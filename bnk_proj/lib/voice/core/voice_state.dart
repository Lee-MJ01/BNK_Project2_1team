
/// 음성 비서 상태
enum VoiceState {
  s0Idle,
  s1Recommend,
  s2ProductExplain,
  s3JoinConfirm,

  s4Terms,
  s4Input,
  s4Confirm,
  s4Signature,

  s5End;

  static VoiceState from(String value) {
    return VoiceState.values.firstWhere(
          (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => VoiceState.s0Idle, // fallback
    );
  }
}
