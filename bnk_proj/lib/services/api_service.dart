import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:test_main/utils/device_manager.dart';

class ApiService {
  // 환경에 맞게 주소 변경 (백엔드 Controller 경로: /api/mobile/member)
  static const String _prodUrl = "http://34.64.124.33:8080/backend/api/mobile";
  static const String baseUrl = "http://10.0.2.2:8080/backend/api/mobile"; // 에뮬레이터
  static const String base2Url = "http://192.168.0.209:8080/backend/api/mobile";  // 케이블 연결 했을 때 로컬 테스트(본인 컴퓨터 IP로 바꿔야함)

  // 현재 테스트 환경에 맞춰 선택하세요
  static const String currentUrl = base2Url;

  static const _storage = FlutterSecureStorage();

  /// 로그인 요청
  static Future<Map<String, dynamic>> login(String userid, String password, String deviceId) async {
    final url = Uri.parse('$currentUrl/member/login');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userid": userid,
          "password": password,
          "deviceId": deviceId,
        }),
      );

      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        // Case 1: 새로운 기기 (추가 인증 필요)
        if (responseBody['status'] == 'NEW_DEVICE') {
          return {
            'status': 'NEW_DEVICE',
            'message': responseBody['message'] ?? '새로운 기기입니다. 인증이 필요합니다.'
          };
        }

        // Case 2: 로그인 성공
        if (responseBody['token'] != null) {
          await _storage.write(key: 'auth_token', value: responseBody['token']);
          return {
            'status': 'SUCCESS',
            'token': responseBody['token'],
            'custName': responseBody['custName'],
            'message': responseBody['message']
          };
        }

        return {'status': 'UNKNOWN', 'message': '알 수 없는 응답입니다.'};
      } else {
        return {'status': 'FAIL', 'message': responseBody['message'] ?? '로그인 실패'};
      }
    } catch (e) {
      print("서버 통신 오류: $e");
      return {'status': 'ERROR', 'message': '서버와 연결할 수 없습니다.'};
    }
  }

  /// [STEP 1] 인증번호 발송 요청
  static Future<Map<String, dynamic>> sendAuthCodeToMember(String userid) async {
    final url = Uri.parse('$currentUrl/member/auth/send-code');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userid": userid}),
      );

      // 성공이든 실패든 백엔드 메시지를 그대로 리턴
      return jsonDecode(utf8.decode(response.bodyBytes));

    } catch (e) {
      print("SMS 요청 오류: $e");
      return {"status": "ERROR", "message": "서버 통신 오류"};
    }
  }

  /// [STEP 2] 인증번호 검증 요청
  static Future<bool> verifyAuthCode(String userid, String code) async {
    final url = Uri.parse('$currentUrl/member/auth/verify-code');

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
      print("검증 오류: $e");
      return false;
    }
  }

  /// [STEP 3] 기기 등록 요청 (최종)
  static Future<bool> registerDevice(String userid, String password, String deviceId) async {
    final url = Uri.parse('$currentUrl/member/register-device');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userid": userid,
          "password": password,
          "deviceId": deviceId,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        // 토큰 저장
        if (responseBody['token'] != null) {
          await _storage.write(key: 'auth_token', value: responseBody['token']);
        }
        return responseBody['status'] == 'SUCCESS';
      }
      return false;
    } catch (e) {
      print("기기 등록 오류: $e");
      return false;
    }
  }

  /// [STEP 4] 간편비밀번호(PIN) 등록 요청
  static Future<Map<String, dynamic>> registerPin(String userid, String pin) async {
    final url = Uri.parse('$currentUrl/member/auth/register-pin');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userid": userid,
          "pin": pin,
        }),
      );
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (e) {
      return {"status": "ERROR", "message": "통신 오류가 발생했습니다."};
    }
  }

  /// [STEP 5] 생체인증 사용 여부 설정
  static Future<bool> toggleBioAuth(String userid, bool useYn) async {
    final url = Uri.parse('$currentUrl/member/auth/toggle-bio');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userid": userid,
          "useYn": useYn ? "Y" : "N",
        }),
      );
      final result = jsonDecode(utf8.decode(response.bodyBytes));
      return result['status'] == 'SUCCESS';
    } catch (e) {
      return false;
    }
  }

  /// [STEP 6] 간편비밀번호(PIN)로 로그인 시도
  static Future<Map<String, dynamic>> loginWithPin(String userid, String pin) async {
    final url = Uri.parse('$currentUrl/member/login-pin');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userid": userid,
          "pin": pin,
          // 기기 고유 ID도 함께 보내서 검증하면 더욱 안전합니다.
          "deviceId": await DeviceManager.getDeviceId(),
        }),
      );

      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && responseBody['token'] != null) {
        // 성공 시 토큰 저장
        await _storage.write(key: 'auth_token', value: responseBody['token']);
        return {'status': 'SUCCESS'};
      }
      return {'status': 'FAIL', 'message': responseBody['message']};
    } catch (e) {
      return {'status': 'ERROR', 'message': '서버 연결 실패'};
    }
  }
}