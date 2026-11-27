import 'package:material_ui/material_ui.dart';
import 'package:group_project/data/schedule.dart';
import 'package:group_project/data/user_data.dart';
import 'package:group_project/screen/add_schedule_screen.dart';

// 달력을 StatefulWidget으로 바꾸는 구조, < > 버튼으로 달을 이동하는 기능(_changeMonth)
// 날짜 선택(_selectDay)과 선택한 날짜의 일정 목록, D-day 계산,
// + 버튼으로 일정 추가 화면 이동 후 사용자 데이터에 저장하는 기능(_openAddScreen),
// 일정 카드를 길게 눌러 삭제하는 기능(_confirmDelete) 작성에 AI(Claude) 사용

const Color kNavy = Color(0xFF243A66); //요일 줄 배경색, 연/월 글자색
const Color kSunday = Color(0xFFB04A5A); //일요일 날짜 글자색
const Color kSaturday = Color(0xFF3F5BA9); // 토요일 날짜 글자색, 상단 영문 제목 색
const Color kGridLine = Color(0xFFE3E6EC); // 날짜 칸 테두리 색
const Color kOutsideBg = Color(0xFFF7F8FA); //지난달, 다음달 날짜 칸 배경색
const Color kPageBg = Color(0xFFF5F6F8); // 화면 전체 배경색
const Color kSelectedBg = Color(0xFFEAF0FF);
const Color kDdayRed = Color(0xFFE5533D);

//기업 그룹별 색깔
const Map<String, Color> kCompanyColors = {
    '삼성': Color(0xFF3F5BA9),
    'LG그룹': Color(0xFF8A2E45),
    '기타': Color(0xFF6B7280),
};

//기업 이름으로 색깔 찾기
Color companyColor(String company) => kCompanyColors[company] ?? Colors.grey;
// 두 날짜가 같은 날인지 비교 (시간은 무시하고 연/월/일만)
bool isSameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class CalendarScreen extends StatefulWidget {
    final UserData ud;
    const CalendarScreen({super.key, required this.ud});

    @override
    State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
    static const double cellHeight = 68;

    late DateTime _focusedMonth;
    late DateTime _selectedDay;

    // 처음 화면이 뜰 때 이번 달을 보여주도록 설정
    @override
    void initState() {
        super.initState();
        final DateTime now = DateTime.now();
        _focusedMonth = DateTime(now.year, now.month, 1);
        _selectedDay = DateTime(now.year, now.month, now.day);
    }

    // < > 버튼을 누르면 이전 달 또는 다음 달로 이동
    void _changeMonth(int offset) {
        setState(() {
            _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + offset, 1);
        });
    }
    // 특정 날짜의 일정만 골라내기
    List<ScheduleItem> _eventsOf(DateTime day) {
        return widget.ud.scheduleList.where((s) => isSameDate(s.date, day)).toList();
    }

    // 날짜 칸을 누르면 그 날짜를 선택하고, 다른 달 날짜면 그 달로 이동
    void _selectDay(DateTime day) {
        setState(() {
            _selectedDay = day;
            if (day.month != _focusedMonth.month || day.year != _focusedMonth.year) {
                _focusedMonth = DateTime(day.year, day.month, 1);
            }
        });
    }

    // + 버튼을 누르면 일정 추가 화면으로 이동하고, 저장해서 돌아오면 내 일정에 추가
    Future<void> _openAddScreen() async {
        final ScheduleItem? newItem = await Navigator.push<ScheduleItem>(
            context,
            MaterialPageRoute(builder: (_) => AddScheduleScreen(
                                                initialDate: _selectedDay,
                                                companyColors: widget.ud.companyColors,
                                              ),
                                              ),
        );
        if (newItem == null) return;
        widget.ud.scheduleList.add(newItem);
        await UserManager.save();
        if (!mounted) return;
        setState(() {
            _selectedDay = newItem.date;
            _focusedMonth = DateTime(newItem.date.year, newItem.date.month, 1);
        });
    }
    // 일정 카드를 길게 누르면 확인 창을 띄우고, 삭제를 누르면 내 일정에서 지우기
    Future<void> _confirmDelete(ScheduleItem e) async {
        final bool? ok = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
                title: const Text('일정 삭제'),
                content: Text('"${e.title}" 일정을 삭제할까요?'),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('취소'),
                    ),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('삭제', style: TextStyle(color: Colors.red)),
                    ),
                ],
            ),
        );
        if (ok != true) return;
        widget.ud.scheduleList.removeWhere((s) => s.id == e.id);
        await UserManager.save();
        if (!mounted) return;
        setState(() {});
    }

    // 오늘 기준 D-day 글자 만들기 (D-3, D-Day, D+2)
    String _dDayLabel(DateTime date) {
        final DateTime now = DateTime.now();
        final int diff = DateTime(date.year, date.month, date.day)
            .difference(DateTime(now.year, now.month, now.day))
            .inDays;
        if (diff == 0) return 'D-Day';
        return diff > 0 ? 'D-$diff' : 'D+${-diff}';
    }

    // 달력 카드, 범례, 선택한 날짜의 일정 목록, + 버튼으로 이루어진 화면 전체 그리기
    @override
    Widget build(BuildContext context) {
        final List<ScheduleItem> selectedEvents = _eventsOf(_selectedDay);

        return Scaffold(
            backgroundColor: kPageBg,
            body: SafeArea(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            _buildCalendarCard(),
                            const SizedBox(height: 18),
                            _buildLegend(),
                            const SizedBox(height: 22),
                            _buildSelectedDayTitle(selectedEvents.length),
                            const SizedBox(height: 10),
                            if (selectedEvents.isEmpty)
                                _buildEmptyBox()
                            else
                                ...selectedEvents.map(_buildScheduleCard),
                        ],
                    ),
                ),
            ),
            floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                onPressed: _openAddScreen,
                child: const Icon(Icons.add),
            ),
        );
    }

    Widget _buildCalendarCard() {
        return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                color: Colors.white,
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
                        IconButton(
                            onPressed: () => _changeMonth(-1),
                            icon: const Icon(Icons.chevron_left, size: 32, color: kNavy),
                        ),
                        Expanded(
                            child: Text(
                                '${_focusedMonth.year}년 ${_focusedMonth.month}월',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: kNavy),
                            ),
                        ),
                        IconButton(
                            onPressed: () => _changeMonth(1),
                            icon: const Icon(Icons.chevron_right, size: 32, color: kNavy),
                        ),
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
        final int year = _focusedMonth.year;
        final int month = _focusedMonth.month;
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
        final bool isOutside = day.month != _focusedMonth.month;
        final bool isSelected = isSameDate(day, _selectedDay);
        final bool isToday = isSameDate(day, DateTime.now());
        final List<ScheduleItem> events = _eventsOf(day);

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

        Color cellColor = Colors.white;
        if (isSelected) {
            cellColor = kSelectedBg;
        } else if (isOutside) {
            cellColor = kOutsideBg;
        }

        return GestureDetector(
            onTap: () => _selectDay(day),
            child: Container(
                height: cellHeight,
                padding: const EdgeInsets.fromLTRB(6, 8, 4, 4),
                decoration: BoxDecoration(
                    color: cellColor,
                    border: Border(
                        right: col < 6 ? const BorderSide(color: kGridLine) : BorderSide.none,
                        bottom: const BorderSide(color: kGridLine),
                    ),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                            '${day.day}',
                            style: TextStyle(
                                fontSize: 14,
                                color: numberColor,
                                fontWeight: (isSelected || isToday) ? FontWeight.w800 : FontWeight.w400,
                                decoration: isToday ? TextDecoration.underline : null,
                            ),
                        ),
                        const SizedBox(height: 4),
                        if (events.isNotEmpty) _buildEventChip(events.first),
                        if (events.length > 1)
                            Text('+${events.length - 1}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                    ],
                ),
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
                            '${_focusedMonth.year}. ${_focusedMonth.month.toString().padLeft(2, '0')} 기준',
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
                ],
            );
        }
    // 선택한 날짜 제목 그리기
    Widget _buildSelectedDayTitle(int count) {
        const List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];
        final DateTime d = _selectedDay;
        return Text(
            '${d.month}월 ${d.day}일 (${weekdays[d.weekday - 1]})  ·  일정 $count개',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kNavy),
        );
    }

    // 선택한 날짜에 일정이 없을 때 안내 상자 그리기
    Widget _buildEmptyBox() {
        return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kGridLine),
            ),
            child: const Text(
                '일정이 없어요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
            ),
        );
    }

    // 달력 아래 일정 카드 1개 그리기
    Widget _buildScheduleCard(ScheduleItem e) {
        final Color color = companyColor(e.company);
        return GestureDetector(
            onLongPress: () => _confirmDelete(e),
            child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kGridLine),
                ),
                child: Row(
                    children: [
                        Container(
                            width: 4,
                            height: 36,
                            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text(e.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 3),
                                    Text(e.company, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                ],
                            ),
                        ),
                        Text(
                            _dDayLabel(e.date),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: kDdayRed),
                        ),
                    ],
                ),
            ),
        );
    }
}