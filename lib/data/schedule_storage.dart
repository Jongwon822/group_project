import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:group_project/data/schedule.dart';

//달력 일정을 기기에 저장하고 불러오는 클래스
class ScheduleStorage {
    static const String _key = 'schedules'; //shared_preferences 안에서 일정 목록을 찾을 때 쓰는 이름표

    //저장된 일정 불러오기
    //한번도 저장한 적이 없으면 null을 돌려줌 (처음 실행인지 구분하기 위해서)
    Future<List<ScheduleItem>?> load() async {
        final p = await SharedPreferences.getInstance();
        final String? raw = p.getString(_key);
        if (raw == null) return null;
        try {
            final List<dynamic> list = jsonDecode(raw) as List<dynamic>; //문자열-> 리스트로 변환
            return list
                .map((e)=> ScheduleItem.fromJson(e as Map<String, dynamic>))
                .toList();
        } catch (_) {
          return []; //저장된 값이 깨져있으면 빈 목록으로 시작
        }
}
    //일정 목록 전체를 저장
    Future<bool> save(List<ScheduleItem> items) async {
        try {
            final p = await SharedPreferences.getInstance();
            final String raw = jsonEncode(items.map((e) => e.toJson()).toList());
            return await p.setString(_key, raw);
        }   catch (_) {
            return false;
            }
        }
    }