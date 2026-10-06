import 'package:flutter/material.dart';
import 'package:group_project/data/schedule.dart';

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
    static const double cellHeight = 68;

    //TODO: 이 예시 데이터 대신 ScheduleStorage로 '이 사용자'의 일정을 불러올 예정
    static final List<ScheduleItem> _sampleSchedules = [
        ScheduleItem(id: '1', title: '삼성전자 서류 마감', company: '삼성', date: DateTime(2026, 9, 12)),
        ScheduleItem(id: '2', title: 'LG전자 1차 면접', company: 'LG그룹', date: DateTime(2026, 9, 20)),
    ];

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
                            _buildCalendarCard(),
                            const SizedBox(height: 18),
                            _buildLegend(),
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
                    _buildDateGrid(),
                    _buildFooter(),
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
    Widget _buildDateGrid() {
        final DateTime firstDay = DateTime(year, month, 1);
        final int leadingDays = firstDay.weekday % 7;
        final int daysInMonth = DateTime(year, month + 1, 0).day;
        final int rowCount = ((leadingDays +daysInMonth) / 7).ceil();

        return Column(
            children: [
                for (int row = 0; row < rowCount; row++)
                    Row(
                        children: [
                            for (int col = 0; col< 7; col++)
                                Expanded(
                                    child: _buildDayCell(DateTime(year, month, 1 - leadingDays + row * 7 + col), col),
                                ),
                        ],
                    ),
                ],
        );
    }
    Widget _buildDayCell(DateTime day, int col) {
        final bool isOutside = day.month != month;
        final List<ScheduleItem> events = _sampleSchedules
            .where((s) => s.date.year == day.year && s.date.month == day.month && s.date.day == day.day)
            .toList();

        //날짜 숫자 색
        Color numberColor;
        if (isOutside) {
            numberColor = const Color(0xFFB3B8C0);
        } else if (col == 0) {
            numberColor = kSunday;
        } else if (col == 6) {
                    numberColor = kSaturday;
        } else {
            numberColor = const Color(0xFF222222);
        }

        return Container(
            height: cellHeight,
            padding: const EdgeInsets.fromLTRB(6, 8, 4, 4),
            decoration: BoxDecoration(
                color: isOutside ? kOutsideBg: Colors.white,
                border: Border(
                    right: col < 6 ? const BorderSide(color: kGridLine) : BorderSide.none,
                    bottom: const BorderSide(color: kGridLine),
                ),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text('${day.day}', style: TextStyle(fontSize: 14, color: numberColor)),
                    const SizedBox(height: 4),
                    if (events.isNotEmpty) _buildEventChip(events.first),
                    ],
                ),
            );
        }

        Widget _buildEventChip(ScheduleItem e) {
            final Color color = companyColor(e.company,);
            return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                decoration: BoxDecoration(
                    color: color.withAlpha(28),
                    borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                    children: [
                        Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                            child: Text(
                                e.company,
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
                            ),
                        ),
                    ],
                ),
            );
        }

        Widget _buildFooter() {
            return Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Row(
                    children: [
                        const Expanded(
                            child: Text(
                                '주요 그룹 채용 일정을 한눈에 확인하세요.',
                                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                            ),
                        ),
                        Text(
                            '$year. ${month.toString().padLeft(2, '0')} 기준',
                            style: const TextStyle(fontSize: 11, color: Color(0xFFA0A6B0)),
                        ),
                    ],
                ),
            );
        }

        Widget _buildLegend() {
            return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    for (final entry in kCompanyColors.entries) ...[
                        Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: entry.value, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(entry.key, style: const TextStyle(fontSize: 13, color: Color(0xFF3A3F48))),
                        const SizedBox(width: 18),
                    ],
                    Container(width: 1, height: 14, color: kGridLine),
                    const SizedBox(width: 18),
                    const Text('월간 보기', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                ],
            );
        }
}