import 'package:flutter/material.dart';
import 'package:group_project/data/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_storage.dart';
import 'settings_edit_screen.dart';

class SettingScreen extends StatefulWidget {
  final UserData ud;
  final VoidCallback logout;
  const SettingScreen({super.key, required this.ud, required this.logout});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final _storage = SettingsStorage();
  UserSettings _settings = const UserSettings();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final s = await _storage.load();
    if (!mounted) return;
    setState(() => _settings = s);
  }

  Future<void> _openEdit() async {
    final next = await Navigator.push<UserSettings>(
      context,
      MaterialPageRoute(builder: (_) => SettingsEditScreen(initial: _settings)),
    );
    if (next != null && mounted) setState(() => _settings = next);
  }

  @override
  Widget build(BuildContext context) {
    final s = _settings;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: const Text(
          '설정',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFFE4EEFF),
                foregroundColor: const Color(0xFF1F5ADD),
                child: Text(
                  widget.ud.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),

              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.ud.id,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    title: const Text('AI 설정'),
                    subtitle: const Text('피드백 스타일'),
                    trailing: Text(s.feedbackStyle.label),
                  ),
                ),
                Card(
                  child: Column(children: [
                    const ListTile(title: Text('나의 정보')),
                    ListTile(title: const Text('관심 직군'), subtitle: Text(s.jobs.join(', '))),
                    ListTile(title: const Text('관심 기업'), subtitle: Text(s.companies.join(', '))),
                  ]),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _openEdit,
                  child: const Text('설정 변경 →'),
                ),
              ],
            ),
          ),

          // onPressed 부분 함수는 유지해줘야해
          TextButton(
            onPressed: () {
              _deleteAutoLogin();
              widget.logout();
            },
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
            ),
            child: const Text(
              "로그 아웃",
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 로그아웃이 시 저장해 둔 자동로그인 정보 삭제
  void _deleteAutoLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('autoLogin', false);
    prefs.remove('id');
  }
}
