import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'user_data.dart';
import 'open_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ------- AI 사용 코드 ------
// 공공 API 원본 데이터를 임시로 담는 내부 모델
class _RawJobPosting {
  final String id;
  final String company;
  final String title;
  final String jobCategory;
  final String career;
  final DateTime startPeriod;
  final DateTime endPeriod;

  _RawJobPosting({
    required this.id,
    required this.company,
    required this.title,
    required this.jobCategory,
    required this.career,
    required this.startPeriod,
    required this.endPeriod,
  });

  // 서울 열린데이터광장(GetJobInfo) 응답 매핑
  factory _RawJobPosting.fromSeoulJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return _RawJobPosting(
      id: json['JO_REQST_NO']?.toString() ?? '',
      company: json['CMPNY_NM']?.toString() ?? 'Unknown Company',
      title: json['JO_SJ']?.toString() ?? 'Untitled',
      jobCategory: json['HOPE_JSSFC_CMMN_CODE_SE_NM']?.toString() ??
          json['JOBCODE_NM']?.toString() ??
          'Any Role',
      career: json['CAREER_CND_CMMN_CODE_SE_NM']?.toString() ??
          json['CAREER_CND_NM']?.toString() ??
          'Any Experience',
      startPeriod: _parseDate(
        json['JO_REG_DT']?.toString() ?? json['REG_DT']?.toString(),
        fallback: now,
      ),
      // '마감 (2026-12-01)' 또는 '채용시까지' 형태를 안전하게 처리
      endPeriod: _parseDate(
        json['RCEPT_CLOS_NM']?.toString(),
        fallback: now.add(const Duration(days: 30)),
      ),
    );
  }

  // 서울시 오류 시 대체용 api
  factory _RawJobPosting.fromRemotiveJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return _RawJobPosting(
      id: 'remotive_${json['id'] ?? now.millisecondsSinceEpoch}',
      company: json['company_name']?.toString() ?? 'Unknown Company',
      title: json['title']?.toString() ?? 'Untitled',
      jobCategory: json['category']?.toString() ?? 'Any Role',
      career: 'Any Experience',
      startPeriod: _parseDate(json['publication_date']?.toString(), fallback: now),
      endPeriod: now.add(const Duration(days: 30)),
    );
  }


  // OpenRouter에 토큰을 아껴 보내기 위한 경량 Map
  Map<String, String> toSummaryMap() => {
    'id': id,
    'company': company,
    'title': title,
    'job': jobCategory,
    'career': career,
  };

  // user_data.dart의 Announcement 모델로 변환
  Announcement toAnnouncement() {
    return Announcement(
      id: id,
      title: '[$company]$title',
      startPeriod: startPeriod,
      endPeriod: endPeriod,
      target: '$jobCategory ($career)',
    );
  }

  static DateTime _parseDate(String? raw, {required DateTime fallback}) {
    if (raw == null || raw.isEmpty) return fallback;
    final match = RegExp(r'\d{4}-\d{2}-\d{2}').firstMatch(raw);
    if (match != null) {
      return DateTime.tryParse(match.group(0)!) ?? fallback;
    }
    return fallback;
  }
}

class JobRecommendationService {

  // 발급받은 서울 열린데이터광장 인증키 입력
  static String get _seoulApiKey => dotenv.env['SEOUL_API_KEY'] ?? '';
  static const String _serviceName = 'GetJobInfo';

  // 서울시 공공 api key로 채용정보 불러오기
  static Future<List<_RawJobPosting>> _fetchPublicJobs({int count = 20}) async {
    try {
      if (_seoulApiKey.isEmpty || _seoulApiKey.contains('여기에_발급받은')) {
        throw Exception('서울시 API 키 미설정');
      }

      // 반드시 http://...:8088 포트 사용
      final uri = Uri.parse(
        'http://openapi.seoul.go.kr:8088/$_seoulApiKey/json/$_serviceName/1/$count/',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      final rawBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(rawBody);
        final serviceData = decoded is Map<String, dynamic> ? decoded[_serviceName] : null;

        if (serviceData != null && serviceData['RESULT']?['CODE'] == 'INFO-000') {
          final List<dynamic> rows = serviceData['row'] ?? [];
          final jobs = rows
              .map((e) => _RawJobPosting.fromSeoulJson(e as Map<String, dynamic>))
              .where((job) => job.id.isNotEmpty)
              .toList();
          if (jobs.isNotEmpty) return jobs;
        }
      }
      log('서울시 API 비정상 응답(백업 API로 전환): $rawBody');
    } catch (e) {
      log('서울시 API 호출 실패(백업 API로 전환): $e');
    }

    // 서울시 API가 ERROR-500 등으로 실패할 경우 무인증 공개 채용 API로 자동 대체
    return _fetchFallbackJobs(limit: count);
  }

  static Future<List<_RawJobPosting>> _fetchFallbackJobs({int limit = 20}) async {
    final uri = Uri.parse('https://remotive.com/api/remote-jobs?limit=$limit');
    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('백업 채용 API 호출 실패 (${response.statusCode})');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final List<dynamic> jobs = decoded['jobs'] ?? [];
    return jobs
        .map((e) => _RawJobPosting.fromRemotiveJson(e as Map<String, dynamic>))
        .where((job) => job.id.isNotEmpty)
        .toList();
  }

  // 현재 유저의 UserSettings를 기반으로 AI가 적합한 공고를 선별해 ancList에 저장
  static Future<int> syncRecommendedJobs(
      UserData ud, {
        bool clearExisting = false, // 설정 변경 시 true로 전달
      }) async {
    // 공공기관 API에서 최신 공고 40건 조회
    final rawJobs = await _fetchPublicJobs(count: 40);
    if (rawJobs.isEmpty) return 0;

    final settings = ud.userSettings;
    final targetJobs = settings.jobs; // humanitiesJobs + scienceJobs
    final targetCompanies = settings.companies;

    // (2) OpenRouter 프롬프트 구성
    const systemPrompt = '''
You are a job posting matching assistant.
Select the job postings that match the user's target job roles and target companies, and return only the "id" values of those postings as a JSON array of strings.
Rules:
1. Output strictly a raw JSON array in the format ["id1", "id2"].
2. Do not include Markdown code blocks (```), greetings, or additional explanations under any circumstances.
3. If no postings match the criteria, return an empty array [].
''';

    final userPrompt = '''
[User Preferences]
- Target Job Roles: ${targetJobs.isEmpty ? 'No restrictions (Select top 5 key postings across all roles)' : targetJobs.join(', ')}
- Target Companies: ${targetCompanies.isEmpty ? 'Not specified' : targetCompanies.join(', ')}

[Job Postings List]
${jsonEncode(rawJobs.map((j) => j.toSummaryMap()).toList())}
''';

    final aiResponse = await OpenRouterService.sendPrompt(
      prompt: userPrompt,
      systemPrompt: systemPrompt,
    );

    final selectedIds = _parseIdList(aiResponse);

    // 설정 변경으로 호출된 경우 기존 공고 목록 초기화
    if (clearExisting) {
      ud.ancList.clear();
    }

    // 중복되지 않는 공고만 Announcement로 변환 후 저장
    final existingIds = ud.ancList.map((a) => a.id).toSet();
    final jobMap = {for (final job in rawJobs) job.id: job};

    int addedCount = 0;
    for (final id in selectedIds) {
      if (!existingIds.contains(id) && jobMap.containsKey(id)) {
        ud.ancList.add(jobMap[id]!.toAnnouncement());
        existingIds.add(id);
        addedCount++;
      }
    }

    // 초기화했거나 새로 추가된 내역이 있으면 로컬 JSON에 저장
    if (clearExisting || addedCount > 0) {
      await UserManager.save();
    }

    return addedCount;
  }

  /// 무료 LLM 모델이 앞뒤에 마크다운이나 설명을 붙이더라도 안전하게 JSON 배열만 추출
  static List<String> _parseIdList(String rawResponse) {
    try {
      final start = rawResponse.indexOf('[');
      final end = rawResponse.lastIndexOf(']');
      if (start == -1 || end == -1 || end <= start) return [];

      final jsonSlice = rawResponse.substring(start, end + 1);
      final List<dynamic> list = jsonDecode(jsonSlice);
      return list.map((e) => e.toString()).toList();
    } catch (e) {
      log('AI 응답 ID 파싱 실패: $e / 원본: $rawResponse');
      return [];
    }
  }
}