import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchApi {
  static const String baseUrl = "http://34.64.124.33:8080/backend";

  /// 통합 검색
  static Future<Map<String, dynamic>> integratedSearch(String keyword) async {
    final uri = Uri.parse(
      "$baseUrl/api/search/integrated?keyword=${Uri.encodeQueryComponent(keyword)}",
    );

    final response = await http.get(uri, headers: {
      "Content-Type": "application/json",
    });

    final bodyText = utf8.decode(response.bodyBytes);

    if (response.statusCode != 200) {
      throw Exception("검색 실패(status=${response.statusCode}): $bodyText");
    }

    final decoded = jsonDecode(bodyText);
    if (decoded is! Map<String, dynamic>) {
      throw Exception("응답이 Map이 아님: $decoded");
    }
    return decoded;
  }

  /// ✅ 탭(카테고리) 상세 검색
  static Future<Map<String, dynamic>> tabSearch({
    required String keyword,
    required String type, // product/faq/docs/notice/event
    int page = 0,
    int size = 20,
  }) async {
    final uri = Uri.parse(
      "$baseUrl/api/search/tab"
          "?keyword=${Uri.encodeQueryComponent(keyword)}"
          "&type=${Uri.encodeQueryComponent(type)}"
          "&page=$page"
          "&size=$size",
    );

    final response = await http.get(uri, headers: {
      "Content-Type": "application/json",
    });

    final bodyText = utf8.decode(response.bodyBytes);

    if (response.statusCode != 200) {
      throw Exception("탭 검색 실패(status=${response.statusCode}): $bodyText");
    }

    final decoded = jsonDecode(bodyText);
    if (decoded is! Map<String, dynamic>) {
      throw Exception("응답이 Map이 아님: $decoded");
    }
    return decoded;
  }

  /// ✅ 자동완성 (SearchScreen에서 부르는 이름: autoComplete)
  /// - 백엔드가 ["KB국민은행 외화 예금", ...] 형태의 JSON 배열을 내려준다고 가정
  static Future<List<String>> autoComplete(
      String keyword, {
        int size = 10, // 백엔드가 size 받으면 사용
      }) async {
    final q = keyword.trim();
    if (q.isEmpty) return [];

    final uri = Uri.parse(
      "$baseUrl/api/search/autocomplete"
          "?keyword=${Uri.encodeQueryComponent(q)}"
          "&size=$size",
    );

    final response = await http.get(uri, headers: {
      "Content-Type": "application/json",
    });

    if (response.statusCode != 200) return [];

    final bodyText = utf8.decode(response.bodyBytes);
    final decoded = jsonDecode(bodyText);

    // 1) ["a","b"] 형태
    if (decoded is List) {
      return decoded.map((e) => e.toString()).toList();
    }

    // 2) {"suggestions":[...]} 형태까지 방어적으로 지원
    if (decoded is Map && decoded["suggestions"] is List) {
      return (decoded["suggestions"] as List).map((e) => e.toString()).toList();
    }

    return [];
  }

  /// (옵션) 기존 함수명 유지하고 싶으면 alias로 남겨도 됨
  static Future<List<String>> autocomplete(String keyword) =>
      autoComplete(keyword);

  /// 최근 검색어
  static Future<List<dynamic>> recentKeywords() async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/search/keywords/recent"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200) return [];

    final bodyText = utf8.decode(response.bodyBytes);
    return jsonDecode(bodyText);
  }
}
