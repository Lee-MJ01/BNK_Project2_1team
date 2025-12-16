import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_main/models/deposit/application.dart';
import 'package:test_main/services/deposit_service.dart';
import 'package:test_main/screens/app_colors.dart';
import '../deposit/step_4.dart';

/* =========================================================
   전자서명 단계
========================================================= */
enum AuthStep {
  selectMethod,
  inputInfo,
  agreeTerms,
  waitingAuth,
  completed,
}

class DepositSignatureScreen extends StatefulWidget {
  static const routeName = "/deposit-signature";
  final DepositApplication application;

  const DepositSignatureScreen({
    super.key,
    required this.application,
  });

  @override
  State<DepositSignatureScreen> createState() =>
      _DepositSignatureScreenState();
}

class _DepositSignatureScreenState extends State<DepositSignatureScreen> {
  AuthStep _step = AuthStep.selectMethod;

  String? _selectedMethod;
  Uint8List? _certificateImage;

  bool _agree1 = false;
  bool _agree2 = false;
  bool _agree3 = false;

  bool _submitting = false;

  final _nameController = TextEditingController();
  final _rrnController = TextEditingController();
  final _phoneController = TextEditingController();

  bool get _allAgreed => _agree1 && _agree2 && _agree3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pointDustyNavy,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "전자서명",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _StepIndicator(step: _step),
            const SizedBox(height: 24),
            Expanded(child: _buildStep()),
          ],
        ),
      ),
    );
  }

  /* =========================================================
     STEP 분기
  ========================================================= */
  Widget _buildStep() {
    switch (_step) {
      case AuthStep.selectMethod:
        return _stepSelectMethod();
      case AuthStep.inputInfo:
        return _stepInputInfo();
      case AuthStep.agreeTerms:
        return _stepAgreeTerms();
      case AuthStep.waitingAuth:
        return _stepWaitingAuth();
      case AuthStep.completed:
        return _stepCompleted();
    }
  }

  /* =========================================================
     STEP 1. 본인확인 수단 선택 (스타일 유지 / 복수)
  ========================================================= */
  Widget _stepSelectMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle("본인확인 수단 선택"),
        _AuthMethodCard(
          title: "카카오 인증서",
          description: "카카오톡 인증서를 이용한 본인확인",
          selected: _selectedMethod == "kakao",
          onTap: () => _selectMethod("kakao"),
        ),
        _AuthMethodCard(
          title: "통신사 PASS",
          description: "이동통신 3사 PASS 인증",
          selected: _selectedMethod == "pass",
          onTap: () => _selectMethod("pass"),
        ),
        _AuthMethodCard(
          title: "KB 인증서",
          description: "KB국민은행 공동 인증",
          selected: _selectedMethod == "kb",
          onTap: () => _selectMethod("kb"),
        ),
        _AuthMethodCard(
          title: "네이버 인증",
          description: "네이버 인증서를 이용한 본인확인",
          selected: _selectedMethod == "naver",
          onTap: () => _selectMethod("naver"),
        ),
        _AuthMethodCard(
          title: "토스 인증",
          description: "토스 앱을 통한 본인확인",
          selected: _selectedMethod == "toss",
          onTap: () => _selectMethod("toss"),
        ),
      ],
    );
  }

  void _selectMethod(String method) {
    setState(() {
      _selectedMethod = method;
      _step = AuthStep.inputInfo;
    });
  }

  /* =========================================================
     STEP 2. 본인 정보 입력
  ========================================================= */
  Widget _stepInputInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle("본인 확인"),
        _InputField(_nameController, "이름", TextInputType.text),
        _InputField(
          _rrnController,
          "주민등록번호 앞 6자리",
          TextInputType.number,
        ),
        _InputField(
          _phoneController,
          "휴대폰 번호",
          TextInputType.phone,
        ),
        const Spacer(),
        _PrimaryButton(
          text: "다음",
          onPressed: () => setState(() => _step = AuthStep.agreeTerms),
        ),
      ],
    );
  }

  /* =========================================================
     STEP 3. 약관 동의 (개별)
  ========================================================= */
  Widget _stepAgreeTerms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle("약관 동의"),
        _AgreementTile(
          value: _agree1,
          text: "전자서명 이용약관 동의 (필수)",
          onChanged: (v) => setState(() => _agree1 = v),
        ),
        _AgreementTile(
          value: _agree2,
          text: "본인확인 서비스 이용약관 동의 (필수)",
          onChanged: (v) => setState(() => _agree2 = v),
        ),
        _AgreementTile(
          value: _agree3,
          text: "개인정보 수집 및 이용 동의 (필수)",
          onChanged: (v) => setState(() => _agree3 = v),
        ),
        const Spacer(),
        _PrimaryButton(
          text: "인증 요청",
          enabled: _allAgreed,
          onPressed: () => setState(() => _step = AuthStep.waitingAuth),
        ),
      ],
    );
  }

  /* =========================================================
     STEP 4. 인증 대기
  ========================================================= */
  Widget _stepWaitingAuth() {
    _simulateAuth();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.phone_android,
            size: 64, color: AppColors.pointDustyNavy),
        SizedBox(height: 20),
        Text(
          "본인확인 요청을 전송했습니다.\n선택한 인증 수단에서 인증을 완료해 주세요.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        SizedBox(height: 24),
        CircularProgressIndicator(color: AppColors.pointDustyNavy),
      ],
    );
  }

  /* =========================================================
     STEP 5. 전자서명 완료
  ========================================================= */
  Widget _stepCompleted() {
    return Column(
      children: [
        const Icon(Icons.check_circle,
            size: 72, color: Colors.green),
        const SizedBox(height: 20),
        const Text(
          "전자서명이 완료되었습니다.",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const Spacer(),
        _PrimaryButton(
          text: "가입 완료",
          onPressed: _goToCompletion,
        ),
      ],
    );
  }

  /* =========================================================
     인증 시뮬레이션
  ========================================================= */
  Future<void> _simulateAuth() async {
    if (_certificateImage != null) return;

    await Future.delayed(const Duration(seconds: 2));
    final data = await rootBundle.load('images/chatboticon.png');

    setState(() {
      _certificateImage = data.buffer.asUint8List();
      widget.application.signatureImage = _certificateImage;
      widget.application.signatureMethod = _selectedMethod;
      widget.application.signedAt = DateTime.now();
      _step = AuthStep.completed;
    });
  }

  /* =========================================================
     가입 완료 → step_4 이동
  ========================================================= */
  Future<void> _goToCompletion() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    final result =
    await DepositService().submitApplication(widget.application);

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      DepositStep4Screen.routeName,
      arguments: DepositCompletionArgs(
        application: widget.application,
        result: result,
      ),
    );
  }
}

/* =========================================================
   공통 UI 컴포넌트 (이전 스타일 유지)
========================================================= */

class _StepIndicator extends StatelessWidget {
  final AuthStep step;
  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "STEP ${step.index + 1} / 5",
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.pointDustyNavy,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.pointDustyNavy,
        ),
      ),
    );
  }
}

class _AuthMethodCard extends StatelessWidget {
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _AuthMethodCard({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? AppColors.pointDustyNavy
              : AppColors.mainPaleBlue,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.pointDustyNavy,
          ),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(fontSize: 13),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _AgreementTile extends StatelessWidget {
  final bool value;
  final String text;
  final ValueChanged<bool> onChanged;

  const _AgreementTile({
    required this.value,
    required this.text,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mainPaleBlue),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          text,
          style: const TextStyle(fontSize: 14.5),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  const _InputField(
      this.controller,
      this.hint,
      this.keyboardType,
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
            const BorderSide(color: AppColors.mainPaleBlue),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
            const BorderSide(color: AppColors.mainPaleBlue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
            const BorderSide(color: AppColors.pointDustyNavy),
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final bool enabled;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.text,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pointDustyNavy,
          disabledBackgroundColor: AppColors.mainPaleBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
