import 'package:flutter/material.dart';
import 'package:group_project/data/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_edit_screen.dart';
// 데이터들 몽땅 ud로 통합시켯습니다. 이러면 provider와 storage파일은 필요없겟네요
// sectioncard로 카드틀 생성, infoRow로 카드내 글 생서함다
//저희 근데 설정란에 이메일 적는란 필요하나요? 내가 알기론 ID가 곧 email이긴한데
class SettingScreen extends StatefulWidget {
  final UserData ud;
  final VoidCallback logout;
  const SettingScreen({super.key, required this.ud, required this.logout});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  Widget _sectionCard(String title, List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value.isEmpty ? '선택 안 함' : value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }




  Future<void> _openEdit() async {
    final next = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => SettingsEditScreen(ud: widget.ud)),
    );
    if (next != null && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ud = widget.ud;
    final s = ud.userSettings;
    final displayName = ud.name.isNotEmpty ? //이름이 없으면 id로 대체하는 코드인데 필요할려나
        ud.name : ud.id;// 혹시 몰라 넣어둠
    final initial = displayName[0];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          '설정',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFE4EEFF),
                foregroundColor: const Color(0xFF1F5ADD),
                child: Text(initial, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(ud.id, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

                _sectionCard('AI 설정', [
                  _infoRow('피드백 스타일', s.feedbackStyle.label),
                ]),
                const SizedBox(height: 12),
                _sectionCard('나의 정보', [
                  _infoRow('관심 직군', s.jobs.join(', ')),
                  _infoRow('관심 기업', s.companies.join(', ')),
                ]),
                const SizedBox(height : 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _openEdit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1F5ADD),
                      side: const BorderSide(color: Color(0xFF1F5ADD)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('설정 변경 →', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),




          const SizedBox(height: 12),
          // onPressed 부분 함수는 유지해줘야해
          Center(
            child: TextButton(
              onPressed: () async {
                await _deleteAutoLogin();
                widget.logout();
              },

              child: const Text(
                "로그아웃",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),
            ),
          ),
          ),
        ],
      ),

    );
  }

  // 로그아웃이 시 저장해 둔 자동로그인 정보 삭제
  Future<void> _deleteAutoLogin() async {// void - > Future<void>로 수정
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoLogin', false);
    await prefs.remove('id');
  }
}
