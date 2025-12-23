// voice_intent_classifier.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/voice_intent.dart';

class VoiceIntentClassifier {
  static Future<IntentResult> classify(String text) async {
    final res = await http.post(
      Uri.parse('https://api.flobank.co.kr/voice/classify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'utterance': text,
      }),
    );

    final json = jsonDecode(res.body);

    return IntentResult(
      intent: Intent.values.byName(json['intent']),
      productCode: json['productCode'],
    );
  }
}
class IntentResult {
  final Intent intent;
  final String? productCode;

  IntentResult({
    required this.intent,
    this.productCode,
  });
}