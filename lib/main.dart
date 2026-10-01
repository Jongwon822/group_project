import 'package:flutter/material.dart';
import 'package:group_project/data/user_data.dart';
import 'package:group_project/data/announcement.dart';
import 'package:group_project/screen/login_screen.dart';
import 'package:group_project/screen/main_navigation.dart';


/* 미리 만들어둔 기능!!
홈화면 상단 앱바
홈화면 상단 탭바 (추천 공고 / 추천 자격증)
  ㄴ 추천공고의 경우 가로 스크롤이 가능한 listview 박스까지 구현함 (저장된 추천 공고를 불러오기까지 가능)

홈화면 중단
홈화면 하단 네비게이션바 (홈 / 달력 / 설정)


 */


void main() {

  // 내가 기록한 분야정보 불러오기
  // 나의 달력에 기록된 정보 불러오기
  // 설정 값 불러오기

  // 추천 공고 저장된 파일 불러오기
  final List<Announcement>? ancList = [
    //Announcement(title: '삼성전자 상반기 채용 공고', period: '3.15~3.17', target: '소프트웨어 직군'),
    //Announcement(title: '하이닉스 상반기 채용 공고', period: '3.15~3.17', target: '전자정보 직군'),
    //Announcement(title: 'HD현대 상반기 채용 공고', period: '3.15~3.17', target: '반도체 직군')
  ]; // 일단 공고 불러오기 내용은 임시로 메인에 적어둠 -> 나중에 분리해줄 필요 있음

  // 임시로 false로 해뒀음
  userData ud = userData(id: '이종원', password: '040415', name: '이종원', isLogged: false);

  runApp(MyApp(ancList: ancList, ud: ud));
}

// 임시로 일단 하단 네비게이션바를 메인으로 해두긴했는데
// 로그인창을 만들어야 해서 home: (대충 로그인정보를 저장해둔 파일 검사하는 함수)
// 1. 로그인 정보가 저장 안되어 있는 경우 -> LoginScreen()
// 2. 로그인 정보가 저장 되어 있는 경우 -> HomeScreen()
// 이런 식으로 하면 될듯?

class MyApp extends StatelessWidget {

  final List<Announcement>? ancList;
  final userData ud;

  const MyApp({super.key, required this.ancList, required this.ud});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '우리가 만든 앱',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: ud.isLogged ? MainNavigationScreen(ancList: ancList, ud: ud) : LoginScreen(ud: ud), // 수정 필요함!!
    );
  }



}
