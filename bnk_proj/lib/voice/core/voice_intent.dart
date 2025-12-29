enum Intent {
  // --- 탐색/추천 ---
  reqRecommend,
  reqOther,
  reqExplain,
  reqJoin,

  // --- 의사 표현 ---
  affirm,     // yes, 동의, 이해했어요
  deny,       // no, 거절

  provideValue,

  // --- 진행 제어 ---
  proceed,    // 다음
  confirm,    // 최종 확정

  // --- 흐름 제어 ---
  reqBack,
  reqCancel,

  unknown,

  success;

  static Intent from(String value) {
    switch (value) {
      case 'REQ_RECOMMEND':
        return Intent.reqRecommend;
      case 'REQ_OTHER':
        return Intent.reqOther;
      case 'REQ_EXPLAIN':
        return Intent.reqExplain;
      case 'REQ_JOIN':
        return Intent.reqJoin;

      case 'AFFIRM':
        return Intent.affirm;
      case 'DENY':
        return Intent.deny;

      case 'PROVIDE_VALUE':
        return Intent.provideValue;

      case 'PROCEED':
        return Intent.proceed;
      case 'CONFIRM':
        return Intent.confirm;

      case 'REQ_BACK':
        return Intent.reqBack;
      case 'REQ_CANCEL':
        return Intent.reqCancel;

      case 'SUCCESS':
        return Intent.success;

      default:
        return Intent.unknown;
    }
  }

}