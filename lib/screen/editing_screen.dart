import 'package:flutter/material.dart';

class EditingScreen extends StatefulWidget {
  const EditingScreen({super.key});

  @override
  State<EditingScreen> createState() => _EditingScreenState();
}

class _EditingScreenState extends State<EditingScreen> {

  final TextEditingController _textController1 = TextEditingController(); //AIIIIIIIIIIIIII
  final List<String> _itemList = ['마케팅', 'A', 'B', 'C'];
  String? _selectedJob = '마케팅'; //--------AI


  // 텍스트 컨트롤러를 하나로 지정하면 전부 같이 작동함 변수명 다르게 해줘야함
  final TextEditingController _textController2 = TextEditingController();


  // 사용이 끝난 컨트롤러는 dispose()
  @override
  void dispose() {
    _textController1.dispose();
    _textController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0, // 이거 해줘야 스크롤 내렸을 때 앱바 색상 안변함
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context); //되돌아가기
            },
            icon: const Icon(Icons.arrow_back, size: 30,)
        ),

        title: const Text(
          "자소서 첨삭",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "지원 직무",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),


            /* 자꾸 칸이 위로 올라감
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.circular(8),
              ),

              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedJob,
                  isExpanded: true,

                  icon: const Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                  ),

                  items: _itemList.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedJob = newValue;
                    });
                  },
                ),
              ),
            ),
            */

            //NEW VERSION(AI)--------------------------
            DropdownMenu<String>(
              initialSelection: _selectedJob,
              expandedInsets: EdgeInsets.zero, // 가로 꽉 채우기
              requestFocusOnTap: false,        // 키보드 입력 막고 선택만 가능하게
              menuStyle: const MenuStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.white),
                //surfaceTintColor: WidgetStatePropertyAll(Colors.transparent), // 보라빛 틴트 제거
              ),
              inputDecorationTheme: InputDecorationTheme(
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              dropdownMenuEntries: _itemList
              //.where((item) => item != _selectedJob) // 선택된 항목 제외
                  .map((String item) {
                return DropdownMenuEntry<String>(value: item, label: item);
              }).toList(),
              onSelected: (String? newValue) {
                setState(() {
                  _selectedJob = newValue;
                });
              },
            ),
            //-------------------------------------------

            const SizedBox(height: 20),

            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),

              child: TextField(
                controller: _textController1,
                textAlignVertical: TextAlignVertical.top,

                decoration: const InputDecoration(
                  hintText: "자소서 문항과 내용을 붙여넣으세요",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,

                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 39,
              child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),//request feedback
                  child:
                  const Text(
                    "첨삭 요청",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "AI 첨삭 결과",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),

              child: TextField(
                controller: _textController2,
                textAlignVertical: TextAlignVertical.top,

                decoration: const InputDecoration(
                  hintText: "결과 출력",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,

                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 39,
              child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(
                      color: Color(0xFF3B82F6),
                      width: 1.0,
                    ),
                  ),//request feedback
                  child:
                  const Text(
                    "면접 질문 만들기",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }
}