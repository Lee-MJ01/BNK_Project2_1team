enum Intent {
  // --- 탐색/추천 ---
  reqRecommend,
  reqOther,
  reqExplain,
  reqJoin,

  // --- 의사 표현 ---
  affirm,     // yes, 동의, 이해했어요
  deny,       // no, 거절

  // --- 진행 제어 ---
  proceed,    // 다음
  confirm,    // 최종 확정

  // --- 흐름 제어 ---
  reqBack,
  reqCancel,

  unknown,

  success;

  static Intent from(String value) {
    return Intent.values.firstWhere(
          (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => Intent.unknown,
    );
  }
}