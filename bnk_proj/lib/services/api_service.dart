import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // 에뮬레이터에서 로컬호스트 접속 시 10.0.2.2 사용
  // 실기기 연결 시에는 내 PC의 IP 주소(예: 192.168.0.x)를 써야 함
  // 1. 실제 배포 주소 (앱 출시용 - 나중에 서버 올리면 그때 적으세요)
  static const String _prodUrl = "http://34.64.124.33:8080/backend/api/mobile";   // 실제 배포 서버
  static const String baseUrl = "http://10.0.2.2:8080/backend/api/mobile";        // 가상 디바이스 테스트
  static const String base2Url = "http://192.168.0.209:8080/backend/api/mobile";  // 케이블 연결 했을 때 로컬 테스트(본인 컴퓨터 IP로 바꿔야함)
  static const _storage = FlutterSecureStorage();

  /// 로그인 요청
  static Future<Map<String, dynamic>> login(String userid, String password, String deviceId) async {
    final url = Uri.parse('$baseUrl/member/login');

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

      // 한글 깨짐 방지 디코딩
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        // 백엔드 응답 형태에 따른 분기 처리

        // Case 1: 새로운 기기 (status: "NEW_DEVICE"가 명시적으로 옴)
        if (responseBody['status'] == 'NEW_DEVICE') {
          return {
            'status': 'NEW_DEVICE',
            'message': responseBody['message'] ?? '새로운 기기입니다.'
          };
        }

        // Case 2: 로그인 성공
        if (responseBody['token'] != null) {
          await _storage.write(key: 'auth_token', value: responseBody['token']);

          return {
            'status': responseBody['status'], // 백엔드 값을 그대로 사용
            'token': responseBody['token'],
            'custName': responseBody['custName'],
            'message': responseBody['message']
          };
        }

        return {'status': 'UNKNOWN', 'message': '알 수 없는 응답입니다.'};
      } else if (response.statusCode == 401) {
        // Case 3: 아이디/비번 불일치
        return {'status': 'FAIL', 'message': '아이디 또는 비밀번호가 일치하지 않습니다.'};
      } else {
        return {'status': 'ERROR', 'message': '서버 오류: ${response.statusCode}'};
      }
    } catch (e) {
      print("서버 통신 오류: $e");
      return {'status': 'ERROR', 'message': '서버와 연결할 수 없습니다.'};
    }
  } // login 함수 end

  /// SMS 인증번호 발송 요청
  static Future<Map<String, dynamic>> sendAuthCodeToMember(String userid) async {
    final url = Uri.parse('$baseUrl/member/auth/send-code');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userid": userid}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        // 서버에서 보낸 에러 메시지를 디코딩하여 확인
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          print("서버 에러(${response.statusCode}): ${errorBody['message']}");
          return {
            "status": "ERROR",
            "message": errorBody['message'] ?? "발송 실패 (코드: ${response.statusCode})"
          };
        } catch (e) {
          // JSON 파싱 실패 시 상태 코드라도 출력
          return {
            "status": "ERROR",
            "message": "발송 실패 (서버 응답 코드: ${response.statusCode})"
          };
        }
      }
    } catch (e) {
      print("SMS 요청 오류: $e");
      return {"status": "ERROR", "message": "서버 통신 오류"};
    }
  }

  /// [추가] 인증번호 검증 요청
  static Future<bool> verifyAuthCode(String userid, String code) async {
    final url = Uri.parse('$baseUrl/member/auth/verify-code');

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
      return false;
    }
  }

  /// 기기 등록 요청 (최종 인증 후 호출)
  static Future<bool> registerDevice(String userid, String password, String deviceId) async {
    final url = Uri.parse('$baseUrl/member/register-device');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userid": userid,
          "password": password, // 보안을 위해 비번을 다시 확인하거나, 인증 토큰을 써야 함
          "deviceId": deviceId,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

        // 등록 성공과 동시에 토큰을 발급받았으므로 저장
        if (responseBody['token'] != null) {
          await _storage.write(key: 'auth_token', value: responseBody['token']);
        }
        return true;
      }
      return false;
    } catch (e) {
      print("기기 등록 오류: $e");
      return false;
    }
  }
} // Class End