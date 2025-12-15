import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/deposit/list.dart';
import '../models/deposit/view.dart';

class DepositService {
  static const String baseUrl = 'http://10.0.2.2:8080/backend';
  final http.Client _client = http.Client();

  /// =========================
  /// 상품 목록
  /// =========================
  Future<List<DepositProductList>> fetchProductList() async {
    final response =
    await _client.get(Uri.parse('$baseUrl/deposit/products'));

    if (response.statusCode != 200) {
      throw Exception('상품 목록 조회 실패');
    }

    final List<dynamic> data =
    jsonDecode(utf8.decode(response.bodyBytes));

    return data
        .map((e) => DepositProductList.fromJson(e))
        .toList();
  }

  /// =========================
  /// 상품 상세
  /// =========================
  Future<DepositProduct> fetchProductDetail(String dpstId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/deposit/products/$dpstId'),
    );

    if (response.statusCode != 200) {
      throw Exception('상품 상세 조회 실패');
    }

    final Map<String, dynamic> data =
    jsonDecode(utf8.decode(response.bodyBytes));

    return DepositProduct.fromJson(data);
  }
}
