import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/chatbot_hist.dart';

class ChatbotService {
  final String baseUrl = 'http://34.64.124.33:8080/backend';

  ChatbotService();

  Future<ChatResponse> ask(String question) async {
    try {
      final res = await http
          .post(
        Uri.parse('$baseUrl/api/mypage/chatbot'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'question': question}),
      )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        throw Exception('챗봇 응답 실패');
      }

      return ChatResponse.fromJson(jsonDecode(res.body));
    } catch (e) {
      throw Exception('네트워크 오류');
    }
  }

}
