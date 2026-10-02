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
