enum FeedbackStyle {
  soft('부드럽게', '격려하는 어조로, 좋은 점을 먼저 짚어 주세요.'),
  normal('보통', '균형 잡힌 어조로 피드백해 주세요.'),
  strict('꼼꼼하게', '약점을 구체적으로 지적하고 개선안을 제시해 주세요.');

  const FeedbackStyle(this.label, this.promptText);
  final String label;

  final String promptText; // AI 프롬프트에 그대로 붙임
}

// 설정 화면에서 쓰는 값 (피드백 스타일, 관심 직군, 관심 기업)
class UserSettings {
  final String email;
  final FeedbackStyle feedbackStyle;
  final List<String> jobs;
  final List<String> companies;

  const UserSettings({//이메일, 피드백 스타일, 직업, 회사 생성자
    this.email = '',
    this.feedbackStyle = FeedbackStyle.soft,
    this.jobs = const [],
    this.companies = const [],
  });
  UserSettings copyWith({
    String? email,
    FeedbackStyle? feedbackStyle,
    List<String>? jobs,
    List<String>? companies,
  }) =>
      UserSettings(
        email: email ?? this.email,
        feedbackStyle: feedbackStyle ?? this.feedbackStyle,
        jobs: jobs ?? this.jobs,
        companies: companies ?? this.companies,
      );
}

// 개인과제처럼 json파일에 저장하면 되지 않을까

class UserData {
  final String id;
  final String password;

  String name;
  List<String>? jobCategory;

  // ... 우리가 저장해야할 유저정보 목록

  UserData({
    required this.id,
    required this.password,
    this.name = '',
    this.jobCategory,
  });
}

class Announcement {
  final String title;
  final String period;
  final String target;

  Announcement({required this.title, required this.period, required this.target});


}
