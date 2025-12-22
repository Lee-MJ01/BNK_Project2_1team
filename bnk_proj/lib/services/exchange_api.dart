import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screens/exchange/forex_insight.dart';
import '../services/api_service.dart';


class ExchangeApi {
  static String get baseUrl =>
      ApiService.currentUrl.replaceFirst('/api/mobile', '/api/exchange');

  static Future<List<CurrencyRate>> fetchRates() async {
    final headers = await ApiService.getAuthHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/rates'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => CurrencyRate.fromJson(e)).toList();
    } else {
      throw Exception('환율 조회 실패: ${response.statusCode} ${response.body}');
    }
  }

  static Future<List<ExchangeHistory>> fetchHistory(String currency) async {
    final headers = await ApiService.getAuthHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/rates/$currency'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map<ExchangeHistory>((e) {
        return ExchangeHistory(
          date: DateTime.parse(e['rhistRegDt']),
          rate: (e['rhistBaseRate'] as num).toDouble(),
        );
      }).toList();
    } else {
      throw Exception('히스토리 조회 실패: ${response.statusCode} ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> fetchAccounts(String currency) async {
    final headers = await ApiService.getAuthHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/accounts?currency=$currency'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception("계좌 조회 실패: ${response.statusCode} ${response.body}");
    }

    return jsonDecode(utf8.decode(response.bodyBytes));
  }
}

