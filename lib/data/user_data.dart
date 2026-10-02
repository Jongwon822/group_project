import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

enum FeedbackStyle {
  soft('부드럽게', '격려하는 어조로, 좋은 점을 먼저 짚어 주세요.'),
  normal('보통', '균형 잡힌 어조로 피드백해 주세요.'),
  strict('꼼꼼하게', '약점을 구체적으로 지적하고 개선안을 제시해 주세요.');

  const FeedbackStyle(this.label, this.promptText);
  final String label;

  final String promptText; // AI 프롬프트에 그대로 붙임
}
//기본 설정값은 어떻게 구현할까


class userData {
  final bool userLogged;
  final String email;
  final FeedbackStyle feedbackStyle;
  final List<String> jobs;
  final List<String> companies;

  const userData({//이메일, 피드백 스타일, 직업, 회사 생성자
    this.userLogged = false,
    this.email = '',
    this.feedbackStyle = FeedbackStyle.soft,
    this.jobs = const [],
    this.companies = const [],
});
  userData copyWith({
    bool? userLogged,
    String? email,
    FeedbackStyle? feedbackStyle,
    List<String>? jobs,
    List<String>? companies,

})=>
      userData(
        userLogged: userLogged ?? this.userLogged,
        email: email ?? this.email,
        feedbackStyle: feedbackStyle ?? this.feedbackStyle,
        jobs: jobs ?? this.jobs,
        companies: companies ?? this.companies,
      );
}
//setting화면에서 쓸 것 데리고 왔습니다.

// 개인과제처럼 json파일에 저장하면 되지 않을까?

