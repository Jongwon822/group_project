import 'package:flutter/material.dart';
import 'package:group_project/data/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  final UserData ud;
  final VoidCallback logout;
  const SettingScreen({super.key, required this.ud, required this.logout});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: const Text(
          '설정',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFFE4EEFF),
                foregroundColor: const Color(0xFF1F5ADD),
                child: Text(
                  widget.ud.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),

              // 알아서 채우쇼


            ],
          ),



          // onPressed 부분 함수는 유지해줘야해
          TextButton(
            onPressed: () {
              _deleteAutoLogin();
              widget.logout();
            },
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
            ),
            child: const Text(
              "로그 아웃",
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 로그아웃이 시 저장해 둔 자동로그인 정보 삭제
  void _deleteAutoLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('autoLogin', false);
    prefs.remove('id');
  }
}
