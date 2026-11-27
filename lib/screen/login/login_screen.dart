import 'package:material_ui/material_ui.dart';
import 'package:group_project/data/user_data.dart';
import 'package:group_project/screen/login/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:group_project/screen/login/id_password_finder_screen.dart';

// 비밀번호 찾기 기능 미완성, 다이어로그로 할지 고민중

class LoginScreen extends StatefulWidget {
  final ValueChanged<String> login;

  const LoginScreen({super.key, required this.login});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // TextField()에 적힌 값을 사용하기 위한 컨트롤러 생성
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool autoLogin = false;
  String errorMessage = '';
  bool _isLoading = false;

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
                    'Login',
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
                        hintText: 'Enter your email',
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
                        hintText: 'Enter your password',
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
                        const Text('Keep me signed in')
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
                      onPressed: _isLoading
                          ? null
                          : () async {
                              setState(() {
                                _isLoading = true;
                                errorMessage = '';
                              });
                              final String checkResult = await _loginCheck();
                              if (!mounted) return;

                              if (checkResult == '') {
                                // 로그인 성공 시 새 세션 발급 및 Firestore 반영
                                final matchedUser = UserManager.uds.firstWhere(
                                  (u) => u.id == _email.text.trim(),
                                );
                                await UserManager.activateSessionForUser(
                                    matchedUser);
                                await _savedAutoLogin(autoLogin);

                                if (!mounted) return;
                                setState(() {
                                  _isLoading = false;
                                  errorMessage = '';
                                });
                                widget.login(matchedUser.id);
                              } else {
                                setState(() {
                                  _isLoading = false;
                                  errorMessage = checkResult;
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Continue',
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
                                _OpenIdPasswordFinder('id');
                              },
                              style: TextButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text(
                                "Forgot email?",
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
                      TextButton(
                        onPressed: () {
                          // 비밀번호 찾기 창 => 이메일, 이름을 입력하면 출력해줌
                          _OpenIdPasswordFinder('password');
                        },
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          "Forget password?",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
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
                                "Register",
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
        builder: (context) => const RegisterScreen(),
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

  // 비밀번호 찾기 창 넘어갔다가 다시 돌아올 때 에러 메세지랑 입력 내용 지우는 함수
  Future<void> _OpenIdPasswordFinder(String selection) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PasswordFinderScreen(selection: selection),
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
  Future<void> _savedAutoLogin(bool autoLogin) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (autoLogin) {
      await prefs.setString('id', _email.text);
      await prefs.setBool('autoLogin', true);
    } else {
      await prefs.setBool('autoLogin', false);
      await prefs.remove('id');
    }
  }

  Future<String> _loginCheck() async {
    try {
      await UserManager.load();
    } catch (e) {
      return 'Failed to connect to server. Please try again.';
    }

    final String inputEmail = _email.text.trim();
    UserData? ud =
        UserManager.uds.where((ud) => ud.id == inputEmail).firstOrNull;

    if (ud == null) {
      return 'No account found with this email.';
    }
    if (ud.password != _password.text) {
      return 'Incorrect password.';
    }
    return '';
  }
}
