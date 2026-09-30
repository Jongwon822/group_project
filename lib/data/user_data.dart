import 'package:group_project/main.dart';


// 개인과제처럼 json파일에 저장하면 되지 않을까?

class userData {
  final bool userLogged;
  final List<String>? jobCategory;
  // ... 우리가 저장해야할 유저정보 목록

  userData({required this.userLogged, this.jobCategory});
}