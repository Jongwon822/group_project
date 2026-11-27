import 'package:material_ui/material_ui.dart';
import 'package:group_project/data/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_edit_screen.dart';

// 데이터들 몽땅 ud로 통합시켯습니다. 이러면 provider와 storage파일은 필요없겟네요
// sectioncard로 카드틀 생성, infoRow로 카드내 글 생서함다
class SettingScreen extends StatefulWidget {
  final UserData ud;
  final VoidCallback logout;

  const SettingScreen({super.key, required this.ud, required this.logout});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

  bool _isDeleting = false;

  Widget _sectionCard(IconData icon, String title, List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF4F46E5), size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          ...rows,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool showTopBorder = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: showTopBorder
          ? const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
            )
          : null,
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not selected' : value,
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

  // 회원탈퇴 기능 구현
  Future<void> _confirmWithdraw() async {
    if (_isDeleting) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete your account?\nAll saved account data will be deleted.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'No',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Yes',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isDeleting = true;
    });

    await UserManager.delete(widget.ud.id);
    // main.dart의 _Logout()이 삭제된 문서를 다시 save()하지 않도록 로컬 세션 분리
    await UserManager.clearSavedSessionId();
    widget.ud.activeSessionId = '';
    await _deleteAutoLogin();

    if (!mounted) return;
    setState(() {
      _isDeleting = false;
    });

    widget.logout();
  }

  @override
  Widget build(BuildContext context) {
    final ud = widget.ud;
    final s = ud.userSettings;
    final displayName = ud.name.isNotEmpty
        ? //이름이 없으면 id로 대체하는 코드
        ud.name
        : ud.id; // 혹시 몰라 넣어둠
    final initial = displayName.isNotEmpty ? displayName[0] : '?';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey.shade200,
            height: 1,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(
            height: 4,
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFEEF2FF),
                foregroundColor: const Color(0xFF4F46E5),
                child: Text(initial,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(ud.id,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _sectionCard(Icons.auto_awesome, 'AI Settings', [
            _infoRow('Feedback Style', s.feedbackStyle.label),
          ]),
          const SizedBox(height: 12),
          _sectionCard(Icons.person_rounded, 'My Info', [
            _infoRow('Target Roles', s.jobs.join(', ')),
            _infoRow('Target Companies', s.companies.join(', ')),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _openEdit,
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFEEF2FF),
                elevation: 0,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Edit Settings',
                    style: TextStyle(
                        color: Color(0xFF4F46E5),
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF4F46E5),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          // onPressed 부분 함수는 유지해줘야해
          Center(
            child: TextButton(
              onPressed: () async {
                await _deleteAutoLogin();
                widget.logout();
              },
              child: const Text(
                "Log Out",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // 회원탈퇴 기능 구현
          Center(
            child: TextButton(
              onPressed: _isDeleting ? null : _confirmWithdraw,
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _isDeleting ? 'Deleting account...' : 'Delete Account',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 로그아웃이 시 저장해 둔 자동로그인 정보 삭제
  Future<void> _deleteAutoLogin() async {
    // void - > Future<void>로 수정
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoLogin', false);
    await prefs.remove('id');
  }
}
