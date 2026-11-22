import 'package:material_ui/material_ui.dart';
import 'package:group_project/data/user_data.dart';

//임시데이터 넣어둠.
//세부적인 디자인, DB연동은 나중에 함
//버튼모양같은것들 형식이 다 동일해서 만약 디자인 이걸로 고정하게되면 공통 함수로 뺌
//자소서 별 피드백 횟수도 따로 카운트해서 화면에 표시할까 고민중

class FeedbackScreen extends StatefulWidget {
  final UserData ud;

  const FeedbackScreen({super.key, required this.ud});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

//AI활용
class _FeedbackScreenState extends State<FeedbackScreen> {
  static const _resumes = [
    {'title': '데이터 분석 직무 지원서', 'job': '데이터 분석'},
    {'title': 'AI 엔지니어 지원서', 'job': 'AI 개발'},
    {'title': '서비스 기획 직무 지원서', 'job': '서비스 기획'},
  ];

  // 디자인을 확인할 때만 쓰는 샘플 회차. 날짜는 최신순이다.
  static const _interviews = <String, List<String>>{
    '데이터 분석 직무 지원서': ['11월 22일 10:12', '11월 21일 20:41'],
    'AI 엔지니어 지원서': ['11월 20일 18:05'],
  };

  static const _questions = [
    '팀 프로젝트에서 맡은 역할은 무엇이었나요?',
    '프로젝트 결과가 잘 나왔는지 어떻게 확인했나요?',
    '팀원과 의견이 달랐을 때 어떻게 해결했나요?',
  ];

  static const _answers = [
    '팀 프로젝트에서 데이터 정리와 검증을 맡았습니다.',
    '같은 기준으로 두 가지 방법을 비교해 결과를 확인했습니다.',
    '각 방법의 장단점을 적어 두고 팀원들과 함께 비교했습니다.',
  ];

  static const _feedbacks = [
    '맡은 역할이 명확해요. 어떤 기준으로 데이터를 정리했는지와 그 결과를 한 문장씩 덧붙여 보세요.',
    '비교했다는 점은 좋아요. 사용한 지표와 두 방법의 차이를 설명해 보세요.',
    '의견을 비교한 과정이 드러나요. 팀이 어떤 결정을 내렸는지도 말해 보세요.',
  ];

  final TextEditingController _textController1 = TextEditingController();//내 답변 입력칸

  // 사용이 끝난 컨트롤러는 dispose()
  @override
  void dispose() {
    _textController1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: const Text(
          "면접 연습",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('저장한 자소서'),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _resumes.length,
                  itemBuilder: (context, index) {
                    final resume = _resumes[index];
                    final title = resume['title']!;
                    final job = resume['job']!;

                    return _tile(
                      ListTile(
                        title: Text(title),
                        subtitle: Text(job),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  _feedbackListScreen(context, title, job),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _feedbackListScreen(BuildContext context, String title, String job,){
    //면접기록 없으면 []
    final interviews = _interviews[title] ?? const <String>[];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: const Text(
          "면접 연습 기록",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //상단에 현재 선택한 자소서 타일
              _tile(ListTile(title: Text(title), subtitle: Text(job))),
              const SizedBox(height: 8),
              const Text('지난 연습'),
              const SizedBox(height: 8),
              if (interviews.isEmpty)
                const Text('아직 면접 연습 기록이 없어요.')
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: interviews.length,
                    itemBuilder: (context, index) {
                      final date = interviews[index];

                      return _tile(
                        ListTile(
                          title: Text(date),
                          subtitle: Text(job),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    _feedbackRecordScreen(title, date),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
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
                onPressed: () {
                  _textController1.clear();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => _interviewPracticeScreen(title)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '새 면접 연습',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //아이템타일? 모양 통일
  Widget _tile(Widget child) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  //피드백결과기록확인창
  Widget _feedbackRecordScreen(String title, String date){
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: const Text(
          "면접 피드백",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 위쪽에 선택한 자소서 제목과 면접 날짜를 표시한다.
              _tile(ListTile(title: Text(title), subtitle: Text(date),)),

              const SizedBox(height: 8),
              const Text('피드백 내용'),
              const SizedBox(height: 8),

              // 남은 공간에 질문 카드를 띄운다.
              Expanded(
                child: ListView.builder(
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    // 같은 번호의 질문, 답변, 피드백을 가져온다.
                    final question = _questions[index];
                    final answer = _answers[index];
                    final feedback = _feedbacks[index];

                    //AI
                    return _tile(
                      ExpansionTile(
                        initiallyExpanded: index == 0,
                        title: Text('질문 ${index + 1}'),
                        subtitle: Text(question),
                        childrenPadding: const EdgeInsets.all(14),
                        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            '내 답변',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          SelectableText(answer),
                          const SizedBox(height: 12),
                          const Text(
                            '예시 피드백',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          SelectableText(feedback),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _interviewPracticeScreen(String title){
    int index = 0;
    bool showFeedback = false;

    return StatefulBuilder(
      builder: (context, setPracticeState) {
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            backgroundColor: Colors.white,
            scrolledUnderElevation: 0,
            title: const Text(
              "면접 연습",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(height: 8),
                //현재질문번호 / 전체질문개수
                _tile(ListTile(title: Text('질문 ${index + 1} / ${_questions.length}'), subtitle: Text(_questions[index]),),),
                const SizedBox(height: 8),
                const Text('내 답변', style: TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(height: 8),
                TextField(
                  controller: _textController1,
                  //피드백 오면 더이상 답변 입력 x
                  readOnly: showFeedback,
                  minLines: 6,
                  maxLines: 12,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: '여기에 답변을 입력하세요',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                //피드백 들어오면 하단에 표시
                if (showFeedback)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '예시 피드백',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      SelectableText(_feedbacks[index]),
                    ],
                  ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
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
                    onPressed: () {
                      //피드백 보기 전에는 내 답변 있을때만 진행
                      if (!showFeedback) {
                        if (_textController1.text.trim().isEmpty) return;

                        setPracticeState(() {
                          showFeedback = true;
                        });
                        return;
                      }

                      // 마지막 질문의 피드백을 보고 연습 끝내기.
                      if (index == _questions.length - 1) {
                        Navigator.pop(context);
                        return;
                      }

                      // 답변 칸을 비우고 다음 질문을 보여준다.
                      _textController1.clear();
                      setPracticeState(() {
                        index++;
                        showFeedback = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      !showFeedback ? '예시 피드백 보기' : (index == _questions.length - 1 ? '연습 끝내기' : '다음 질문'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
