import 'package:test_main/voice/core/voice_intent.dart';
import 'package:test_main/voice/core/voice_state.dart';

import 'end_reason.dart';

class VoiceResDTO {
  final VoiceState currentState;
  final Intent intent;
  final String? noticeCode;
  final EndReason? endReason;
  final String? productCode;

  VoiceResDTO({
    required this.currentState,
    required this.intent,
    this.noticeCode,
    this.endReason,
    this.productCode,
  });

  factory VoiceResDTO.fromJson(Map<String, dynamic> json) {
    return VoiceResDTO(
      currentState: VoiceState.from(json['currentState']),
      intent: Intent.from(json['intent']),
      noticeCode: json['noticeCode'],
      endReason: json['endReason'] != null
          ? EndReason.from(json['endReason'])
          : null,
      productCode: json['productCode'],
    );
  }
}
