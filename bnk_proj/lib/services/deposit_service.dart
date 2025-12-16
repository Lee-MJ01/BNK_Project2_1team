import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/deposit/list.dart';
import '../models/deposit/view.dart';
import '../models/deposit/application.dart';

class DepositService {
  static const String baseUrl = 'http://10.0.2.2:8080/backend';
  final http.Client _client = http.Client();

  /// =========================
  /// 상품 목록
  /// =========================
  Future<List<DepositProductList>> fetchProductList() async {
    final response =
    await _client.get(Uri.parse('$baseUrl/deposit/products'));

    ///예금 리스트 잘 나오는지 확인하는 로그
    ///print('STATUS = ${response.statusCode}');
    ///print('BODY = ${response.body}');


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



  /// =========================
  /// 예금 신규 가입 신청
  /// =========================
  Future<DepositSubmissionResult> submitApplication(
      DepositApplication application) async {


    final response = await _client.post(
      Uri.parse('$baseUrl/deposit/applications'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(application.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('예금 가입 신청 실패 (${response.statusCode})');
    }

    final Map<String, dynamic> data =
    jsonDecode(utf8.decode(response.bodyBytes));

    return DepositSubmissionResult.fromJson(data);
  }

}
