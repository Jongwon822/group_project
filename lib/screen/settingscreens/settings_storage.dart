import 'package:shared_preferences/shared_preferences.dart';
import 'package:group_project/data/user_data.dart';


class SettingsStorage {
  Future<userData> load() async { //값 불러오기
    final p = await SharedPreferences.getInstance();
    final idx = p.getInt('feedbackStyle') ?? 0;
    return userData(
      email: p.getString('email') ?? '',//초기값
      feedbackStyle: FeedbackStyle.values[idx],
      jobs: p.getStringList('jobs') ?? [],//초기값
      companies: p.getStringList('companies') ?? [],//초기값 빼면 오류남
    );
  }

  Future<bool> save(userData s) async {
    try {
      final p = await SharedPreferences.getInstance();
      final results = await Future.wait([
        p.setInt('feedbackStyle', s.feedbackStyle.index),
        p.setStringList('jobs', s.jobs),
        p.setStringList('companies', s.companies),
      ]);
      return results.every((r) => r);   // 하나라도 false면 실패
    } catch (_) {
      return false;
    }

  }


  Future<void> clearLoginInfo() async { // 로그아웃
    final p = await SharedPreferences.getInstance();
    await p.remove('autoLogin');
    await p.remove('authToken');
  }
}