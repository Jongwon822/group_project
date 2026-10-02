import 'package:flutter/material.dart';
import 'package:group_project/data/user_data.dart';
import 'package:group_project/screen/login_screen.dart';
import 'package:group_project/screen/main_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/* 미리 만들어둔 기능!!
홈화면 상단 앱바
홈화면 상단 탭바 (추천 공고 / 추천 자격증)
  ㄴ 추천공고의 경우 가로 스크롤이 가능한 listview 박스까지 구현함 (저장된 추천 공고를 불러오기까지 가능)

홈화면 중단
홈화면 하단 네비게이션바 (홈 / 달력 / 설정)


 */

void main() async {
  // 내가 기록한 분야정보 불러오기
  // 나의 달력에 기록된 정보 불러오기
  // 설정 값 불러오기

  // 추천 공고 저장된 파일 불러오기
  List<Announcement>? ancList = [
    Announcement(
        title: '삼성전자 상반기 채용 공고', period: '3.15~3.17', target: '소프트웨어 직군'),
    Announcement(
        title: '하이닉스 상반기 채용 공고', period: '3.15~3.17', target: '전자정보 직군'),
    Announcement(title: 'HD현대 상반기 채용 공고', period: '3.15~3.17', target: '반도체 직군')
  ]; // 일단 공고 불러오기 내용은 임시로 메인에 적어둠 -> 나중에 분리해줄 필요 있음

  // 임시로 false로 해뒀음
  List<UserData> uds = [
    UserData(id: 'dlwhddnjs', password: 'dlwhddnjs', name: '이종원'),
    UserData(id: 'dlwldnjs', password: 'dlwldnjs', name: '이지원')
  ];

  // 자동 로그인 값 불러오기
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool initAutoLog = prefs.getBool('autoLogin') ?? false; // 앱을 처음 킨거라면 false로 설정
  String? savedId = prefs.getString('id');

  runApp(MyApp(ancList: ancList, uds: uds, initAutoLog: initAutoLog, savedId: savedId,));
}

// 임시로 일단 하단 네비게이션바를 메인으로 해두긴했는데
// 로그인창을 만들어야 해서 home: (대충 로그인정보를 저장해둔 파일 검사하는 함수)
// 1. 로그인 정보가 저장 안되어 있는 경우 -> LoginScreen()
// 2. 로그인 정보가 저장 되어 있는 경우 -> HomeScreen()
// 이런 식으로 하면 될듯?

class MyApp extends StatefulWidget {

  final List<Announcement>? ancList;
  final List<UserData> uds;
  final bool initAutoLog;
  final String? savedId;

  const MyApp({super.key, required this.ancList, required this.uds, required this.initAutoLog, required this.savedId});

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
        ud = widget.uds.firstWhere((ud) => ud.id == widget.savedId);
      } catch (e) {
        // id 저장은 되어있는데 uds에 없다면 null 할당
        ud = null;
      }
    }
  }


  // 해당 이메일을 가진 UserData 객체를 ud에 저장
  void _Login(String id) {
    setState(() {
      ud = widget.uds.firstWhere((ud) => ud.id == id); // ud에 id로 검색해서 찾은 객체를 할당
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
            ? MainNavigationScreen(ancList: widget.ancList, ud: ud!, logout: _Logout)
            : LoginScreen(uds: widget.uds, login: _Login)
        );
  }
}
