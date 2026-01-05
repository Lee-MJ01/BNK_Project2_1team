import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/survey.dart';
import '../models/survey_recommendation.dart';
import 'api_service.dart';

class SurveyService {
  // ✅ 배포/로컬 자동 전환
  static String get baseUrl => ApiService.currentUrl;

  final http.Client _client = http.Client();

  Future<SurveyDetail> fetchSurveyDetail(int surveyId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/surveys/$surveyId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('설문 조회 실패 (${response.statusCode})');
    }

    final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return SurveyDetail.fromJson(data);
  }

  /// ✅ 원래(실제 저장) 엔드포인트로 제출
  Future<void> submitSurveyResponse({
    required int surveyId,
    required String custCode,
    required List<Map<String, dynamic>> answers,
  }) async {
    final url = '$baseUrl/surveys/$surveyId/responses';

    print('🚀 SURVEY POST URL = $url');
    print('🧾 SUBMIT BODY = ${jsonEncode({'custCode': custCode, 'answers': answers})}');
    print('🧾 answers[0] = ${answers.isNotEmpty ? answers[0] : 'EMPTY'}');

    final response = await _client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'custCode': custCode,
        'answers': answers,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      // 서버가 뭘 리턴하는지까지 보고 싶으면 body도 찍어두는게 좋음
      print('❌ RESPONSE BODY = ${utf8.decode(response.bodyBytes)}');
      throw Exception('설문 저장 실패 (${response.statusCode})');
    }
  }

  /// ✅ 디버그용: 서버가 "진짜로 받은 JSON"을 그대로 echo 해주는 _debug 엔드포인트로 제출
  /// 서버에 @PostMapping("/{surveyId}/responses/_debug") 를 추가해둔 상태에서만 사용해.
  Future<Map<String, dynamic>> submitSurveyResponseDebug({
    required int surveyId,
    required String custCode,
    required List<Map<String, dynamic>> answers,
  }) async {
    final url = '$baseUrl/surveys/$surveyId/responses/_debug';

    print('🧪 SURVEY DEBUG POST URL = $url');
    print('🧪 DEBUG SUBMIT BODY = ${jsonEncode({'custCode': custCode, 'answers': answers})}');
    print('🧪 answers[0] = ${answers.isNotEmpty ? answers[0] : 'EMPTY'}');

    final response = await _client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'custCode': custCode,
        'answers': answers,
      }),
    );

    // debug는 보통 200 OK + echo json 리턴
    if (response.statusCode != 200 && response.statusCode != 201) {
      print('❌ DEBUG RESPONSE BODY = ${utf8.decode(response.bodyBytes)}');
      throw Exception('디버그 설문 호출 실패 (${response.statusCode})');
    }

    final bodyStr = utf8.decode(response.bodyBytes);
    final decoded = jsonDecode(bodyStr);

    // 서버가 Map 형태로 그대로 돌려주면 Map<String,dynamic>으로 캐스팅 가능
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    // 혹시 다른 형태면 래핑해서 반환
    return {'raw': decoded};
  }

  Future<List<SurveyRecommendation>> fetchRecommendations({
    required int surveyId,
    required String custCode,
  }) async {
    final url = '$baseUrl/surveys/$surveyId/recommendations?custCode=$custCode';
    final response = await _client.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('추천 조회 실패 (${response.statusCode})');
    }

    final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return data
        .map((e) => SurveyRecommendation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<SurveyRecommendation>> refreshRecommendations({
    required int surveyId,
    required String custCode,
  }) async {
    final url =
        '$baseUrl/surveys/$surveyId/recommendations/refresh?custCode=$custCode';
    final response = await _client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('추천 갱신 실패 (${response.statusCode})');
    }

    final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return data
        .map((e) => SurveyRecommendation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SurveyPrefill> fetchPrefill({
    required int surveyId,
    required String custCode,
  }) async {
    final url = '$baseUrl/surveys/$surveyId/prefill?custCode=$custCode';
    final response = await _client.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('prefill 조회 실패 (${response.statusCode})');
    }

    final Map<String, dynamic> data =
        jsonDecode(utf8.decode(response.bodyBytes));
    return SurveyPrefill.fromJson(data);
  }
}
