import 'package:flutter/material.dart';
import 'package:group_project/data/announcement.dart';
import 'package:group_project/data/user_data.dart';
import 'package:group_project/screen/main_navigation.dart';

class LoginScreen extends StatefulWidget {

  final userData ud;
  final List<Announcement>? ancList;

  const LoginScreen({super.key, this.ancList, required this.ud});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool autoLogin = false; // 로그인 화면에서는 자동로그인이 기본적으로 풀려있음

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 520,
              alignment: Alignment.center,
              child: Column(
                children: [
                  SizedBox(height: 70),
                  const Text(
                    '앱 이름',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    '로그인',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 50),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: '이메일을 입력하세요.',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: '비밀번호를 입력하세요.',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 5,),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    width: 300,
                    child: Row(
                      children: [
                        Checkbox(
                          value: autoLogin,
                          onChanged: (value) {
                            setState(() {
                              autoLogin = value!;
                            });
                          },
                        ),
                        const Text('자동 로그인')

                      ],
                    ),
                  ),

                  SizedBox(height: 10,),

                  SizedBox(
                    width: 300,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // 계속 누르면 작동할 함수
                        _loginSuccess(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '계속',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                // 자세히 보기 눌렀을 때 작동하는거 navigation.push로 나중에 기입해줄것!!
                              },
                              style: TextButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text(
                                "비밀번호 찾기",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        height: 13,
                        width: 1,
                        color: Colors.grey,
                        margin: EdgeInsets.symmetric(horizontal: 8),
                      ),

                      Expanded(
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                // 자세히 보기 눌렀을 때 작동하는거 navigation.push로 나중에 기입해줄것!!
                              },
                              style: TextButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text(
                                "회원가입",
                                style: TextStyle(
                                  color: Color(0xFF4F46E5),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 로그인 완료 하면 작동할 함수
  void _loginSuccess(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MainNavigationScreen(ancList: widget.ancList, ud: widget.ud,)),
      (route) => false, // 이전 모든 화면 삭제
    );
  }
}
