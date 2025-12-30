import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/deposit/application.dart';
import '../models/deposit/context.dart';
import '../models/deposit/list.dart';
import '../models/deposit/view.dart';

class DepositService {
  static const String baseUrl =
      'http://34.64.124.33:8080/backend/deposit';

  static const String mobileBaseUrl =
      'http://34.64.124.33:8080/backend/api/mobile/deposit';

  final http.Client _client = http.Client();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// 상품 목록
  Future<List<DepositProductList>> fetchProductList() async {
    final token = await _storage.read(key: 'auth_token');

    final response = await _client.get(
      Uri.parse('$baseUrl/products'),
      headers: token == null
          ? null
          : {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('상품 목록 조회 실패 (${response.statusCode})');
    }

    final List<dynamic> data =
    jsonDecode(utf8.decode(response.bodyBytes));

    return data
        .map((e) => DepositProductList.fromJson(e))
        .toList();
  }

  /// 상품 상세
  Future<DepositProduct> fetchProductDetail(String dpstId) async {
    final token = await _storage.read(key: 'auth_token');

    final response = await _client.get(
      Uri.parse('$baseUrl/products/$dpstId'),
      headers: token == null
          ? null
          : {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('상품 상세 조회 실패 (${response.statusCode})');
    }

    final Map<String, dynamic> data =
    jsonDecode(utf8.decode(response.bodyBytes));

    return DepositProduct.fromJson(data);
  }


  /// 상품 금리 조회
  Future<double?> fetchRate({
    required String dpstId,
    required String currency,
    required int months,
  }) async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('로그인이 필요합니다.');
    }

    final uri = Uri.parse('$mobileBaseUrl/products/$dpstId/rate').replace(
      queryParameters: {
        'currency': currency,
        'month': months.toString(),
      },
    );

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('금리 조회 실패 (${response.statusCode})');
    }

    final Map<String, dynamic> data =
    jsonDecode(utf8.decode(response.bodyBytes));

    final num? rate = data['rate'] as num?;
    return rate?.toDouble();
  }



  /// 사용자 컨텍스트
  Future<DepositContext> fetchContext() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('로그인이 필요합니다.');
    }

    final response = await _client.get(
      Uri.parse('$mobileBaseUrl/context'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('사용자 정보 조회 실패 (${response.statusCode})');
    }

    final Map<String, dynamic> data =
    jsonDecode(utf8.decode(response.bodyBytes));

    return DepositContext.fromJson(data);
  }

  /// 예금 가입 신청
  Future<DepositSubmissionResult> submitApplication(
      DepositApplication application) async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('로그인이 필요합니다.');
    }

    final response = await _client.post(
      Uri.parse('$mobileBaseUrl/applications'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(application.toJson()),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception('예금 가입 신청 실패 (${response.statusCode})');
    }

    final Map<String, dynamic> data =
    jsonDecode(utf8.decode(response.bodyBytes));

    return DepositSubmissionResult.fromJson(data);
  }
}
