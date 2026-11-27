import 'package:material_ui/material_ui.dart';
import 'package:group_project/data/user_data.dart';
import 'package:group_project/screen/editing_screen.dart';
import 'package:group_project/screen/feedback_screen.dart';
import 'package:intl/intl.dart';
import 'package:group_project/screen/view_all_screen.dart';


// 이거 높이 조정할 일 있으면 주의해서 바꿔줘
// 위젯안에 위젯을 child로 계속 담다보니까 하나 고치면 나머지도 다 고쳐야됨!!

class HomeScreen extends StatelessWidget {

  final UserData ud;

  const HomeScreen({super.key, required this.ud});

  @override
  Widget build(BuildContext context) {
    // 홈 화면 내부에서만 상단 탭을 제어하도록 DefaultTabController로 감싸줌
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // 상단 AppBar
        appBar: AppBar(
          title: const Text(
            '앱 이름',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
          // 앱바 색상 변함 방지
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
        ),

        // 본문 내용 가로 리스트뷰 및 첨삭/피드백 이동 위젯
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    // 선택한 탭바는 검정 바탕에 흰 글씨, 선택되지 않은 탭바는 그 반대
                    isScrollable: true,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    splashFactory: NoSplash.splashFactory,

                    // 배경을 둥근 모양으로
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.black,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,

                    // 탭바 사이 여백
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                    tabAlignment: TabAlignment.start,

                    // 탭바 이름
                    tabs: const [
                      Tab(text: 'Jobs'),
                      Tab(text: 'Certs'),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 210, // 높이조정은 공고탭 생성 함수에 있는 리스트뷰랑 동시에 바꿔야 오류 안나니까 주의좀
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  // 스크롤을 통한 탭 이동을 막음
                  children: [
                    // 1번 탭 - 추천 공고 내용 (가로 리스트뷰 포함)
                    _buildAnnouncementTab(ud.ancList, context),
                    // 2번 탭 - 추천 자격증 내용 (아직 안만듬)
                    _buildCertificationTab(ud.certList, context),
                    // 임시로 해둔거고 추천공고 만드는 함수처럼 추가해줘야함
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 첨삭지원 페이지 이동 박스
              _buildContentTile(
                  Icons.description_outlined,
                  'Resume & Cover Letter Review',
                  'Get instant AI feedback to tailor your resume and cover letter for your target role.',
                  'Start Review',
                      () {
                    Navigator.push(
                      context, MaterialPageRoute(
                        builder: (context) => EditingScreen(ud: ud,),
                      ),
                    );
                  }
              ),

              // 면접지원 페이지 이동 박스.
              _buildContentTile(
                Icons.help_outline,
                'Interview Prep & Feedback',
                'Practice with tailored follow-up questions based on your profile and get scored feedback.',
                'Start Interview',
                    () {
                  Navigator.push(
                    context, MaterialPageRoute(
                      builder: (context) => FeedbackScreen(ud: ud),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 추천 공고 탭 전체 레이아웃
  Widget _buildAnnouncementTab(List<Announcement> ancList, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단 타이틀 영역 (추천 취업 공고 / 자세히 보기)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recommended Jobs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context, MaterialPageRoute(
                    builder: (context) => DetailScreen(ud: ud, type: 'anc'),
                  ),
                  );
                },
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 모바일 최소 터치영역(48px) 때문에 높이 넘치는 것 방지
                ),
                child: const Text(
                  'view all',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            ],
          ),
        ),

        // 가로 스크롤로 넘기는 리스트뷰 영역
        SizedBox(
          height: 155,
          child: ListView.builder(
            scrollDirection: Axis.horizontal, // 가로로 넘기기
            itemCount: ancList.isEmpty
                ? 1 // 비어있으면 '추천 공고 없음' 박스 하나 출력할 예정
                : ancList.length, // ancList에 저장된 공고 개수
            padding: const EdgeInsets.only(left: 16),
            itemBuilder: (context, index) {
              if (ancList.isEmpty) {
                return Container(
                  width: MediaQuery.of(context).size.width-32,
                  height: 155,
                  alignment: Alignment.center,
                  child: const Text('No jobs found', style: TextStyle(color: Colors.grey)),
                );
              } else {
                return _buildAncDetailBox(
                  ancList[index],
                ); // 추천 공고 리스트로 박스를 순차적으로 생성
              }
            },
          ),
        ),
      ],
    );
  }

  // 추천공고가 들어갈 박스 위젯 만드는 함수
  Widget _buildAncDetailBox(Announcement anc) {
    return Container(
      // 전체 박스 모양 잡기
      width: 270,
      margin: const EdgeInsets.only(right: 14, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        // 박스 안에 세로로 내용 배치
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            anc.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${DateFormat('MM/dd').format(anc.startPeriod)}~${DateFormat('MM/dd').format(anc.endPeriod)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 24,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            anc.target,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 추천 자격증 탭 전체 레이아웃
  Widget _buildCertificationTab(List<Certification> certList, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단 타이틀 영역 (추천 자격증 / 자세히 보기)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recommended Certs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context, MaterialPageRoute(
                    builder: (context) => DetailScreen(ud: ud, type: 'cert'),
                  ),
                  );
                },
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 모바일 최소 터치영역(48px) 때문에 높이 넘치는 것 방지
                ),
                child: const Text(
                  'view all',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            ],
          ),
        ),

        // 가로 스크롤로 넘기는 리스트뷰 영역
        SizedBox(
          height: 155,
          child: ListView.builder(
            scrollDirection: Axis.horizontal, // 가로로 넘기기
            itemCount: certList.isEmpty
                ? 1 // 비어있으면 '추천 공고 없음' 박스 하나 출력할 예정
                : certList.length, // ancList에 저장된 공고 개수
            padding: const EdgeInsets.only(left: 16),
            itemBuilder: (context, index) {
              if (certList.isEmpty) {
                return Container(
                  width: MediaQuery.of(context).size.width-32,
                  height: 155,
                  alignment: Alignment.center,
                  child: const Text('No certification found', style: TextStyle(color: Colors.grey)),
                );
              } else {
                return _buildCertDetailBox(
                  certList[index],
                ); // 추천 공고 리스트로 박스를 순차적으로 생성
              }
            },
          ),
        ),
      ],
    );
  }

  // 추천 자격증이 들어갈 박스 위젯 만드는 함수
  Widget _buildCertDetailBox(Certification anc) {
    return Container(
      // 전체 박스 모양 잡기
      width: 270,
      margin: const EdgeInsets.only(right: 14, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        // 박스 안에 세로로 내용 배치
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            anc.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '자격증에 뭐 넣을까?',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 24,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '자격증에 뭐 넣을까?',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }







  // 첨삭하기랑 피드백하기 전용 위젯 만드는 함수
  Widget _buildContentTile(
      IconData icon,
      String title,
      String content,
      String buttonText,
      VoidCallback onPressed,  //AI
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF4F46E5), size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEEF2FF),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    buttonText,
                    style: const TextStyle(
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF4F46E5),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
