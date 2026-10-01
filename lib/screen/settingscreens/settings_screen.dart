import 'package:flutter/material.dart';
import 'package:group_project/data/user_data.dart';
import 'package:group_project/screen/login_screen.dart';

class SettingScreen extends StatefulWidget {
  final userData ud;

  const SettingScreen({super.key, required this.ud});

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
          SizedBox(height: 10),
          Row(
            children: [
              SizedBox(width: 16),
              CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFFE4EEFF),
                foregroundColor: Color(0xFF1F5ADD),
                child: Text(
                  widget.ud.id,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),

              // 알아서 채우쇼


            ],
          ),

          TextButton(
            onPressed: () {
              _logout(context);
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

  // 로그아웃 하면 작동할 함수
  void _logout(BuildContext context) {
    widget.ud.isLogged != widget.ud.isLogged;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen(ud: widget.ud)),
      (route) => false,
    );
  }
}
