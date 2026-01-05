import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/survey.dart';

class SurveyService {
  static const String baseUrl = "https://flobank.kro.kr/backend/api";
  final http.Client _client = http.Client();

  Future<SurveyDetail> fetchSurveyDetail(int surveyId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/surveys/$surveyId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('설문 조회 실패 (${response.statusCode})');
    }

    final Map<String, dynamic> data =
        jsonDecode(utf8.decode(response.bodyBytes));
    return SurveyDetail.fromJson(data);
  }

  Future<void> submitSurveyResponse({
    required int surveyId,
    required String custCode,
    required List<Map<String, dynamic>> answers,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/surveys/$surveyId/responses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'custCode': custCode,
        'answers': answers,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('설문 저장 실패 (${response.statusCode})');
    }
  }
}
