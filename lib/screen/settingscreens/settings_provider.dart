import 'package:flutter/foundation.dart';
import 'package:group_project/data/user_data.dart';
import 'settings_storage.dart';
//main.dart에서는 ChangeNotifierProvider(create: (_) => SettingsProvider()..load(), child: MyApp())으로 감싸면 됩니다.
// (provider 패키지를 pubspec.yaml에 추가해야 사용 가능. 지금은 settings_screen에서 SettingsStorage를 직접 사용)

class SettingProvider extends ChangeNotifier{
  final _storage = SettingsStorage();
  UserSettings settings = const UserSettings();
  Future<void> load() async {
    settings = await _storage.load();
    notifyListeners(); //앱시작시 호출
  }

  Future<bool> update(UserSettings next) async{
    final ok = await _storage.save(next);
    if (!ok) return false;                  // 실패하면 메모리는 그대로
    settings = next;
    notifyListeners();
    return true;
  }



  Future<void> logout() => _storage.clearLoginInfo();

  }
