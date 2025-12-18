// lib/services/signup_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/cust_info.dart';
import '../models/cust_acct.dart';

class SignupService {
  static const String baseUrl = 'http://34.64.124.33:8080/backend';
  final http.Client _client = http.Client();

  Future<void> submitSignup(
      CustInfo custInfo,
      CustAcct custAcct,
      ) async {
    final payload = {
      "custInfo": custInfo.toJson(),
      "custAcct": custAcct.toJson(),
    };

    debugPrint('📦 payload = ${jsonEncode(payload)}');

    try {
      final response = await _client
          .post(
        Uri.parse('$baseUrl/member/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      )
          .timeout(const Duration(seconds: 5));

      debugPrint('📡 status = ${response.statusCode}');
      debugPrint('📡 body = ${response.body}');
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('회원가입 실패 (${response.statusCode})');
      }
    } catch (e, s) {
      debugPrint('❌ HTTP 요청 예외 발생: $e');
      debugPrint('$s');
    }

  }
}
