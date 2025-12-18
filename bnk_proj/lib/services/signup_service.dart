// lib/services/signup_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/cust_info.dart';
import '../models/cust_acct.dart';

class SignupService {
  static const String baseUrl = 'http://34.64.124.33:8080/backend';
  static const String authUrl = 'http://34.64.124.33:8080/backend/api/mobile';
  final http.Client _client = http.Client();

  static const String baseUrl2 = "http://10.0.2.2:8080/backend";

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

  Future<void> subSignup(
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
        Uri.parse('$baseUrl2/member/api/register'),
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
      debugPrint('HTTP 요청 예외 발생: $e');
      debugPrint('$s');
    }

  }

  static Future<Map<String, dynamic>> sendAuthCodeToMemberHp(String phone) async {
    final url = Uri.parse('$authUrl/member/auth/send-code-hp');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        // 서버에서 보낸 에러 메시지를 디코딩하여 확인
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          print("서버 에러(${response.statusCode}): ${errorBody['message']}");
          return {
            "status": "ERROR",
            "message": errorBody['message'] ?? "발송 실패 (코드: ${response.statusCode})"
          };
        } catch (e) {
          // JSON 파싱 실패 시 상태 코드라도 출력
          return {
            "status": "ERROR",
            "message": "발송 실패 (서버 응답 코드: ${response.statusCode})"
          };
        }
      }
    } catch (e) {
      print("SMS 요청 오류: $e");
      return {"status": "ERROR", "message": "서버 통신 오류"};
    }
  }

  /// [추가] 인증번호 검증 요청
  static Future<bool> verifyAuthCodeHp(String userid, String code) async {
    final url = Uri.parse('$authUrl/member/auth/verify-code');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userid": userid,
          "code": code
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        return body['status'] == 'SUCCESS';
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
