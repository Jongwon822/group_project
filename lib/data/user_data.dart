import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:developer';

enum FeedbackStyle {
  soft('부드럽게', '격려하는 어조로, 좋은 점을 먼저 짚어 주세요.'),
  normal('보통', '균형 잡힌 어조로 피드백해 주세요.'),
  strict('꼼꼼하게', '약점을 구체적으로 지적하고 개선안을 제시해 주세요.');

  const FeedbackStyle(this.label, this.promptText);

  final String label;

  final String promptText; // AI 프롬프트에 그대로 붙임
}

class Announcement {
  final String title;
  final DateTime startPeriod;
  final DateTime endPeriod;
  final String target;

  Announcement(
      {required this.title,
      required this.startPeriod,
      required this.endPeriod,
      required this.target});

  // Map으로 변환
  Map<String, dynamic> toJson() => {
        'title': title,
        'startPeriod': startPeriod.toIso8601String(),
        'endPeriod': endPeriod.toIso8601String(),
        'target': target,
      };

  // Announcement로 변환
  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      title: json['title'],
      startPeriod: DateTime.parse(json['startPeriod']),
      endPeriod: DateTime.parse(json['endPeriod']),
      target: json['target'],
    );
  }
}

// 설정 화면에서 쓰는 값 (피드백 스타일, 관심 직군, 관심 기업)
class UserSettings {
  final bool firstSetting;
  final FeedbackStyle feedbackStyle;
  final List<String> jobs;
  final List<String> companies;

  const UserSettings({
    //이메일, 피드백 스타일, 직업, 회사 생성자
    this.firstSetting = true,
    this.feedbackStyle = FeedbackStyle.soft,
    this.jobs = const [],
    this.companies = const [],
  });

  UserSettings copyWith({
    bool? firstSetting,
    FeedbackStyle? feedbackStyle,
    List<String>? jobs,
    List<String>? companies,
  }) =>
      UserSettings(
        firstSetting: firstSetting ?? this.firstSetting,
        feedbackStyle: feedbackStyle ?? this.feedbackStyle,
        jobs: jobs ?? this.jobs,
        companies: companies ?? this.companies,
      );

  // Map으로 변환
  Map<String, dynamic> toJson() => {
        'firstSetting': firstSetting,
        'feedbackStyle': feedbackStyle.name,
        // enum 이름 저장 ('soft', 'normal', 'strict')
        'jobs': jobs,
        'companies': companies,
      };

  // UserSettings로 변환
  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      firstSetting: json['firstSetting'] as bool? ?? false,
      feedbackStyle: FeedbackStyle.values.firstWhere(
        (e) => e.name == json['feedbackStyle'],
        orElse: () => FeedbackStyle.soft, // 저장된 값이 없거나 일치하는게 없으면 soft
      ),
      jobs: List<String>.from(json['jobs'] ?? []),
      companies: List<String>.from(json['companies'] ?? []),
    );
  }
}

class UserData {
  final String id;
  final String password;
  String name;
  List<Announcement> ancList;
  UserSettings userSettings;

  UserData(
      {required this.id,
      required this.password,
      this.name = '',
      List<Announcement>? ancList,
      this.userSettings = const UserSettings()})
      : ancList = ancList ?? [];

  // Map으로 변환
  Map<String, dynamic> toJson() => {
        'id': id,
        'password': password,
        'name': name,
        'ancList': ancList.map((e) => e.toJson()).toList(),
        'userSettings': userSettings.toJson(),
      };

  // UserData로 변환
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      password: json['password'],
      name: json['name'] ?? '',
      ancList: json['ancList'] != null
          ? (json['ancList'] as List)
              .map((e) => Announcement.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      userSettings: json['userSettings'] != null
          ? UserSettings.fromJson(json['userSettings'])
          : const UserSettings(), // json에 값이 없어도 기본값으로
    );
  }
}

class UserManager {
  //전체 유저 데이터 리스트
  static List<UserData> uds = [];

  // ---- AI 사용 코드 ----
  // 파일 저장 경로를 반환하는 내부 private 메서드
  static Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/user_data.json'); // 파일경로는 나중에 정해주자
  }

  // --------------------

  // json파일에서 불러온 값을 uds에 저장
  static Future<void> load() async {
    try {
      final file = await _getLocalFile();
      // 파일이 없는 경우
      if (!await file.exists()) {
        uds = [];
        await save();
        return;
      }
      String jsonString = await file.readAsString();
      // 파일 내용이 비어있을 경우
      if (jsonString.trim().isEmpty) {
        uds = [];
        return;
      }
      List<dynamic> jsonList = jsonDecode(jsonString);

      // List<Map<String, dynamic>> 형태를 List<UserData>로 변환
      uds = jsonList
          .map((item) => UserData.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('load 실패, $e');
      uds = [];
    }
  }

  // uds 내용으로 json 파일 덮어쓰기
  static Future<void> save() async {
    try {
      final file = await _getLocalFile();

      // List<UserData> 형태를 List<Map<String, dynamic>>로 변환
      List<Map<String, dynamic>> jsonList =
          uds.map((user) => user.toJson()).toList();
      String jsonString = jsonEncode(jsonList);
      await file.writeAsString(jsonString);
    } catch (e) {
      log('save 실패, $e');
    }
  }

  // uds에 ud값 추가 (계정 추가)
  static Future<void> add(UserData ud) async {
    uds.add(ud);
    await save();
  }

  // uds에 ud값 제거 (계정 삭제)
  static Future<void> delete(String id) async {
    uds.removeWhere((ud) => ud.id == id);
    await save();
  }
}
