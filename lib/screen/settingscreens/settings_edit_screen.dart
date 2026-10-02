import 'package:flutter/material.dart';
import 'settings_storage.dart';
import 'add_chip_dialog.dart';
import 'package:group_project/data/user_data.dart';
class SettingsEditScreen extends StatefulWidget{
  final UserSettings initial;
  const SettingsEditScreen({super.key, required this.initial});
  @override
  State<SettingsEditScreen> createState() => _SettingEditScreenState();
}
class _SettingEditScreenState extends State<SettingsEditScreen> {
  final _storage = SettingsStorage();
  late FeedbackStyle _style;
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
    // TODO: 완전히 새로 선택: job_category_select.dart 화면이 완성되면 그 화면으로 이동
  }
  @override
  void initState(){
    super.initState();
    final s = widget.initial;
    _style = s.feedbackStyle;
    _jobs = [...s.jobs];
    _companies = [...s.companies];
  }
  Future<void> _save() async {
    final next = widget.initial.copyWith(
      feedbackStyle: _style,
      jobs: _jobs,
      companies: _companies,
    );
    final ok = await _storage.save(next);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, next);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장하지 못했어요. 다시 시도해 주세요.')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정 변경')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('피드백 스타일'),
          const SizedBox(height: 8),
          SegmentedButton<FeedbackStyle>(
            segments: [
              for (final f in FeedbackStyle.values)
                ButtonSegment(value: f, label: Text(f.label)),
            ],
            selected: {_style},
            onSelectionChanged: (set) => setState(() => _style = set.first),
          ),
          const SizedBox(height: 24),
          Row(children: [
            const Text('관심 직군'),
            const Spacer(),
            TextButton(onPressed: _resetJobs, child: const Text('관심 직군 재설정')),
          ]),
          Wrap(spacing: 8, children: [
            for (final j in _jobs)
              InputChip(label: Text(j), onDeleted: () => setState(() => _jobs.remove(j))),
            ActionChip(label: const Text('+ 추가'), onPressed: _addJob),
          ]),
          const SizedBox(height: 24),
          const Text('관심 기업'),
          Wrap(spacing: 8, children: [
            for (final c in _companies)
              InputChip(label: Text(c), onDeleted: () => setState(() => _companies.remove(c))),
            ActionChip(label: const Text('+ 추가'), onPressed: _addCompany),
          ]),
          const SizedBox(height: 32),
          FilledButton(onPressed: _save, child: const Text('저장')),
        ],
      ),
    );
  }

}
