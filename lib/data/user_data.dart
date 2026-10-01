
// 개인과제처럼 json파일에 저장하면 되지 않을까?

class userData {
  final String id;
  final String password;
  bool isLogged;
  final String name;

  final List<String>? jobCategory;

  // ... 우리가 저장해야할 유저정보 목록

  userData({
    required this.id,
    required this.password,
    this.isLogged = false,
    required this.name,
    this.jobCategory,
  });
}
