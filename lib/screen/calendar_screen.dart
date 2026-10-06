import 'package:flutter/material.dart';

const Color kNavy = Color(0xFF243A66); //요일 줄 배경색, 연/월 글자색
const Color kSunday = Color(0xFFB04A5A); //일요일 날짜 글자색
const Color kSaturday = Color(0xFF3F5BA9); // 토요일 날짜 글자색, 상단 영문 제목 색
const Color kGridLine = Color(0xFFE3E6EC); // 날짜 칸 테두리 색
const Color kOutsideBg = Color(0xFFF7F8FA); //지난달, 다음달 날짜 칸 배경색
const Color kPageBg = Color(0xFFF5F6F8); // 화면 전체 배경색

//기업 그룹별 색깔
const Map<String, Color> kCompanyColors = {
    '삼성': Color(0xFF3F5BA9),
    'LG그룹': Color(0xFF8A2E45),
};

//기업 이름으로 색깔 찾기
Color companyColor(String company) => kCompanyColors[company] ?? Colors.grey;

class CalendarScreen extends StatelessWidget {
    //TODO: 사용자마다 일정을 따로 저장하기 위해 로그인한 사용자 id를 받을 예정
    const CalendarScreen({super.key});

    static const int year = 2026; //화면에 보여줄 연도
    static const int month = 9; // 화면에 보여줄 달

    @override
    Widget build(BuildContext context) {
        return Container(
            width: double.infinity,
            height: double.infinity,
            color: kPageBg,
            child: SafeArea(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                        children: [
                            _buildCalendarCard()
                            ],
                        ),
                    ),
                ),
            );
        }
    Widget _buildCalendarCard() {
        return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                color:Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                    BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, 6)),
                ],
            ),
            child: Column(
                children: [
                    _buildHeader(),
                    _buildWeekdayRow(),
                ],
            ),
        );
    }
    Widget _buildHeader() {
        return Padding(
            padding: const EdgeInsets.fromLTRB(12, 24, 12, 20),
            child: Column(
                children: [
                    const Text(
                        'RECRUITMENT CALENDAR',
                        style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 2.5,
                            color: kSaturday,
                            fontWeight: FontWeight.w500,
                        ),
                    ),
                const SizedBox(height: 8),
                Row(
                    children: [
                        const Icon(Icons.chevron_left, size: 32, color: kNavy),
                        Expanded(
                            child: Text(
                                '$year년 $month월',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: kNavy),
                            ),
                        ),
                        const Icon(Icons.chevron_right, size: 32, color: kNavy),
                    ],
                ),
            ],
        ),
    );
}
    Widget _buildWeekdayRow() {
        const List<String> labels = ['일', '월', '화', '수', '목', '금', '토'];
        return Container(
            height: 44,
            color: kNavy,
            child: Row(
                children: [
                    for (int i = 0; i < 7; i++)
                        Expanded(
                            child: Center(
                                child: Text (
                                    labels[i],
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: i == 0 ? const Color(0xFFF2A7B3) : Colors.white,

                                ),
                            ),
                        ),
                    ),
                ],
            ),
        );
    }
}



