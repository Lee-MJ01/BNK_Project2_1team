import 'dart:async'; // 타이머용
import 'package:flutter/material.dart';
import 'package:test_main/screens/app_colors.dart';
import 'package:test_main/screens/auth/pin_setup_screen.dart';
import 'package:test_main/screens/main/bank_homepage.dart';
import 'package:test_main/services/api_service.dart';
import 'package:test_main/utils/device_manager.dart';

class AuthVerificationScreen extends StatefulWidget {
  final String userId;
  final String userPassword;

  const AuthVerificationScreen({
    super.key,
    required this.userId,
    required this.userPassword,
  });

  @override
  State<AuthVerificationScreen> createState() => _AuthVerificationScreenState();
}

class _AuthVerificationScreenState extends State<AuthVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();

  // 상태 변수들
  bool _isCodeSent = false;  // 인증번호 발송 여부
  bool _isLoading = false;   // API 통신 중 로딩 상태
  bool _isTimeExpired = false; // ★ 시간 만료 여부 체크
  String _maskedPhone = "";  // 마스킹된 전화번호

  // 타이머 관련
  Timer? _timer;
  int _timeLeft = 180; // 3분 (Redis TTL과 동일)

  @override
  void dispose() {
    _timer?.cancel(); // 화면 종료 시 타이머 해제
    _codeController.dispose();
    super.dispose();
  }

  // [로직 1] 타이머 시작 및 만료 처리
  void _startTimer() {
    // 기존 타이머가 돌고 있다면 취소
    _timer?.cancel();

    setState(() {
      _timeLeft = 180;
      _isTimeExpired = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        // 시간이 0이 되면 타이머 종료 및 만료 상태로 변경
        _timer?.cancel();
        setState(() {
          _isTimeExpired = true;
        });
      }
    });
  }

  // 남은 시간을 "03:00" 형식으로 변환
  String get _timerString {
    int min = _timeLeft ~/ 60;
    int sec = _timeLeft % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  // [로직 2] 인증번호 발송 요청 (재전송 포함)
  void _requestAuthCode() async {
    setState(() => _isLoading = true);

    // API 호출
    Map<String, dynamic> result = await ApiService.sendAuthCodeToMember(widget.userId);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result['status'] == 'SUCCESS') {
      setState(() {
        _isCodeSent = true;
        _maskedPhone = result['maskedPhone'] ?? "등록된 번호";
        _codeController.clear(); // 입력창 초기화
      });

      // 타이머 시작 (재전송 시 시간 리셋됨)
      _startTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증번호가 발송되었습니다. 3분 내에 입력해주세요.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? '발송 실패')),
      );
    }
  }

  // [로직 3] 인증번호 검증 및 기기 등록
  void _verifyAndRegister() async {
    String inputCode = _codeController.text.trim();
    if (inputCode.isEmpty) return;

    // 만료되었으면 진행 불가 (버튼 비활성화로 막히지만 이중 체크)
    if (_isTimeExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증 시간이 만료되었습니다. 재전송 버튼을 눌러주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 1. 인증번호 검증 요청
    bool isVerified = await ApiService.verifyAuthCode(widget.userId, inputCode);

    if (isVerified) {
      // 2. 검증 성공 -> 기기 등록 요청
      String deviceId = await DeviceManager.getDeviceId();
      bool registerSuccess = await ApiService.registerDevice(
          widget.userId,
          widget.userPassword,
          deviceId
      );

      if (!mounted) return;

      if (registerSuccess) {
        _timer?.cancel();

        // 성공 시 PIN 설정 화면으로 이동 (스택 제거 후 이동)
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PinSetupScreen(userId: widget.userId))
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기기 인증 성공! 간편번호를 설정합니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기기 등록 실패. 잠시 후 다시 시도해주세요.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증번호가 일치하지 않습니다.')),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('기기 인증')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '새로운 기기에서 로그인 시\n추가 인증이 필요합니다.',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pointDustyNavy,
                    height: 1.4
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '회원정보에 등록된 휴대전화로 인증번호를 발송합니다.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),

              // 인증 컨테이너
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE7EBF3)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: [
                    if (!_isCodeSent) ...[
                      // 1. 발송 전 화면
                      const Icon(Icons.mark_email_unread_outlined, size: 48, color: AppColors.pointDustyNavy),
                      const SizedBox(height: 16),
                      const Text("본인 확인을 위해\n인증번호를 요청해주세요.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _requestAuthCode,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.pointDustyNavy,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('인증번호 보내기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ] else ...[
                      // 2. 발송 후 화면
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("인증번호 입력", style: TextStyle(fontSize: 13, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text("$_maskedPhone", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          TextButton(
                              onPressed: _isLoading ? null : _requestAuthCode,
                              child: const Text("재전송", style: TextStyle(fontWeight: FontWeight.bold))
                          )
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 인증번호 입력 필드
                      TextField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        // ★ 시간이 만료되면 입력 불가하게 막음
                        enabled: !_isTimeExpired,
                        decoration: InputDecoration(
                          hintText: '인증번호 6자리',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          // ★ 타이머 UI
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              _isTimeExpired ? "만료됨" : _timerString,
                              style: TextStyle(
                                  color: _isTimeExpired ? Colors.grey : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 만료 시 안내 문구 추가
                      if (_isTimeExpired)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 4),
                          child: Row(
                            children: const [
                              Icon(Icons.info_outline, size: 16, color: Colors.red),
                              SizedBox(width: 4),
                              Text("입력 시간이 만료되었습니다. 재전송해주세요.",
                                  style: TextStyle(color: Colors.red, fontSize: 12)),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      // 확인 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          // ★ 시간이 만료되었거나 로딩 중이면 버튼 비활성화
                          onPressed: (_isLoading || _isTimeExpired) ? null : _verifyAndRegister,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.pointDustyNavy,
                            disabledBackgroundColor: Colors.grey[300], // 비활성화 시 색상
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('인증 확인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}