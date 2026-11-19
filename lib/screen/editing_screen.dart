import 'package:material_ui/material_ui.dart';
import 'package:group_project/data/user_data.dart';
import 'package:group_project/data/open_router.dart';

/* 임시로 만든 open_router로 AI사용하게 만들어놨음
디자인 및 세부사항은 수정해줄것
자소서 입력과 첨삭결과 출력 모두 글씨크기에 비해 칸이 너무 작음
애초에 홈화면처럼 스크롤뷰로 묶거나 입력과 출력의 페이지를 다르게 하는 방식이 필요해 보임
자소서 첨삭할 때 입력할 프롬프트도 정해놔야할듯


자소서 삭제 기능도 넣어야 할 듯
위치는 설정?

*/

class EditingScreen extends StatefulWidget {
  final UserData ud; // 나중에 AI 답변 출력할 때 프롬프트에 사용할 세팅 값을 ud로 가져오는 방식으로 만들어줘
  const EditingScreen({super.key, required this.ud});

  @override
  State<EditingScreen> createState() => _EditingScreenState();
}

class _EditingScreenState extends State<EditingScreen> {
  final TextEditingController _textController1 = TextEditingController(); // 입력
  final List<String> _itemList = ['마케팅', 'A', 'B', 'C'];
  String? _selectedJob = '마케팅'; //--------AI
  // 이거 리스트는 나중에 ud.userSettings에 저장된 관심직군으로 하면 될듯

  final TextEditingController _textController2 = TextEditingController(); // 출력

  bool _isReviewLoading = false; // 첨삭 로딩 상태

  //임시저장
  @override
  void initState() {
    super.initState();

    //복원
    _selectedJob = widget.ud.draftJob;
    _textController1.text = widget.ud.draftEssay;
    _textController2.text = widget.ud.draftResult;

    //내용변경시 임시저장
    _textController1.addListener(() {
      widget.ud.draftEssay = _textController1.text;
    });
    _textController2.addListener(() {
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
  void resetAll() {
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
    final isAnyLoading = _isReviewLoading; // loading이 안끝났으면 버튼 작동 X
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          // 이거 해줘야 스크롤 내렸을 때 앱바 색상 안변함
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context); //되돌아가기
              },
              icon: const Icon(
                Icons.arrow_back,
                size: 30,
              )),

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
            child: SizedBox(
              height: c.maxHeight < 600 ? 600 : c.maxHeight,
              //칸 일정 이상 작아지면 더이상 안작아지고 스크롤
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
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      dropdownMenuEntries: _itemList
                          //.where((item) => item != _selectedJob) // 선택된 항목 제외
                          .map((String item) {
                        return DropdownMenuEntry<String>(
                            value: item, label: item);
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
                          onPressed: () {
                            isAnyLoading ? null : _requestReview();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ), //request feedback
                          child: isAnyLoading
                              ? const SizedBox(
                                  // 로딩 중 표시
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "첨삭 요청",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
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
                          onPressed: isAnyLoading ? null : _saveResume,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            /*side: const BorderSide(
                              color: Color(0xFF3B82F6),
                              width: 1.0,
                            ),*/
                          ), //request feedback
                          child: const Text(
                            "자소서 저장하기",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
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
                          child: const Text(
                            "전체 내용 초기화",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4F46E5)),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          );
        }));
  }

  // ------ AI 코드 사용 ------
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // AI 자소서 첨삭 요청, 시스템 프롬프트 변경 필요
  // ------ AI 코드 사용 ------
  Future<void> _requestReview() async {
    final essay = _textController1.text.trim();
    if (essay.isEmpty) {
      _showSnackBar('자소서 내용을 먼저 입력해 주세요.');
      return;
    }

    setState(() => _isReviewLoading = true);

    try {
      final stylePrompt = widget.ud.userSettings.feedbackStyle.promptText;
      final result = await OpenRouterService.sendPrompt(
        systemPrompt: '당신은 채용 담당자 출신의 자기소개서 첨삭 전문가입니다. $stylePrompt '
            '지원 직무에 맞춰 문맥, 논리력, 직무 적합성을 분석하고 수정 제안을 제공하세요.',
        prompt: '지원 직무: $_selectedJob\n\n[자기소개서 내용]\n$essay',
      );

      setState(() {
        _textController2.text = result; // 리스너를 통해 draftResult에도 자동 저장됨
      });
    } catch (e) {
      _showSnackBar('첨삭 요청 중 오류가 발생했습니다. 다시 시도해 주세요.');
    } finally {
      if (mounted) {
        setState(() => _isReviewLoading = false);
      }
    }
  }

  Future<void> _saveResume() async {
    final content = _textController2.text.trim();
    if (content.isEmpty) {
      _showSnackBar('저장할 자소서 내용을 먼저 입력해 주세요.');
      return;
    }

    String inputName = '';

    final String? resumeName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '자소서 저장',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            autofocus: true,
            onChanged: (value) => inputName = value,
            decoration: InputDecoration(
              hintText: '저장할 자소서 이름을 입력하세요',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final trimmed = inputName.trim();
                if (trimmed.isEmpty) return;
                Navigator.pop(dialogContext, trimmed);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('저장'),
            ),
          ],
        );
      },
    );

    // 취소를 눌렀거나 이름을 입력하지 않은 경우 종료
    if (resumeName == null || resumeName.isEmpty) return;

    final bool isOverwrite = widget.ud.resumeList.containsKey(resumeName);

    // Map<String, String>에 ('이름', '내용') 저장 후 파일 반영
    widget.ud.resumeList[resumeName] = content;
    await UserManager.save();

    _showSnackBar(
      isOverwrite
          ? "'$resumeName' 자소서를 덮어썼습니다."
          : "'$resumeName' 자소서가 저장되었습니다.",
    );
  }
}
