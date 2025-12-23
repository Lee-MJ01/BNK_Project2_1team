class VoiceSsmlTemplates {
  /// 1️⃣ 첫 인사 (idle 진입)
  static String greeting() => '''
<speak>
  <prosody volume="soft">
    안녕하십니까.
  </prosody>
  <break time="500ms"/>
  플로뱅크의 음성 가이드,
  <emphasis level="moderate">플로비</emphasis>입니다.
</speak>
''';

  /// 2️⃣ 추천 시작
  static String startRecommend() => '''
<speak>
  <prosody rate="medium">
    원하시는 예금을
  </prosody>
  <break time="200ms"/>
  추천해 드리겠습니다.
</speak>
''';

  /// 3️⃣ 상품 설명 시작
  static String explainProduct(String productName) => '''
<speak>
  <prosody rate="medium">
    ${productName} 상품에 대해
  </prosody>
  <break time="200ms"/>
  설명드리겠습니다.
</speak>
''';

  /// 4️⃣ 가입 의사 확인 (중요)
  static String confirmJoin() => '''
<speak>
  <prosody rate="slow">
    이 상품에
  </prosody>
  <break time="200ms"/>
  <emphasis level="moderate">
    가입
  </emphasis>
  하시겠습니까?
</speak>
''';

  /// 5️⃣ 약관 동의 안내
  static String termsGuide() => '''
<speak>
  <prosody rate="slow">
    가입을 위해
  </prosody>
  <break time="200ms"/>
  약관 동의가 필요합니다.
</speak>
''';

  /// 6️⃣ 입력 요청 (금액/기간)
  static String inputGuide() => '''
<speak>
  <prosody rate="medium">
    가입 금액과 기간을
  </prosody>
  <break time="200ms"/>
  말씀해 주세요.
</speak>
''';

  /// 7️⃣ 입력 완료 후 확인
  static String confirmInput() => '''
<speak>
  <prosody rate="slow">
    입력하신 내용을
  </prosody>
  <break time="200ms"/>
  확인해 주세요.
</speak>
''';

  /// 8️⃣ 전자서명 단계 (아주 중요)
  static String signatureGuide() => '''
<speak>
  <prosody rate="slow">
    전자서명을
  </prosody>
  <break time="200ms"/>
  진행하겠습니다.
</speak>
''';

  /// 9️⃣ 완료
  static String completed() => '''
<speak>
  <prosody rate="slow">
    가입이 완료되었습니다.
  </prosody>
  <break time="300ms"/>
  이용해 주셔서 감사합니다.
</speak>
''';

  /// 🔟 이해 못 했을 때 (unknown intent)
  static String unknown() => '''
<speak>
  <prosody rate="slow">
    죄송합니다.
  </prosody>
  <break time="200ms"/>
  다시 한 번 말씀해 주세요.
</speak>
''';

  /// 1️⃣1️⃣ 취소 안내
  static String canceled() => '''
<speak>
  <prosody rate="slow">
    음성 안내를
  </prosody>
  <break time="200ms"/>
  종료하겠습니다.
</speak>
''';
}
