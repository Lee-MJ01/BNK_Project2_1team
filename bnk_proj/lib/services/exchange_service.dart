import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ExchangeService {
  static String get baseUrl => "${ApiService.currentUrl}/exchange";

  static Future<Map<String, dynamic>> fetchMyExchangeAccounts({
    required String currency,
  }) async {
    final url = Uri.parse("$baseUrl/accounts?currency=$currency");
    final headers = await ApiService.getAuthHeaders();

    final response = await http.get(url, headers: headers);
    print(url);
    print(headers);

    if (response.statusCode != 200) {
      throw Exception("계좌 조회 실패: ${response.statusCode} ${response.body}");
    }

    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  static Future<void> buyForeignCurrency({
    required String toCurrency,
    required int krwAmount,
  }) async {
    final url = Uri.parse("$baseUrl/online");
    final headers = await ApiService.getAuthHeaders();

    print(">>> 전송하는 헤더: $headers");

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        "exchType": "B",
        "exchFromCurrency": "KRW",
        "exchToCurrency": toCurrency,
        "exchKrwAmount": krwAmount,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("환전 실패: ${response.statusCode} ${response.body}");
    }
  }

  // 외화 팔기 (Sell)
  static Future<void> sellForeignCurrency({
    required String fromCurrency, // 팔려고 하는 외화 (예: USD)
    required int frgnAmount,      // 팔려고 하는 외화 금액
  }) async {
    final url = Uri.parse("$baseUrl/online");
    final headers = await ApiService.getAuthHeaders();

    print(">>> [Sell] 전송하는 헤더: $headers");

    // 백엔드 OnlineExchangeService 로직에 맞춰 파라미터 전송
    final body = jsonEncode({
      "exchType": "S",                // 거래 유형: 팔기(Sell)
      "exchFromCurrency": fromCurrency, // 내가 가진 돈 (외화)
      "exchToCurrency": "KRW",        // 받을 돈 (원화)
      "exchFrgnAmount": frgnAmount,   // 외화 금액 기준
    });

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception("환전(팔기) 실패: ${response.statusCode} ${response.body}");
    }
  }

  // 환전 시, 약관 동의 확인
  static Future<bool> checkTermsAgreed() async {
    final url = Uri.parse("${ApiService.currentUrl}/exchange/check-terms");
    try {
      final response = await http.get(url, headers: await ApiService.getAuthHeaders());
      print("서버 응답 상태코드: ${response.statusCode}");
      print("서버 응답 본문: ${response.body}");

      // 만약 서버 에러가 나면 false를 반환하여 일단 동의창을 띄우게 하거나 에러 처리를 해야 합니다.
      return response.statusCode == 200 && response.body == 'true';
    } catch (e) {
      print("네트워크 또는 서버 연결 실패: $e");
      return false; // 에러 시 일단 동의가 안 된 것으로 처리
    }
  }

  // 약관 동의 내역 저장 (최초 1회)
  static Future<void> submitTermsAgreement() async {
    final url = Uri.parse("${ApiService.currentUrl}/exchange/agree-terms");
    final headers = await ApiService.getAuthHeaders();

    final response = await http.post(url, headers: headers);

    if (response.statusCode != 200) {
      throw Exception("약관 동의 처리에 실패했습니다.");
    }
  }
}

