import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/end_reason.dart';
import '../core/voice_intent.dart';
import '../core/voice_res_dto.dart';

class VoiceApi {
  static Future<VoiceResDTO> process({
    required String sessionId,
    required String text,
    Intent? intent,
    String? productCode,
    EndReason? clientEndReason,
  }) async {

    final baseUrl = "https://flobank.kro.kr/backend/api/mobile";
    final baseUrl2 = "http://192.168.0.207:8080/backend/api/mobile";
    final baseUrl3 = "http://10.82.27.61:8080/backend/api/mobile";

    final res = await http.post(
      Uri.parse('$baseUrl/voice/process'),
      headers: {
        'Content-Type': 'application/json',
        'X-SESSION-ID': sessionId,
      },
      body: jsonEncode({
        'text': text,
        'dpstId': productCode,
        'intent': intent?.name.toUpperCase(),
        'clientEndReason': clientEndReason?.name,
      }),
    );

    print(res.statusCode);
    print(res.body);

    return VoiceResDTO.fromJson(jsonDecode(res.body));
  }
}
