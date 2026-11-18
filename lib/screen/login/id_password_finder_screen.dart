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
                              '이메일 찾기', '이메일을 찾기 위한 개인정보를 입력하세요', '비밀번호를 입력하세요')
                          : _finder('비밀번호 찾기', '비밀번호를 찾기 위한 개인정보를 입력하세요',
                              '이메일을 입력하세요')
                      : widget.selection == 'id'
                          ? _output('이메일 찾기', output)
                          : _output('비밀번호 찾기', output)
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
          child: Text(output, style: const TextStyle(fontSize: 18),)),
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
              hintText: '이름을 입력하세요',
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
            onPressed: () async {
              String? userOutput = await _isUserExits(
                  _text1.text, _text2.text, widget.selection);
              if (userOutput == null) {
                setState(() {
                  errorMessage = '일치하는 계정이 존재하지 않습니다';
                });
              } else {
                output = userOutput;
                setState(() {
                  findCheck = true;
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
            child: const Text(
              '찾기',
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
