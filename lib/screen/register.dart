import 'package:flutter/material.dart';
import 'package:group_project/data/user_data.dart';
import 'package:group_project/screen/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final userData ud;

  const RegisterScreen({super.key, required this.ud});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // TextField()에 적힌 값을 사용하기 위한 컨트롤러 생성
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password1 = TextEditingController();
  final TextEditingController _password2 = TextEditingController();

  String errorMessage = '';

  // 사용이 끝난 컨트롤러는 dispose()
  @override
  void dispose() {
    _email.dispose();
    _password1.dispose();
    _password2.dispose();
    super.dispose();
  }

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
                  const SizedBox(height: 70),
                  const Text(
                    '앱 이름',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 50),
                  const Text(
                    '계정 만들기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    '이 앱에 가입하려면 이메일을 입력하세요',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextField(
                      controller: _email,
                      decoration: const InputDecoration(
                        hintText: '이메일을 입력하세요',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextField(
                      controller: _password1,
                      decoration: const InputDecoration(
                        hintText: '비밀번호를 입력하세요',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextField(
                      controller: _password2,
                      decoration: const InputDecoration(
                        hintText: '비밀번호 확인',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 300,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          errorMessage = _inputCheck();
                        });
                        // _inputCheck에서 오류가 없었다면 로그인창으로 넘어감
                        if (_inputCheck() == '') {
                          _registerSuccess(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '계속',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 회원가입 기입 텍스트 검사 함수
  String _inputCheck() {
    String email = _email.text;
    String password1 = _password1.text;
    String password2 = _password2.text;

    // AI 코드 활용
    // ^[^@\s] : @와 공백을 제외한 문자가 1자 이상 필수
    // @ : @ 기호 필수
    // [a-zA-Z0-9-]+ : @ 직후 영문/숫자/하이픈 1자 이상 필수
    // \. : . 기호 필수
    // [a-zA-Z]{2,} : 확장자 2자 이상 필수
    final RegExp emailCheck =
        RegExp(r'^[^@\s]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}(?:\.[a-zA-Z]{2,})?$');

    if (email.isEmpty) {
      return '이메일 입력이 누락되었습니다.';
    }
    if (password1.isEmpty || password2.isEmpty) {
      return '비밀번호 입력이 누락되었습니다.';
    }
    if (email.contains(' ')) {
      return '이메일에 공백이 포함되어 있습니다.';
    }
    if (!emailCheck.hasMatch(email)) {
      return '이메일은 email@domain.com 형식입니다.';
    }
    if (password1.contains(' ') || password2.contains(' ')) {
      return '비밀번호에 공백이 포함되어 있습니다.';
    }
    if (password1 != password2) {
      return '비밀번호가 일치하지 않습니다.';
    }
    return '';
  }

  // 회원가입 완료 하면 작동할 함수
  void _registerSuccess(BuildContext context) {
    // 방금 입력한 _email, _password1을 ud.json 파일에 저장

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen(ud: widget.ud)),
      (route) => false, // 이전 모든 화면 삭제
    );
  }
}
