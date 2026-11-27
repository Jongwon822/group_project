import 'package:material_ui/material_ui.dart';
import 'package:group_project/data/user_data.dart';

class PasswordFinderScreen extends StatefulWidget {
  final String selection;

  const PasswordFinderScreen({super.key, required this.selection});

  @override
  State<PasswordFinderScreen> createState() => _PasswordFinderScreenState();
}

class _PasswordFinderScreenState extends State<PasswordFinderScreen> {
  // TextField()에 적힌 값을 사용하기 위한 컨트롤러 생성
  final TextEditingController _text1 = TextEditingController();
  final TextEditingController _text2 = TextEditingController();

  String errorMessage = '';
  String output = '';
  bool findCheck = false;
  bool _isLoading = false;

  // 사용이 끝난 컨트롤러는 dispose()
  @override
  void dispose() {
    _text1.dispose();
    _text2.dispose();
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
                  findCheck == false
                      ? widget.selection == 'id'
                          ? _finder(
                              'Find Email',
                              'Enter your information to find your email',
                              'Enter your password')
                          : _finder(
                              'Find Password',
                              'Enter your information to find your password',
                              'Enter your email')
                      : widget.selection == 'id'
                          ? _output('Find Email', output)
                          : _output('Find Password', output)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _output(String title, String output) {
    return Column(children: [
      Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 34),
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 100,
          width: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
          ),
          alignment: Alignment.center,
          child: Text(
            output,
            style: const TextStyle(fontSize: 18),
          )),
    ]);
  }

  // text1 = name, text2 = email or password 로 사용
  Widget _finder(String title, String subTitle, String hintText) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          subTitle,
          style: const TextStyle(
              fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
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
            controller: _text1,
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
            controller: _text2,
            decoration: InputDecoration(
              hintText: hintText,
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
                    setState(() {
                      _isLoading = true;
                      errorMessage = '';
                    });

                    try {
                      String? userOutput = await _isUserExits(
                          _text1.text.trim(),
                          _text2.text.trim(),
                          widget.selection);
                      if (!mounted) return;

                      if (userOutput == null) {
                        setState(() {
                          _isLoading = false;
                          errorMessage = 'No matching account found.';
                        });
                      } else {
                        output = userOutput;
                        setState(() {
                          _isLoading = false;
                          findCheck = true;
                        });
                      }
                    } catch (e) {
                      if (!mounted) return;
                      setState(() {
                        _isLoading = false;
                        errorMessage =
                            'Failed to connect to server. Please try again.';
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
                    'Find',
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
    );
  }

  Future<String?> _isUserExits(
      String text1, String text2, String target) async {
    await UserManager.load();
    if (target == 'id') {
      UserData? ud = UserManager.uds
          .where((ud) => ud.name == text1 && ud.password == text2)
          .firstOrNull;
      if (ud != null) {
        return ud.id;
      } else {
        return null;
      }
    } else {
      UserData? ud = UserManager.uds
          .where((ud) => ud.name == text1 && ud.id == text2)
          .firstOrNull;
      if (ud != null) {
        return ud.password;
      } else {
        return null;
      }
    }
  }
}
