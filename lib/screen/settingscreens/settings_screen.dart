import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_provider.dart';
import 'settings_edit_screen.dart';
import 'package:group_project/screen/login_screen.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await context.read<SettingProvider>().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false, // 뒤로가기로 돌아오지 못하게 스택 비움
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingProvider>().settings;
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(s.email),
          ),
          const SizedBox(height: 16),
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
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsEditScreen())),
            child: const Text('설정 변경 →'),
          ),
          TextButton(
            onPressed: () => _logout(context),
            child: const Text('로그아웃', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}



}
