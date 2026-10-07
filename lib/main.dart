import 'package:flutter/material.dart';
import 'package:group_project/data/user_data.dart';
import 'package:group_project/screen/login_screen.dart';
import 'package:group_project/screen/main_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';



void main() async {
  // 내가 기록한 분야정보 불러오기
  // 나의 달력에 기록된 정보 불러오기
  // 설정 값 불러오기

  // 추천 공고 저장된 파일 불러오기
  List<Announcement>? ancList = [
    Announcement(
        title: '삼성전자 상반기 채용 공고', startPeriod: DateTime(2026,10,7), endPeriod: DateTime(2026,10,10), target: '소프트웨어 직군'),
    Announcement(
        title: '하이닉스 상반기 채용 공고', startPeriod: DateTime(2026,10,8), endPeriod: DateTime(2026,10,12), target: '전자정보 직군'),
    Announcement(title: 'HD현대 상반기 채용 공고', startPeriod: DateTime(2026,10,9), endPeriod: DateTime(2026,10,13), target: '반도체 직군')
  ]; // 일단 공고 불러오기 내용은 임시로 메인에 적어둠 -> 나중에 분리해줄 필요 있음

  // 임시 저장 아이디 비번임
  // 지금 자동로그인은 구현했는데 새로만든 아이디를 json파일에 저장하는 작업을 안해서 해당 아이디로만 테스트 가능해
  UserManager.add(UserData(id: 'dlwhddnjs', password: 'dlwhddnjs', name: '이종원', ancList: ancList));
  UserManager.add(UserData(id: 'dlwldnjs', password: 'dlwldnjs', name: '이지원', ancList: ancList));

  // 자동 로그인 값 불러오기
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool initAutoLog = prefs.getBool('autoLogin') ?? false; // 앱을 처음 킨거라면 false로 설정
  String? savedId = prefs.getString('id');

  runApp(MyApp(initAutoLog: initAutoLog, savedId: savedId,));
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
      ud = UserManager.uds.firstWhere((ud) => ud.id == id); // ud에 id로 검색해서 찾은 객체를 할당
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
            ? MainNavigationScreen(ud: ud!, logout: _Logout)
            : LoginScreen(login: _Login)
        );
  }
}
