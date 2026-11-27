import 'package:material_ui/material_ui.dart';
import 'package:group_project/data/user_data.dart';
import 'package:group_project/screen/job_category_select.dart';
import 'package:group_project/screen/login/login_screen.dart';
import 'package:group_project/screen/main_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:async';

// 로그아웃 후 로그인 화면에서 안내 메시지를 보여주기 위한 전역 키
final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // .env 파일 로드
  await dotenv.load(fileName: ".env");

  // 자동 로그인 값 불러오기
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool initAutoLog =
      prefs.getBool('autoLogin') ?? false; // 앱을 처음 킨거라면 false로 설정
  String? savedId = prefs.getString('id');

  UserData? initUd;
  bool sessionMatchedOnBoot = false; // 자동로그인 세션 일치 여부

  if (initAutoLog && savedId != null) {
    initUd = await UserManager.loadUser(savedId);

    // 기기 저장 sessionId와 Firestore의 activeSessionId 일치 여부 확인
    final savedSessionId = await UserManager.loadSavedSessionId();
    if (initUd != null &&
        savedSessionId != null &&
        initUd.activeSessionId == savedSessionId) {
      sessionMatchedOnBoot = true;
    } else {
      // 다른 기기에서 로그인되었거나 세션 정보가 없으면 자동 로그인 해제
      initUd = null;
      initAutoLog = false;
      await prefs.setBool('autoLogin', false);
      await prefs.remove('id');
      await UserManager.clearSavedSessionId();
    }
  }

  runApp(MyApp(
    initAutoLog: initAutoLog,
    savedId: savedId,
    initUd: initUd,
    sessionMatchedOnBoot: sessionMatchedOnBoot,
  ));
}

class MyApp extends StatefulWidget {
  final bool initAutoLog;
  final String? savedId;
  final UserData? initUd;
  final bool sessionMatchedOnBoot;

  const MyApp({
    super.key,
    required this.initAutoLog,
    required this.savedId,
    this.initUd,
    this.sessionMatchedOnBoot = false,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  UserData? ud;
  late bool autoLog;
  Timer? _sessionTimer; // 주기적 세션 체크 타이머

  // 처음 생성될때는 외부값 가져오고 이후에는 autoLog로 사용
  // final로 선언하고 받아오면 값 변경이 안됨
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this); // 옵저버 등록

    // 다른 기기 후속 로그인 감지 시 강제 로그아웃 및 안내 표시
    UserManager.onSessionExpired = () {
      if (!mounted || ud == null) return;
      _Logout(showExpiredMessage: true);
    };

    autoLog = widget.initAutoLog;

    // autoLog(초기값)과 저장된 id가 둘 다 있으면
    if (autoLog && widget.savedId != null && widget.sessionMatchedOnBoot) {
      ud = widget.initUd;
      UserManager.currentUser = ud;
      _startSessionWatcher();
    } else {
      // id 저장은 되어있는데 uds에 없다면 null 할당
      ud = null;
      UserManager.currentUser = null;
    }
  }

  // 앱이 다시 활성화(resumed)될 때 세션 유효성 즉시 확인
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && ud != null) {
      UserManager.verifySession();
    }
  }

  // 10초마다 Firestore activeSessionId 변경 여부 확인
  void _startSessionWatcher() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (ud != null) {
        UserManager.verifySession();
      }
    });
  }

// 세션 감시 타이머 정지
  void _stopSessionWatcher() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  @override
  void dispose() {
    _stopSessionWatcher();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

// 해당 이메일을 가진 UserData 객체를 ud에 저장
  void _Login(String id) {
    setState(() {
      ud = UserManager.uds
          .firstWhere((ud) => ud.id == id); // ud에 id로 검색해서 찾은 객체를 할당
      UserManager.currentUser = ud;
    });
  }

// ud = null 로 설정
  void _Logout({bool showExpiredMessage = false}) {
    _stopSessionWatcher();
    // 현재 기기가 최신 세션을 점유 중이었다면 Firestore의 activeSessionId도 비워줌
    final loggingOutUser = ud;
    if (loggingOutUser != null &&
        loggingOutUser.activeSessionId == UserManager.currentSessionId) {
      loggingOutUser.activeSessionId = null;
      UserManager.save(loggingOutUser);
    }
    setState(() {
      ud = null;
      autoLog = false;
      UserManager.currentUser = null;
    });

    UserManager.clearSavedSessionId(); // 로컬 세션 ID 삭제

    // 로그아웃 후 앱 재실행 시 자동 로그인이 풀려 있도록 SharedPreferences 초기화
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('autoLogin', false);
      prefs.remove('id');
    });

    // 다른 기기 로그인으로 인한 세션 종료 안내 메시지
    if (showExpiredMessage) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('다른 기기에서 로그인하여 현재 세션이 종료되었습니다.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: '우리가 만든 앱',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          useMaterial3: true,
        ),
        home: ud != null
            ? ud!.userSettings.firstSetting
                ? JobCategoryScreen(
                    ud: ud!, login: _Login) // ud는 지정되었으나 첫방문인 경우 사전 설정 화면
                : MainNavigationScreen(
                    ud: ud!, logout: _Logout) // ud도 지정되었고 사전 설정 기록이 있는 경우 메인 화면
            : LoginScreen(login: _Login)); // ud 지정 안된 경우 로그인 화면
  }
}
