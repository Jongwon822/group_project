import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// AI 로 임시 생성한 OpenRouter 코드임
// 필요에 따라 수정 필요함
class OpenRouterService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  // .env에서 키를 불러오도록 변경 (const 대신 getter 사용)
  static String get _apiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';

  // 기본 모델
  static const String defaultModel = 'openrouter/free';

  /// 단일 프롬프트를 보내고 AI의 답변을 받아옵니다.
  static Future<String> sendPrompt({
    required String prompt,
    String? systemPrompt,
    String model = defaultModel,
  }) {
    return sendChat(
      messages: [
        {'role': 'user', 'content': prompt},
      ],
      systemPrompt: systemPrompt,
      model: model,
    );
  }

  /// 대화 내역(messages)을 포함해 연속 대화를 주고받습니다.
  static Future<String> sendChat({
    required messages,
    String? systemPrompt,
    String model = defaultModel,
  }) async {
    try {
      final fullMessages = [];

    if (systemPrompt != null && systemPrompt.trim().isNotEmpty) {
    fullMessages.add({
    'role': 'system',
    'content': systemPrompt,
    });
    }

    fullMessages.addAll(messages);

    final response = await http
        .post(
    Uri.parse(_baseUrl),
    headers: {
    'Authorization': 'Bearer $_apiKey',
    'Content-Type': 'application/json',
    'HTTP-Referer': 'https://localhost',
    'X-Title': 'Group Project App',
    },
    body: jsonEncode({
    'model': model,
    'messages': fullMessages,
    }),
    )
        .timeout(const Duration(seconds: 30));

    final String responseBody = utf8.decode(response.bodyBytes);

    if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(responseBody);
    final choices = data['choices'] as List?;

    if (choices != null && choices.isNotEmpty) {
    final content = choices[0]['message']?['content'] as String?;
    if (content != null) {
    return content.trim();
    }
    }
    throw Exception('응답 데이터에 텍스트 내용이 없습니다.');
    } else {
    log('OpenRouter API 오류 (${response.statusCode}): $responseBody');
    throw Exception('AI 응답 실패 (상태 코드: ${response.statusCode})');
    }
    } catch (e) {
    log('OpenRouter 통신 실패: $e');
    rethrow;
    }
  }
}