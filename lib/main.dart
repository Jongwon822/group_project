import 'package:material_ui/material_ui.dart';
import 'package:group_project/data/user_data.dart';
import 'package:group_project/screen/job_category_select.dart';
import 'package:group_project/screen/login/login_screen.dart';
import 'package:group_project/screen/main_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 내가 기록한 분야정보 불러오기
  // 나의 달력에 기록된 정보 불러오기

  // 유저의 개인정보 모두 불러오기
  await UserManager.load(); // 전역변수 UserData.uds에 저장값 불러오기(window로 run하면 Documents\user_data.json으로 저장됨)


  // 자동 로그인 값 불러오기
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool initAutoLog =
      prefs.getBool('autoLogin') ?? false; // 앱을 처음 킨거라면 false로 설정
  String? savedId = prefs.getString('id');

  runApp(MyApp(
    initAutoLog: initAutoLog,
    savedId: savedId,
  ));
}

class MyApp extends StatefulWidget {
  final bool initAutoLog;
  final String? savedId;

  const MyApp({super.key, required this.initAutoLog, required this.savedId});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  UserData? ud;
  late bool autoLog;

  // 처음 생성될때는 외부값 가져오고 이후에는 autoLog로 사용
  // final로 선언하고 받아오면 값 변경이 안됨
  @override
  void initState() {
    super.initState();
    autoLog = widget.initAutoLog;

    // autoLog(초기값)과 저장된 id가 둘 다 있으면
    if (autoLog && widget.savedId != null) {
      try {
        // ud에 해당 id로 검색한 객체를 할당
        ud = UserManager.uds.firstWhere((ud) => ud.id == widget.savedId);
      } catch (e) {
        // id 저장은 되어있는데 uds에 없다면 null 할당
        ud = null;
      }
    }
  }

  // 해당 이메일을 가진 UserData 객체를 ud에 저장
  void _Login(String id) {
    setState(() {
      ud = UserManager.uds
          .firstWhere((ud) => ud.id == id); // ud에 id로 검색해서 찾은 객체를 할당
    });
  }

  // ud = null 로 설정
  void _Logout() {
    setState(() {
      ud = null;
      autoLog = false;
    });
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
                ? JobCategoryScreen(ud: ud!, login: _Login) // ud는 지정되었으나 첫방문인 경우 사전 설정 화면
                : MainNavigationScreen(ud: ud!, logout: _Logout) // ud도 지정되었고 사전 설정 기록이 있는 경우 메인 화면
            : LoginScreen(login: _Login)); // ud 지정 안된 경우 로그인 화면
  }
}
