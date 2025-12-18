import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screens/exchange/forex_insight.dart';

class ExchangeApi {
  static const String baseUrl =
      'http://34.64.124.33:8080/backend/api/exchange';

  static Future<List<CurrencyRate>> fetchRates() async {
    final response = await http.get(Uri.parse('$baseUrl/rates'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data
          .map((e) => CurrencyRate.fromJson(e))
          .toList();
    } else {
      throw Exception('환율 조회 실패');
    }
  }

  static Future<List<ExchangeHistory>> fetchHistory(String currency) async {
    final response = await http.get(Uri.parse('$baseUrl/rates/$currency'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map<ExchangeHistory>((e) {
        return ExchangeHistory(
          date: DateTime.parse(e['rhistRegDt']), // 백엔드 키 이름 맞춰서
          rate: (e['rhistBaseRate'] as num).toDouble(),
        );
      }).toList();
    } else {
      throw Exception('히스토리 조회 실패');
    }
  }
}