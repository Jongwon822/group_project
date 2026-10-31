import 'package:flutter/material.dart';
import 'package:group_project/data/user_data.dart';

class EditingScreen extends StatefulWidget {

  final UserData ud; // 나중에 AI 답변 출력할 때 프롬프트에 사용할 세팅 값을 ud로 가져오는 방식으로 만들어줘
  const EditingScreen({super.key, required this.ud});

  @override
  State<EditingScreen> createState() => _EditingScreenState();
}

class _EditingScreenState extends State<EditingScreen> {


  final TextEditingController _textController1 = TextEditingController();
  final List<String> _itemList = ['마케팅', 'A', 'B', 'C'];
  String? _selectedJob = '마케팅'; //--------AI

  final TextEditingController _textController2 = TextEditingController();

  //임시저장
  @override
  void initState(){
    super.initState();

    //복원
    _selectedJob = widget.ud.draftJob;
    _textController1.text = widget.ud.draftEssay;
    _textController2.text = widget.ud.draftResult;

    //내용변경시 임시저장
    _textController1.addListener((){
      widget.ud.draftEssay = _textController1.text;
    });
    _textController2.addListener((){
      widget.ud.draftResult = _textController2.text;
    });
  }

  // 사용이 끝난 컨트롤러는 dispose()
  @override
  void dispose() {
    _textController1.dispose();
    _textController2.dispose();
    super.dispose();
  }

  //전체 초기화
  void resetAll(){
    _textController1.clear();
    _textController2.clear();

    widget.ud.draftJob = '마케팅';
    widget.ud.draftEssay = '';
    widget.ud.draftResult = '';

    setState(() {
      _selectedJob = '마케팅';
    });
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

      body: LayoutBuilder(//입력칸 높이 자동 조절
        builder: (context, c) {
          return SingleChildScrollView(
            child:SizedBox(
              height: c.maxHeight < 600 ? 600 : c.maxHeight, //칸 일정 이상 작아지면 더이상 안작아지고 스크롤
              child: Padding(
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

                    //NEW VERSION(AI)--------------------------
                    DropdownMenu<String>(
                      initialSelection: _selectedJob,
                      expandedInsets: EdgeInsets.zero,
                      // 가로 꽉 채우기
                      requestFocusOnTap: false,
                      // 키보드 입력 막고 선택만 가능하게
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
                        widget.ud.draftJob = newValue!; //선택한 직군 임시저장
                      },
                    ),
                    //-------------------------------------------

                    const SizedBox(height: 20),

                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),

                        child: TextField(
                          controller: _textController1,
                          maxLines: null,
                          expands: true,
                          keyboardType: TextInputType.multiline,
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
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ), //request feedback
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

                    Expanded(
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),

                        child: TextField(
                          controller: _textController2,
                          maxLines: null,
                          expands: true,
                          keyboardType: TextInputType.multiline,
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
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            /*side: const BorderSide(
                              color: Color(0xFF3B82F6),
                              width: 1.0,
                            ),*/
                          ), //request feedback
                          child:
                          const Text(
                            "면접 질문 만들기",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                      ),
                    ),

                    const SizedBox(height: 20),

                    //전체초기화
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                          onPressed: resetAll,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEEF2FF),
                            foregroundColor: const Color(0xFF4F46E5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            /*side: const BorderSide(
                              color: Color(0xFF3B82F6),
                              width: 1.0,
                            ),*/
                          ), //request feedback
                          child:
                          const Text(
                            "전체 내용 초기화",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4F46E5)
                            ),
                          )
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      )
    );
  }
}