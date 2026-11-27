import 'package:material_ui/material_ui.dart';
import 'package:group_project/data/schedule.dart';
import 'package:group_project/screen/calendar_screen.dart';
// 기업 색으로 고를 수 있는 색 6개
const List<int> kColorPalette = [
  0xFFE5533D,
  0xFFF59E0B,
  0xFF16A34A,
  0xFF2563EB,
  0xFF7C3AED,
  0xFFDB2777,
];

// 제목 입력, 기업 선택, 날짜 선택, 저장 버튼에서 AI 사용함
// 기업 이름 입력과 색 선택, 기존 기업 색 자동 선택,
// 날짜 선택 팝업, 저장 후 달력 화면으로 값 돌려주기 작성에 AI 사용함

class AddScheduleScreen extends StatefulWidget {
    final DateTime initialDate;
    // 달력 화면의 UserData에 있는 것을 그대로 받음
    final Map<String, int> companyColors;
    const AddScheduleScreen({super.key, required this.initialDate, required this.companyColors});

    @override
    State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
    final TextEditingController _titleController = TextEditingController();
    // 기업 이름 입력칸
    final _companyController = TextEditingController();
    // 지금 선택된 색
    int _colorValue = kColorPalette.first;
    late DateTime _date;

    // 달력에서 선택해 둔 날짜를 기본 날짜로 설정
    @override
    void initState() {
        super.initState();
        _date = widget.initialDate;
    }

    // 화면이 닫힐 때 입력칸 정리
    @override
    void dispose() {
        _titleController.dispose();
        _companyController.dispose();
        super.dispose();
    }

    // 달력 팝업을 띄워서 날짜 고르기
    Future<void> _pickDate() async {
        final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _date,
            firstDate: DateTime(2020, 1, 1),
            lastDate: DateTime(2030, 12, 31),
        );
        if (picked == null) return;
        setState(() => _date = picked);
    }
    // 이미 색이 정해진 기업이면 그 색을 자동으로 선택
    void _onCompanyChanged(String text) {
      final saved = widget.companyColors[text.trim()];
        if (saved != null) {
          setState(() => _colorValue = saved);
        }
    }

    // 입력한 내용으로 새 일정을 만들어 달력 화면에 돌려주기
      void _save() {
        final company = _companyController.text.trim();
        if (company.isNotEmpty) {
          widget.companyColors[company] = _colorValue;
        }
        final ScheduleItem item = ScheduleItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          company: company,
          date: DateTime(_date.year, _date.month, _date.day),
        );
        Navigator.pop(context, item);
      }
    // 제목 입력, 기업 선택, 날짜 선택, 저장 버튼으로 이루어진 화면 그리기
    @override
    Widget build(BuildContext context) {
        final bool canSave = _titleController.text.trim().isNotEmpty;
        const List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];

        return Scaffold(
            backgroundColor: kPageBg,
            appBar: AppBar(
                backgroundColor: kPageBg,
                title: const Text('일정 추가', style: TextStyle(fontWeight: FontWeight.w700, color: kNavy)),
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                ),
            ),
            body: SafeArea(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            const Text('일정 제목', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            TextField(
                                controller: _titleController,
                                autofocus: true,
                                decoration: const InputDecoration(
                                    hintText: '예) 삼성전자 서류 마감',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(),
                                ),
                                onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 24),

                            const Text('기업 그룹', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _companyController,
                              onChanged: _onCompanyChanged,
                              decoration: const InputDecoration(
                                labelText: 'Company',
                                hintText: 'e.g. Samsung, Naver',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text('Color'),
                            const SizedBox(height: 8),
                            _buildColorPicker(),
                            const SizedBox(height: 24),

                            const Text('날짜', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            InkWell(
                                onTap: _pickDate,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: kGridLine),
                                    ),
                                    child: Row(
                                        children: [
                                            const Icon(Icons.calendar_month, color: kNavy),
                                            const SizedBox(width: 10),
                                            Text(
                                                '${_date.year}년 ${_date.month}월 ${_date.day}일 (${weekdays[_date.weekday - 1]})',
                                                style: const TextStyle(fontSize: 15),
                                            ),
                                        ],
                                    ),
                                ),
                            ),
                            const SizedBox(height: 36),

                            SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: FilledButton(
                                    style: FilledButton.styleFrom(backgroundColor: kNavy),
                                    onPressed: canSave ? _save : null,
                                    child: const Text('저장', style: TextStyle(fontSize: 16)),
                                ),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
  // 기업 색 선택 동그라미 줄
  Widget _buildColorPicker() {
    return Wrap(
      spacing: 12,
      children: kColorPalette.map((value) {
        final selected = value == _colorValue;
        return GestureDetector(
          onTap: () => setState(() => _colorValue = value),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Color(value),
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? Colors.black : Colors.transparent,
                width: 3,
              ),
            ),
            child: selected
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : null,
          ),
        );
      }).toList(),
    );
  }
}