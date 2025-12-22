import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ExchangeService {
  static String get baseUrl =>
      ApiService.currentUrl.replaceFirst('/api/mobile', '/api/exchange');

  static Future<Map<String, dynamic>> fetchMyExchangeAccounts({
    required String currency,
  }) async {
    final url = Uri.parse("$baseUrl/accounts?currency=$currency");
    final headers = await ApiService.getAuthHeaders();

    final response = await http.get(url, headers: headers);

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
}
