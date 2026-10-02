import 'package:flutter/material.dart';
import 'package:group_project/data/user_data.dart';
import 'package:group_project/screen/register.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  final List<UserData> uds;
  final List<Announcement>? ancList;
  final ValueChanged<String> login;

  const LoginScreen({super.key, this.ancList, required this.uds, required this.login});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // TextField()에 적힌 값을 사용하기 위한 컨트롤러 생성
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool autoLogin = false;
  String errorMessage = '';

  // 사용이 끝난 컨트롤러는 dispose()
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
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
                  const Text(
                    '로그인',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 50),
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
                      controller: _password,
                      decoration: const InputDecoration(
                        hintText: '비밀번호를 입력하세요',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    width: 354,
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
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 300,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          errorMessage = _loginCheck();
                        });
                        // 계속 누르면 작동할 함수
                        if (_loginCheck()=='') {
                          _savedAutoLogin(autoLogin); // 자동로그인 여부를 prefs에 저장
                          widget.login(_email.text); // 로그인 성공한 ud로 메인 진입
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
                                // 비밀번호 찾기 창 => 이메일, 이름을 입력하면 출력해줌
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
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                _OpenRegister();
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


  // 회원가입 창 넘어갔다가 다시 돌아올 때 에러 메세지랑 입력 내용 지우는 함수
  Future<void> _OpenRegister() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RegisterScreen(uds: widget.uds),
      ),
    );
    if (mounted) {
      setState(() {
        errorMessage = '';
        _email.clear();
        _password.clear();
      });
    }
  }

  // 로그인 했을 때 autoLogin이 true라면
  void _savedAutoLogin(bool autoLogin) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (autoLogin) {
      prefs.setString('id', _email.text);
      prefs.setBool('autoLogin', true);
    }
  }


  String _loginCheck() {

    UserData? ud = widget.uds.where((ud) => ud.id == _email.text).firstOrNull;

    if (ud == null) {
      return '이메일이 일치하지 않습니다.';
    }
    if (ud.password != _password.text) {
      return '비밀번호가 일치하지 않습니다.';
    }
    return '';
  }
}
