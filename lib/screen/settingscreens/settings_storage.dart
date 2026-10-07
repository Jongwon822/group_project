import 'package:shared_preferences/shared_preferences.dart';
import 'package:group_project/data/user_data.dart';


// 세팅을 유저데이터로 합쳐서 아래 클래스는 필요없음
// shared_preferences 말고 그냥 전체데이터를 json에 저장하는 방식으로 가는게 좋을 것 같음
// 관리하기 편하고 우리가 뭐 수백수천명 데이터 관리하는것도 아니니까 매번 읽고 써도 부담 없을듯
// 세팅값 수정 방법 예시
// (widget).ud.userSettings.feedbackStyle = FeedbackStyle.soft;
// (widget).ud.userSettings.jobs[index] = '직군명아무거나' 이런 방식으로 넣어줘
// 여기서 ud는 세팅스크린이 main_navigation에서 넘겨받는 로그인한 사용자의 UserData야
// 그리고 반드시 수정사항이 발생한 경우 UserManager.save();를 해줘야해
// 매번 save() 적기 귀찮으면 user_data.dart에 UserManager class에다가 값을 조작하는 함수 만들어서 써도 죄
// + userSettings.email이랑 ud.id랑 같은 값이라 합칠 때 없앴음

class SettingsStorage {
  Future<UserSettings> load() async { //값 불러오기
    final p = await SharedPreferences.getInstance();
    final idx = p.getInt('feedbackStyle') ?? 0;
    return UserSettings(
      feedbackStyle: FeedbackStyle.values[idx],
      jobs: p.getStringList('jobs') ?? [],//초기값
      companies: p.getStringList('companies') ?? [],//초기값 빼면 오류남
    );
  }

  Future<bool> save(UserSettings s) async {
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


  // 이미 로그아웃 있음
  Future<void> clearLoginInfo() async { // 로그아웃
    final p = await SharedPreferences.getInstance();
    await p.remove('autoLogin');
    await p.remove('authToken');
  }
}
