import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:test_main/utils/device_manager.dart';

class ApiService {
  // 환경에 맞게 주소 변경 (백엔드 Controller 경로: /api/mobile/member)
  static const String _prodUrl = "https://flobank.kro.kr/backend/api/mobile";
  static const String _prodUrlHttp = "http://34.64.124.33:8080//backend/api/mobile";
  static const String baseUrl = "http://10.0.2.2:8080/backend/api/mobile"; // 에뮬레이터
  static const String base2Url = "http://192.168.0.209:8080/backend/api/mobile";  // 케이블 연결 했을 때 로컬 테스트(본인 컴퓨터 IP로 바꿔야함)
  static const String baseUrl2 = "http://192.168.0.207:8080/backend/api/mobile";  // 케이블 연결 했을 때 로컬 테스트(본인 컴퓨터 IP로 바꿔야함)
  static const String base2Url2 = "http://192.168.0.14:8080/backend/api/mobile";

  // 현재 테스트 환경에 맞춰 선택하세요
  static const String currentUrl = _prodUrl;

  static const _storage = FlutterSecureStorage();
  static Future<Map<String, String>> getAuthHeaders() async {
    String? token = await _storage.read(key: 'auth_token');
    print("🚩 [DEBUG] 현재 저장된 토큰: $token");
    if (token == null) {
      print("🚩 [ERROR] 토큰이 없습니다. 로그인이 필요합니다.");
    }
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token", // ★ 여기가 핵심! 서버에 출입증 제시
    };
  }

  /// PIN 등록 여부 확인
  static Future<bool> checkHasPin() async {
    try {
      // 1. 저장된 사용자 ID 가져오기 (로그인 시 저장했다고 가정)
      String? userid = await _storage.read(key: 'saved_userid');

      // 사용자 ID가 없으면 false (재로그인 필요)
      if (userid == null) {
        print("🚩 [checkHasPin] 저장된 ID가 없습니다.");
        return false;
      }

      // 2. 기기 ID 가져오기
      String deviceId = await DeviceManager.getDeviceId();

      // 3. 서버에 상태 조회 요청 (기존 API 재활용)
      // 이 API는 { "status": "...", "hasPin": true/false, ... } 를 반환합니다.
      final result = await checkDeviceStatus(userid, deviceId);

      // 4. hasPin 값 반환
      return result['hasPin'] == true;

    } catch (e) {
      print("🚩 [checkHasPin] 오류 발생: $e");
      return false;
    }
  }

  // 저장된 로그인 아이디 가져오기
  static Future<String?> getSavedUserId() async {
    return await _storage.read(key: 'saved_userid');
  }

  /// [STEP 0] 기기 상태 및 일치 여부 확인 (스플래시 화면용)
  /// 반환값: { "status": "MATCH", "hasPin": true, "useBio": false } 형태의 Map
  static Future<Map<String, dynamic>> checkDeviceStatus(String userid, String deviceId) async {
    final url = Uri.parse('$currentUrl/member/check-device');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userid": userid,
          "deviceId": deviceId,
        }),
      );

      if (response.statusCode == 200) {
        // 서버에서 받은 JSON 그대로 리턴 (status, hasPin, useBio 포함)
        return jsonDecode(utf8.decode(response.bodyBytes));
      }

      // 통신은 성공했으나 200이 아닌 경우
      return {"status": "ERROR", "message": "서버 응답 오류"};

    } catch (e) {
      print("기기 확인 오류: $e");
      return {"status": "ERROR", "message": "통신 오류"};
    }
  }

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
            'message': responseBody['message'] ?? '새로운 기기입니다.',
            // 서버에서 받은 hasPin 값 전달 (없으면 false)
            'hasPin': responseBody['hasPin'] ?? false,
          };
        }

        // Case 2: 로그인 성공
        if (responseBody['token'] != null) {
          await _storage.write(key: 'auth_token', value: responseBody['token']);

          // 나중에 checkHasPin에서 쓰기 위해 아이디 저장
          await _storage.write(key: 'saved_userid', value: userid);

          return {
            'status': 'SUCCESS',
            'token': responseBody['token'],
            'custName': responseBody['custName'],
            'message': responseBody['message'],
            'hasPin': responseBody['hasPin'] ?? false,
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
  static Future<Map<String, dynamic>> getUserInfo(String userid) async {
    final url = Uri.parse('$currentUrl/member/info');

    final headers = await getAuthHeaders();

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({"userid": userid}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        return {"status": "FAIL", "message": "세션이 만료되었습니다."};
      }
    } catch (e) {
      return {"status": "ERROR"};
    }
  }

  /// [STEP 5] 생체인증 사용 여부 설정
  static Future<bool> toggleBioAuth(String userid, bool useBio) async {
    final url = Uri.parse('$currentUrl/member/auth/toggle-bio');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userid": userid,
          "useBio": useBio,
        }),
      );

      // 응답 코드와 내용을 모두 확인하여 안정성 확보
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final result = jsonDecode(utf8.decode(response.bodyBytes));
          return result['status'] == 'SUCCESS';
        }
        return true;
      }
      return false;
    } catch (e) {
      print("생체인증 설정 오류: $e");
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