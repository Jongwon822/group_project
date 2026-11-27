import 'dart:developer';
import 'package:group_project/data/schedule.dart';
import 'dart:math' hide log;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum FeedbackStyle {
  soft('부드럽게', '격려하는 어조로, 좋은 점을 먼저 짚어 주세요.'),
  normal('보통', '균형 잡힌 어조로 피드백해 주세요.'),
  strict('꼼꼼하게', '약점을 구체적으로 지적하고 개선안을 제시해 주세요.');

  const FeedbackStyle(this.label, this.promptText);

  final String label;

  final String promptText; // AI 프롬프트에 그대로 붙임
}

// 공고 전용 class
class Announcement {
  final String id;
  final String title;
  final DateTime startPeriod;
  final DateTime endPeriod;
  final String target;

  Announcement(
      {required this.id,
      required this.title,
      required this.startPeriod,
      required this.endPeriod,
      required this.target});

  // Map으로 변환
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'startPeriod': startPeriod.toIso8601String(),
        'endPeriod': endPeriod.toIso8601String(),
        'target': target,
      };

  // Announcement로 변환
  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      title: json['title'],
      startPeriod: DateTime.parse(json['startPeriod']),
      endPeriod: DateTime.parse(json['endPeriod']),
      target: json['target'],
    );
  }
}

class Certification {
  final String id;
  final String title;

  Certification({
    required this.id,
    required this.title,
  });

  // Map으로 변환
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
      };

  // Announcement로 변환
  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      id: json['id'],
      title: json['title'],
    );
  }
}

// 설정 화면에서 쓰는 값 (피드백 스타일, 관심 직군, 관심 기업)
class UserSettings {
  final bool firstSetting;
  final FeedbackStyle feedbackStyle;
  final List<String> humanitiesJobs; // 문과 직군
  final List<String> scienceJobs; // 이과 직군
  final List<String> companies;

  // 문과 + 이과를 합친 목록 (읽기 전용)
  List<String> get jobs => [...humanitiesJobs, ...scienceJobs];

  const UserSettings({
    this.firstSetting = true,
    this.feedbackStyle = FeedbackStyle.soft,
    this.humanitiesJobs = const [],
    this.scienceJobs = const [],
    this.companies = const [],
  });

  UserSettings copyWith({
    bool? firstSetting,
    FeedbackStyle? feedbackStyle,
    List<String>? humanitiesJobs,
    List<String>? scienceJobs,
    List<String>? companies,
  }) =>
      UserSettings(
        firstSetting: firstSetting ?? this.firstSetting,
        feedbackStyle: feedbackStyle ?? this.feedbackStyle,
        humanitiesJobs: humanitiesJobs ?? this.humanitiesJobs,
        scienceJobs: scienceJobs ?? this.scienceJobs,
        companies: companies ?? this.companies,
      );

  // Map으로 변환
  Map<String, dynamic> toJson() => {
        'firstSetting': firstSetting,
        'feedbackStyle': feedbackStyle.name,
        'humanitiesJobs': humanitiesJobs,
        'scienceJobs': scienceJobs,
        'companies': companies,
      };

  // UserSettings로 변환
  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      firstSetting: json['firstSetting'] as bool? ?? false,
      feedbackStyle: FeedbackStyle.values.firstWhere(
        (e) => e.name == json['feedbackStyle'],
        orElse: () => FeedbackStyle.soft,
      ),
      humanitiesJobs: List<String>.from(json['humanitiesJobs'] ?? []),
      scienceJobs: List<String>.from(json['scienceJobs'] ?? []),
      companies: List<String>.from(json['companies'] ?? []),
    );
  }
}

// 통합 유저 데이터
class UserData {
  final String id;
  final String password;
  final String name;
  List<Certification> certList;
  List<Announcement> ancList;
  List<ScheduleItem> scheduleList;
  Map<String, int> companyColors;  // 기업 이름별 일정 색
  UserSettings userSettings;
  Map<String, String> resumeList;
  String? activeSessionId;

  //임시저장(앱 껐다키면 초기화 / 껐다켜도 유지되게 ?)
  // 아직 load, save에 반영되지 않은 사항임, 코드 추가 필요
  String draftJob = '마케팅';
  String draftEssay = '';
  String draftResult = '';

  //---------------------------------------------------------------------------
  String? draftResultEssay; // 현재 첨삭 결과를 만들 때 쓴 원문
  String? draftResultJob; // 현재 첨삭 결과를 만들 때 선택한 직무
  //-------------------------------------------------------------------------

  UserData(
      {required this.id,
      required this.password,
      required this.name,
      List<Certification>? certList,
      List<Announcement>? ancList,
      Map<String, String>? resumeList,
      List<ScheduleItem>? scheduleList,
      Map<String, int>? companyColors,
      this.userSettings = const UserSettings(),
      this.activeSessionId})
      : ancList = ancList ?? [],
        certList = certList ?? [],
        resumeList = resumeList ?? {},
        scheduleList = scheduleList ?? [],
        companyColors = companyColors ?? {};
  // Map으로 변환
  Map<String, dynamic> toJson() => {
        'id': id,
        'password': password,
        'name': name,
        'ancList': ancList.map((e) => e.toJson()).toList(),
        'certList': certList.map((e) => e.toJson()).toList(),
        'resumeList': resumeList,
        'scheduleList': scheduleList.map((e) => e.toJson()).toList(),
        'companyColors': companyColors,
        'userSettings': userSettings.toJson(),
        'activeSessionId': activeSessionId,
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
      certList: json['certList'] != null
          ? (json['certList'] as List)
              .map((e) => Certification.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      resumeList: json['resumeList'] != null
          ? Map<String, String>.from(json['resumeList'] as Map)
          : {},
      // ---- AI 사용 코드 ----
      scheduleList: json['scheduleList'] != null
          ? (json['scheduleList'] as List)
              .map((e) => ScheduleItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      // --------------------
      companyColors: (json['companyColors'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value as int)),
      userSettings: json['userSettings'] != null
          ? UserSettings.fromJson(json['userSettings'])
          : const UserSettings(),
      // json에 값이 없어도 기본값으로
      activeSessionId: json['activeSessionId'] as String?,
    );
  }
}

// ---- AI 사용 코드 ----
class UserManager {
  //전체 유저 데이터 리스트
  static List<UserData> uds = [];

  static UserData? currentUser;

  // [동시로그인-후속우선] 현재 기기에 발급된 세션 ID 및 중복 로그인 감지 콜백
  static String? currentSessionId;
  static const String _sessionPrefKey = 'active_session_id';
  static void Function()? onSessionExpired;

  static final CollectionReference _usersRef =
      FirebaseFirestore.instance.collection('users');

  // [동시로그인-후속우선] 새 고유 세션 ID 생성 및 로컬 저장
  static Future<String> issueNewSessionId() async {
    final randomPart = Random.secure().nextInt(1 << 32).toRadixString(16);
    final newSessionId = '${DateTime.now().microsecondsSinceEpoch}_$randomPart';
    currentSessionId = newSessionId;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionPrefKey, newSessionId);
    return newSessionId;
  }

  // [동시로그인-후속우선] 로컬에 저장된 세션 ID 불러오기 (앱 재시작 / 자동로그인용)
  static Future<String?> loadSavedSessionId() async {
    if (currentSessionId != null) return currentSessionId;
    final prefs = await SharedPreferences.getInstance();
    currentSessionId = prefs.getString(_sessionPrefKey);
    return currentSessionId;
  }

  // [동시로그인-후속우선] 로그아웃 시 로컬 세션 ID 제거
  static Future<void> clearSavedSessionId() async {
    currentSessionId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionPrefKey);
  }

  // [동시로그인-후속우선] Firestore의 activeSessionId와 내 세션 ID 비교
  // 반환값: true = 세션 유효, false = 다른 기기에서 후속 로그인하여 내 세션이 무효화됨
  static Future<bool> verifySession() async {
    final user = currentUser;
    if (user == null) return false;

    final localSessionId = await loadSavedSessionId();
    if (localSessionId == null || localSessionId.isEmpty) {
      return false;
    }

    try {
      final doc = await _usersRef.doc(user.id).get();
      if (!doc.exists || doc.data() == null) {
        return false;
      }

      final rawData = doc.data();
      if (!doc.exists || rawData == null) {
        return false;
      }

      final data = Map<String, dynamic>.from(rawData as Map);
      final remoteSessionId = data['activeSessionId'] as String?;
      final isValid = remoteSessionId == localSessionId;

      if (!isValid) {
        log('다른 기기에서 후속 로그인 감지: 기존 세션(${user.id}) 만료 처리');
        onSessionExpired?.call();
      }
      return isValid;
    } catch (e) {
      log('세션 검증 중 오류 발생(네트워크 일시 오류 허용): $e');
      // 시연 중 일시적 네트워크 오류로 강제 로그아웃되는 것을 막기 위해 true 반환
      return true;
    }
  }

  // [동시로그인-후속우선] 로그인 성공 시 새 세션 발급 + Firestore 문서에 activeSessionId 저장
  static Future<void> activateSessionForUser(UserData user) async {
    final newSessionId = await issueNewSessionId();
    user.activeSessionId = newSessionId;
    currentUser = user;
    await save(user);
  }

  // Firebase에서 전체 유저 문서를 불러와 uds에 저장 (로그인 시도 / 계정 찾기 시 호출)
  static Future<void> load() async {
    try {
      final snapshot = await _usersRef.get();
      uds = snapshot.docs
          .where((doc) => doc.data() != null)
          .map((doc) => UserData.fromJson(
                Map<String, dynamic>.from(doc.data()! as Map),
              ))
          .toList();
    } catch (e) {
      log('Firebase load 실패, $e');
      rethrow; // 호출한 화면에서 네트워크 에러 안내를 띄울 수 있도록 전달
    }
  }

  // 자동 로그인용: 전체 uds를 읽지 않고 특정 id의 문서 1건만 조회
  static Future<UserData?> loadUser(String id) async {
    try {
      final doc = await _usersRef.doc(id.trim()).get();
      final rawData = doc.data();
      if (!doc.exists || rawData == null) {
        return null;
      }
      final data = Map<String, dynamic>.from(rawData as Map);
      final ud = UserData.fromJson(data);

      // uds 캐시에도 해당 유저를 반영
      uds.removeWhere((u) => u.id == ud.id);
      uds.add(ud);
      return ud;
    } catch (e) {
      log('Firebase loadUser 실패, $e');
      return null;
    }
  }

  // uds 내용으로 json 파일 덮어쓰기
  static Future<void> save([UserData? target]) async {
    final UserData? userToSave = target ?? currentUser;
    if (userToSave == null) {
      log('save 건너뜀: 저장할 대상 UserData(target 또는 currentUser)가 없습니다.');
      return;
    }

    try {
      await _usersRef.doc(userToSave.id).set(userToSave.toJson());
    } catch (e) {
      log('Firebase save 실패, $e');
    }
  }

  // 회원가입 시 중복 이메일 체크 후 개별 ud 문서로 Firebase에 저장 (성공 시 true, 중복 시 false)
  static Future<bool> add(UserData ud) async {
    try {
      final docRef = _usersRef.doc(ud.id);
      final existing = await docRef.get();

      // 이미 존재하는 이메일이면 덮어쓰지 않고 false 반환
      if (existing.exists) {
        return false;
      }

      // 해당 유저의 ud 정보만 개별 문서로 저장
      await docRef.set(ud.toJson());

      // 메모리 캐시(uds) 동기화
      uds.removeWhere((u) => u.id == ud.id);
      uds.add(ud);
      return true;
    } catch (e) {
      log('Firebase add 실패, $e');
      rethrow;
    }
  }

  // Firebase에서 해당 id의 개별 문서 삭제 및 캐시 제거
  static Future<void> delete(String id) async {
    try {
      await _usersRef.doc(id).delete();
      uds.removeWhere((ud) => ud.id == id);
      if (currentUser?.id == id) {
        currentUser = null;
      }
    } catch (e) {
      log('Firebase delete 실패, $e');
    }
  }
}

