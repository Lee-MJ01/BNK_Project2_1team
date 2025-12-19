import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/chatbot_hist.dart';

class ChatbotService {
  final String baseUrl = 'http://34.64.124.33:8080/backend';
  final String base2Url = "http://192.168.0.209:8080/backend";

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

      debugPrint('📡 statusCode: ${res.statusCode}');
      debugPrint('📡 response body: ${res.body}');

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}');
      }

      return ChatResponse.fromJson(jsonDecode(res.body));
    } catch (e, s) {
      debugPrint('❌ chatbot error: $e');
      debugPrint('❌ stack: $s');
      rethrow; // ← 제발 이거
    }
  }

}
