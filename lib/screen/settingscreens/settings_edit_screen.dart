import 'package:flutter/material.dart';
import 'add_chip_dialog.dart';
import 'package:group_project/data/user_data.dart';
//widget selectedChip, addChip,sectionTitle, style button들로 기존 버튼들을 몇몇 widget으로 뭉쳣습니다.
//
class SettingsEditScreen extends StatefulWidget{
  final UserData ud;
  const SettingsEditScreen({super.key, required this.ud});
  @override
  State<SettingsEditScreen> createState() => _SettingEditScreenState();
}
class _SettingEditScreenState extends State<SettingsEditScreen> {
  static const _blue = Color(0xFF1F5ADD);
  static const _lightGrey = Color(0xFFF2F3F5);
  static const _borderGrey = Color(0xFFE5E7EB); // 색깔코드들 변수들로 통합해부림
  late FeedbackStyle _style;
  bool _saving = false;
  late List<String> _jobs;
  late List<String> _companies;
  Future<void> _addJob() async {
    final v = await showAddChipDialog(context, '관심 직군 추가');
    if (v != null && v.isNotEmpty && !_jobs.contains(v)) setState(() => _jobs.add(v));
  }

  Future<void> _addCompany() async {
    final v = await showAddChipDialog(context, '관심 기업 추가');
    if (v != null && v.isNotEmpty && !_companies.contains(v)) setState(() => _companies.add(v));
  }

  void _resetJobs() {
    // jabcategory와 연결
  }
  @override
  void initState(){
    super.initState();
    final s = widget.ud.userSettings;
    _style = s.feedbackStyle;
    _jobs = [...s.jobs];
    _companies = [...s.companies];
  }
  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true); // 두 번 누릴때, 두번 실행하는 것 을 방지합니다. 누군가 백퍼 두번 누른다. 이런걸로 점수까이면 나 정말 억울해
    widget.ud.userSettings = widget.ud.userSettings.copyWith(
      feedbackStyle: _style,
      jobs: _jobs,
      companies: _companies,
    );
    await UserManager.save();
    if (!mounted) return;
    Navigator.pop(context, true);
  }
  Widget _styleButton(FeedbackStyle f) {
    final selected = _style == f;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _style = f),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.black : _lightGrey,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            f.label,
            style: TextStyle(
              fontSize: 14,
              color: selected ? Colors.white : Colors.black87,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
  Widget _sectionTitle(String title, {int? count, Widget? trailing}) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        if (count != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: _lightGrey, borderRadius: BorderRadius.circular(10)),
            child: Text('$count', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
        ],
        const Spacer(),
        if (trailing != null) trailing,
      ],
    );
  }
  Widget _addChip(VoidCallback onTap) {
    return ActionChip(
      label: const Text('+ 추가'),
      labelStyle: const TextStyle(color: Colors.black54, fontSize: 13),
      backgroundColor: Colors.white,
      side: const BorderSide(color: _borderGrey),
      shape: const StadiumBorder(),
      onPressed: onTap,
    );
  }
  Widget _selectedChip(String text, VoidCallback onRemove) {
    return InputChip(
      avatar: const Icon(Icons.check, size: 16, color: _blue),
      label: Text(text),
      labelStyle: const TextStyle(color: _blue, fontSize: 13, fontWeight: FontWeight.w600),
      backgroundColor: Colors.white,
      side: const BorderSide(color: _blue),
      shape: const StadiumBorder(),
      deleteIcon: const Icon(Icons.close, size: 14),
      deleteIconColor: _blue,
      onDeleted: onRemove,
    );
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('설정 변경', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _sectionTitle('피드백 스타일'),
          const SizedBox(height: 12),
          Row(children: [
            _styleButton(FeedbackStyle.soft),
            const SizedBox(width: 8),
            _styleButton(FeedbackStyle.normal),
            const SizedBox(width: 8),
            _styleButton(FeedbackStyle.strict),
          ]),
          const SizedBox(height: 32),

          _sectionTitle(
            '관심 직군',
            count: _jobs.length,
            trailing: TextButton(
              onPressed: _resetJobs,
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: const Text('관심 직군 재설정', style: TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final j in _jobs) _selectedChip(j, () => setState(() => _jobs.remove(j))),
            _addChip(_addJob),
          ]),
          const SizedBox(height: 32),

          _sectionTitle('관심 기업'),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final c in _companies) _selectedChip(c, () => setState(() => _companies.remove(c))),
            _addChip(_addCompany),
          ]),


        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: _saving ? null : _save,
              style: OutlinedButton.styleFrom(
                foregroundColor: _blue,
                side: const BorderSide(color: _blue),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('저장', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    );
  }

}
