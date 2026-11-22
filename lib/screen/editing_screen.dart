import 'package:material_ui/material_ui.dart';
import 'package:group_project/data/user_data.dart';
import 'package:group_project/data/open_router.dart';

import 'package:group_project/data/resume_database.dart';

/* 임시로 만든 open_router로 AI사용하게 만들어놨음
디자인 및 세부사항은 수정해줄것 -> 해봄

자소서 입력과 첨삭결과 출력 모두 글씨크기에 비해 칸이 너무 작음
애초에 홈화면처럼 스크롤뷰로 묶거나 입력과 출력의 페이지를 다르게 하는 방식이 필요해 보임 -> 두페이지로 나눔

자소서 첨삭할 때 입력할 프롬프트도 정해놔야할듯 -> 이건나중에

자소서 삭제 기능도 넣어야 할 듯 -> db먼저 구현하고함
위치는 설정?

*/

//db관련기능, 직군선택, 창 넘어가는 구조 AI활용, 그 외에는 코드에 표시

class EditingScreen extends StatefulWidget {
  final UserData ud; // 나중에 AI 답변 출력할 때 프롬프트에 사용할 세팅 값을 ud로 가져오는 방식으로 만들어줘
  const EditingScreen({super.key, required this.ud});

  @override
  State<EditingScreen> createState() => _EditingScreenState();
}

class _EditingScreenState extends State<EditingScreen> {
  final TextEditingController _textController1 = TextEditingController(); // 입력
  late final List<String> _itemList;
  String? _selectedJob;

  final TextEditingController _textController2 = TextEditingController(); // 출력

  bool _isReviewLoading = false; // 첨삭 로딩 상태

  int _resetCount = 0; //첨삭요청 로딩중 초기화 시 결과창 등장 방지

  //임시저장
  @override
  void initState() {
    super.initState();

    //복원
    //이전 직군이 관심목록에 있으면 그걸로, 없으면 맨 위에껄로
    _itemList = widget.ud.userSettings.jobs;

    final draftJob = widget.ud.draftJob;
    _selectedJob = _itemList.contains(draftJob)
        ? draftJob
        : (_itemList.isEmpty ? null : _itemList.first);

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
    _resetCount++;
    _textController1.clear();
    _textController2.clear();

    // 첨삭 결과를 비울 때 그 결과에 연결된 원문과 직무도 비운다.
    widget.ud.draftResultEssay = null;
    widget.ud.draftResultJob = null;

    final defaultJob = _itemList.isEmpty ? null : _itemList.first;
    widget.ud.draftJob = defaultJob ?? '';

    setState(() {
      _selectedJob = defaultJob;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAnyLoading = _isReviewLoading; // loading이 안끝났으면 버튼 작동 X
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
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
              height: c.maxHeight < 280 ? 280 : c.maxHeight,
              //칸 일정 이상 작아지면 더이상 안작아지고 스크롤
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            "지원 직무",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            //AI활용
                            child: DropdownMenu<String>(
                              initialSelection: _selectedJob,
                              textAlign: TextAlign.right,
                              //관심직군이 있을때만 enable
                              enabled: _itemList.isNotEmpty,
                              //관심직군이 비었을 때 안내 문구
                              hintText: _itemList.isEmpty
                                  ? '설정에서 관심 직군을 추가해 주세요'
                                  : null,
                              expandedInsets: EdgeInsets.zero,
                              // 가로 꽉 채우기
                              requestFocusOnTap: false,
                              // 키보드 입력 막고 선택만 가능하게
                              menuStyle: const MenuStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(Colors.white),
                                //surfaceTintColor: WidgetStatePropertyAll(Colors.transparent), // 보라빛 틴트 제거
                              ),
                              inputDecorationTheme: const InputDecorationTheme(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                border: InputBorder.none,
                              ),
                              dropdownMenuEntries: _itemList
                                  //.where((item) => item != _selectedJob) // 선택된 항목 제외
                                  .map((String item) {
                                return DropdownMenuEntry<String>(
                                    value: item, label: item);
                              }).toList(),
                              onSelected: (String? newValue) {
                                if (newValue == null) return;

                                setState(() {
                                  _selectedJob = newValue;
                                });
                                widget.ud.draftJob = newValue; //선택한 직군 임시저장
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                          '자기소개서',
                           style: TextStyle(
                             fontSize: 16,
                             fontWeight: FontWeight.bold,
                           ),
                         )
                        ),
                        // 이미 받은 결과가 있을 때만 버튼을 표시한다.
                        if (_textController2.text.trim().isNotEmpty)
                          Transform.translate(
                            offset: const Offset(0, 4), // 오른쪽으로 0, 아래로 4
                            child: TextButton(
                              onPressed: isAnyLoading
                                  ? null
                                  : () {
                                Navigator.of(context).push<void>(
                                  MaterialPageRoute<void>(builder: _editResult),
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.grey.shade700,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              child: const Text('이전 결과 보기'),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade200),
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
                  ],
                ),
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200),),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: resetAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.grey.shade700,
                      elevation: 0,
                      minimumSize: const Size(0, 54),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: const Text('전체 초기화', textAlign: TextAlign.center),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isAnyLoading ? null : _requestReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(0, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    // 로딩 표시도 아이콘 없이 글자로 보여준다.
                    child: Text(isAnyLoading ? '첨삭 중…' : '첨삭 요청'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

    final job = _selectedJob; //db용
    final resetCount = _resetCount; //로딩과정에서 초기화해 _resetCount 변경시 결과창 안열림

    setState(() => _isReviewLoading = true);

    try {
      final stylePrompt = widget.ud.userSettings.feedbackStyle.promptText;
      final result = await OpenRouterService.sendPrompt(
        systemPrompt: '당신은 채용 담당자 출신의 자기소개서 첨삭 전문가입니다. $stylePrompt '
            '지원 직무에 맞춰 문맥, 논리력, 직무 적합성을 분석하고 수정 제안을 제공하세요.',
        prompt: '지원 직무: $job\n\n[자기소개서 내용]\n$essay',
      );

      //_resetCount확인
      if (!mounted || resetCount != _resetCount) {
        return;
      }

      // 이전 결과 보기에서 저장할 때도 이 결과에 맞는 원문과 직무를 사용
      widget.ud.draftResultEssay = essay;
      widget.ud.draftResultJob = job;

      _textController2.text = result; // 리스너를 통해 draftResult에도 자동 저장됨

      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: _editResult),
      );
    } catch (e) {
      _showSnackBar('첨삭 요청 중 오류가 발생했습니다. 다시 시도해 주세요.');
    } finally {
      if (mounted) {
        setState(() => _isReviewLoading = false);
      }
    }
  }

  //첨삭결과화면
  Widget _editResult(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: const Text(
          'AI 첨삭 결과',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox.expand(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // 결과 칸 배경
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _textController2,
                maxLines: null,
                expands: true,
                readOnly: true,
                showCursor: true,
                canRequestFocus: true,
                enableInteractiveSelection: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: '결과 출력',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),
          ),
        ),
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200), // 본문과 하단 영역의 구분선
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _saveResume,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '자소서 저장하기',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //AI활용
  Future<void> _saveResume() async {
    final content = _textController2.text.trim();
    if (content.isEmpty) {
      _showSnackBar('저장할 자소서 내용을 먼저 입력해 주세요.');
      return;
    }

    // 저장 창을 띄우기 전에 현재 결과와 짝이 되는 원문과 직무를 읽어 둔다.
    final originalText = widget.ud.draftResultEssay;
    final job = widget.ud.draftResultJob;

    //원문 정보가 없ㅅㅅ으면 첨삭 재요청
    if (originalText == null) {
      _showSnackBar('원문을 함께 저장하려면 첨삭을 다시 요청해 주세요.');
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

    //신규저장인지 덮어쓰기인지 확인
    try {
      final isOverwrite = await ResumeDatabase.saveResume(
        userId: widget.ud.id,
        title: resumeName,
        job: job,
        originalText: originalText,
        editedText: content,
      );

      _showSnackBar(
        isOverwrite
            ? "'$resumeName' 자소서를 덮어썼습니다."
            : "'$resumeName' 자소서가 저장되었습니다.",
      );
    } catch (_) {
      _showSnackBar('자소서를 저장하지 못했습니다. 다시 시도해 주세요.');
    }
  }


}
