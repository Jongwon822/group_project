import 'package:material_ui/material_ui.dart';
import 'package:group_project/data/user_data.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // TextField()에 적힌 값을 사용하기 위한 컨트롤러 생성
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password1 = TextEditingController();
  final TextEditingController _password2 = TextEditingController();

  String errorMessage = '';
  bool _isLoading = false;

  // 사용이 끝난 컨트롤러는 dispose()
  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password1.dispose();
    _password2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context); //되돌아가기
            },
            icon: const Icon(
              Icons.arrow_back,
              size: 30,
            )),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 520,
              alignment: Alignment.center,
              child: Column(
                children: [
                  const SizedBox(height: 14),
                  const Text(
                    '앱 이름',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 50),
                  const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Enter your email to sign up for this app',
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
                      controller: _name,
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
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
                      controller: _password1,
                      decoration: const InputDecoration(
                        hintText: 'Enter your password',
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
                        hintText: 'Confirm password',
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
                      onPressed: _isLoading
                          ? null
                          : () async {
                              final String validationError = _inputCheck();
                              setState(() {
                                errorMessage = validationError;
                              });
                              // _inputCheck에서 오류가 없었다면 로그인창으로 넘어감
                              if (validationError == '') {
                                await _registerSuccess(context);
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
    String name = _name.text.trim();

    // AI 코드 활용
    // ^[^@\s] : @와 공백을 제외한 문자가 1자 이상 필수
    // @ : @ 기호 필수
    // [a-zA-Z0-9-]+ : @ 직후 영문/숫자/하이픈 1자 이상 필수
    // \. : . 기호 필수
    // [a-zA-Z]{2,} : 확장자 2자 이상 필수
    final RegExp emailCheck =
        RegExp(r'^[^@\s]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}(?:\.[a-zA-Z]{2,})?$');

    if (name.isEmpty) {
      return 'Please enter your name.';
    }
    if (email.isEmpty) {
      return 'Please enter your email.';
    }
    if (email.contains(' ')) {
      return 'Email cannot contain spaces.';
    }
    if (!emailCheck.hasMatch(email)) {
      return 'Please enter a valid email (e.g., email@domain.com).';
    }
    if (password1.isEmpty || password2.isEmpty) {
      return 'Please enter your password.';
    }
    if (password1.contains(' ') || password2.contains(' ')) {
      return 'Password cannot contain spaces.';
    }
    if (password1 != password2) {
      return 'Passwords do not match.';
    }
    return '';
  }

  // 회원가입 완료 하면 작동할 함수
  Future<void> _registerSuccess(BuildContext context) async {
    setState(() {
      _isLoading = true;
      errorMessage = '';
    });
    try {
      final bool isAdded = await UserManager.add(
        UserData(
          id: _email.text.trim(),
          password: _password1.text,
          name: _name.text.trim(),
        ),
      );

      if (!mounted) return;

      if (!isAdded) {
        setState(() {
          _isLoading = false;
          errorMessage = 'This email is already registered.';
        });
        return;
      }

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        errorMessage = 'Registration failed. Please try again.';
      });
    }
  }
}
