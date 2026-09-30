import 'package:flutter/material.dart';
import 'package:group_project/data/user_data.dart';

class LoginScreen extends StatelessWidget {
  // final userData ud;

  const LoginScreen({super.key});

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
                      SizedBox(height: 70,),
                      const Text('앱 이름', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                      const Text('로그인', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),),
                      SizedBox(height: 50,),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey)
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: '이메일을 입력하세요.',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 25,),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        width: 300,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey)
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: '비밀번호를 입력하세요.',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 25,),
                      ElevatedButton(onPressed: () {
                        // 계속 누르면 진행할 함수
                      },
                        child: Text('계속', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                      )
                    ],
                  )


                ),
              ]
            ),
        ),
    );
  }
}
