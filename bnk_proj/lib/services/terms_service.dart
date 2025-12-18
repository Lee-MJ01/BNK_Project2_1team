import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/terms.dart';

class TermsService {
  static const String baseUrl = 'http://34.64.124.33:8080/backend';
  final http.Client _client = http.Client();

  Future<List<TermsDocument>> fetchTerms({int status = 4}) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/deposit/terms?status=$status'),
    );

    if (response.statusCode != 200) {
      throw Exception('약관 정보를 불러오지 못했습니다.');
    }

    final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

    return data
        .map((e) => TermsDocument.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}