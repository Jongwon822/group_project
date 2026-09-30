import 'package:flutter/material.dart';
import 'package:group_project/screen/home_screen.dart';
import 'package:group_project/data/announcement.dart';
import 'package:group_project/screen/login_screen.dart';

// 로그인창 이외의 공간에서 계속 하단에 적용 될 BottomNavigationBar

class MainNavigationScreen extends StatefulWidget {
  final List<Announcement>? ancList;
  const MainNavigationScreen({super.key, required this.ancList});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // BottomNavigationBar로 보여줄 화면 리스트
  late final List<Widget> _pages = [
    HomeScreen(ancList: widget.ancList), // 분리한 상단 탭바 + 리스트뷰 화면
    const Center(child: Text('달력을 그리자')), // 달력을 눌렀을 때 출력될 화면 함수를 지정해줘야함
    // const Center(child: Text('설정 화면')), // 설정을 눌렀을 때 출력될 화면 함수를 지정해줘야함
    LoginScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        // bottomNavigationBar에서 label 표시 숨기기
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'setting'),
        ],
      ),
    );
  }
}