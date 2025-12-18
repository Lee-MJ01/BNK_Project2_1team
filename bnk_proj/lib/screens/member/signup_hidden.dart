import 'package:flutter/material.dart';

import 'package:test_main/screens/app_colors.dart';
import 'package:test_main/services/signup_service.dart';

import '../../models/cust_acct.dart';
import '../../models/cust_info.dart';



class CustInfoAllInOneFormPage extends StatefulWidget {
  const CustInfoAllInOneFormPage({super.key});

  @override
  State<CustInfoAllInOneFormPage> createState() => _CustInfoAllInOneFormPageState();
}

class _CustInfoAllInOneFormPageState extends State<CustInfoAllInOneFormPage> {
  final _formKey = GlobalKey<FormState>();

  // CustInfo
  final _nameCtrl = TextEditingController();
  final _rrnCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _addr1Ctrl = TextEditingController();
  final _addr2Ctrl = TextEditingController();
  final _deviceIdCtrl = TextEditingController();
  final _engNameCtrl = TextEditingController();

  String? _jobType; // dropdown
  bool _isForeignTax = false;

  String? _mailAgree;  // "자택" / "직장" / "수신안함"
  String? _phoneAgree; // "수신" / "거부"
  String? _emailAgree; // "수신" / "거부"
  String? _smsAgree;   // "수신" / "거부"

  // CustAcct
  String? _purpose; // dropdown
  String? _source;  // dropdown
  bool _isOwner = true;
  final _acctPwCtrl = TextEditingController();

  bool _hideLoginPw = true;
  bool _hideAcctPw = true;

  // 예시 옵션 (필요한 값으로 바꾸면 됨)
  final _jobTypeOptions = const ["학생", "직장인", "자영업", "프리랜서", "무직", "기타"];
  final _purposeOptions = const ["생활비", "급여", "저축", "보험료 납부", "투자", "기타"];
  final _sourceOptions = const ["근로소득", "사업소득", "연금소득", "금융소득", "상속/증여", "기타"];

  @override
  void initState() {
    super.initState();

    // 기본값(원하면 수정)
    _mailAgree = "자택";
    _phoneAgree = "수신";
    _emailAgree = "수신";
    _smsAgree = "수신";
    _jobType = _jobTypeOptions.first;
    _purpose = _purposeOptions.first;
    _source = _sourceOptions.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rrnCtrl.dispose();
    _idCtrl.dispose();
    _pwCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _zipCtrl.dispose();
    _addr1Ctrl.dispose();
    _addr2Ctrl.dispose();
    _deviceIdCtrl.dispose();
    _engNameCtrl.dispose();
    _acctPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final custInfo = CustInfo(
      name: _nameCtrl.text.trim(),
      rrn: _emptyToNull(_rrnCtrl.text),
      id: _emptyToNull(_idCtrl.text),
      pw: _emptyToNull(_pwCtrl.text),
      phone: _emptyToNull(_phoneCtrl.text),
      email: _emptyToNull(_emailCtrl.text),
      zip: _emptyToNull(_zipCtrl.text),
      addr1: _emptyToNull(_addr1Ctrl.text),
      addr2: _emptyToNull(_addr2Ctrl.text),
      jobType: _jobType,
      isForeignTax: _isForeignTax,
      deviceId: _emptyToNull(_deviceIdCtrl.text),
      engName: _emptyToNull(_engNameCtrl.text),
      mailAgree: _mailAgree,
      phoneAgree: _phoneAgree,
      emailAgree: _emailAgree,
      smsAgree: _smsAgree,
    );

    final custAcct = CustAcct(
      purpose: _purpose,
      source: _source,
      isOwner: _isOwner,
      manageBranch: true,
      salaryExist: true,
      acctPw: _acctPwCtrl.text,
      contractMethod: null
    );

    final signupService = SignupService();

    try {
      await signupService.submitSignup(custInfo, custAcct);

      // ✅ 성공하면 그냥 이전 페이지로
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("회원가입에 실패했습니다.")),
      );
    }
  }


  String? _emptyToNull(String s) {
    final t = s.trim();
    return t.isEmpty ? null : t;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("고객정보 입력"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointDustyNavy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text("저장하고 계속", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
          children: [
            _SectionCard(
              title: "기본 정보",
              child: Column(
                children: [
                  _LabeledField(
                    label: "이름",
                    requiredMark: true,
                    child: _TextField(
                      controller: _nameCtrl,
                      hint: "예) 홍길동",
                      validator: (v) => (v == null || v.trim().isEmpty) ? "이름을 입력해주세요" : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _LabeledField(
                    label: "영문명",
                    child: _TextField(
                      controller: _engNameCtrl,
                      hint: "예) HONG GILDONG",
                    ),
                  ),
                  const SizedBox(height: 12),
                  _LabeledField(
                    label: "주민등록번호",
                    child: _TextField(
                      controller: _rrnCtrl,
                      hint: "하이픈 없이 13자리",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _LabeledField(
                    label: "직업 유형",
                    requiredMark: true,
                    child: _Dropdown(
                      value: _jobType,
                      items: _jobTypeOptions,
                      onChanged: (v) => setState(() => _jobType = v),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ToggleTile(
                    title: "해외납세의무자 여부",
                    subtitle: "미국 등 해외 납세의무가 있으면 켜주세요",
                    value: _isForeignTax,
                    onChanged: (v) => setState(() => _isForeignTax = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            _SectionCard(
              title: "계정/기기",
              child: Column(
                children: [
                  _LabeledField(
                    label: "아이디",
                    child: _TextField(
                      controller: _idCtrl,
                      hint: "예) flobank_user",
                    ),
                  ),
                  const SizedBox(height: 12),
                  _LabeledField(
                    label: "비밀번호",
                    child: _TextField(
                      controller: _pwCtrl,
                      hint: "영문/숫자 조합 권장",
                      obscureText: _hideLoginPw,
                      suffix: IconButton(
                        onPressed: () => setState(() => _hideLoginPw = !_hideLoginPw),
                        icon: Icon(_hideLoginPw ? Icons.visibility_off : Icons.visibility),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _LabeledField(
                    label: "기기 ID",
                    child: _TextField(
                      controller: _deviceIdCtrl,
                      hint: "8eed-8961-4fb 이런 식으로 아무렇게나",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            _SectionCard(
              title: "연락처",
              child: Column(
                children: [
                  _LabeledField(
                    label: "휴대폰",
                    child: _TextField(
                      controller: _phoneCtrl,
                      hint: "예) 01012345678",
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _LabeledField(
                    label: "이메일",
                    child: _TextField(
                      controller: _emailCtrl,
                      hint: "예) user@gmail.com",
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            _SectionCard(
              title: "주소",
              child: Column(
                children: [
                  _LabeledField(
                    label: "우편번호",
                    child: _TextField(
                      controller: _zipCtrl,
                      hint: "예) 12345",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _LabeledField(
                    label: "기본주소",
                    child: _TextField(
                      controller: _addr1Ctrl,
                      hint: "예) 부산광역시 ...",
                    ),
                  ),
                  const SizedBox(height: 12),
                  _LabeledField(
                    label: "상세주소",
                    child: _TextField(
                      controller: _addr2Ctrl,
                      hint: "예) 101동 1001호",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            _SectionCard(
              title: "안내 수신 설정",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ChipRow(
                    title: "우편 수신",
                    value: _mailAgree ?? "자택",
                    options: const ["자택", "직장", "수신안함"],
                    onChanged: (v) => setState(() => _mailAgree = v),
                  ),
                  const SizedBox(height: 12),
                  _ChipRow(
                    title: "전화",
                    value: _phoneAgree ?? "수신",
                    options: const ["수신", "거부"],
                    onChanged: (v) => setState(() => _phoneAgree = v),
                  ),
                  const SizedBox(height: 12),
                  _ChipRow(
                    title: "이메일",
                    value: _emailAgree ?? "수신",
                    options: const ["수신", "거부"],
                    onChanged: (v) => setState(() => _emailAgree = v),
                  ),
                  const SizedBox(height: 12),
                  _ChipRow(
                    title: "SMS",
                    value: _smsAgree ?? "수신",
                    options: const ["수신", "거부"],
                    onChanged: (v) => setState(() => _smsAgree = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            _SectionCard(
              title: "계좌 개설 정보",
              child: Column(
                children: [
                  _LabeledField(
                    label: "거래 목적",
                    requiredMark: true,
                    child: _Dropdown(
                      value: _purpose,
                      items: _purposeOptions,
                      onChanged: (v) => setState(() => _purpose = v),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _LabeledField(
                    label: "자금 출처",
                    requiredMark: true,
                    child: _Dropdown(
                      value: _source,
                      items: _sourceOptions,
                      onChanged: (v) => setState(() => _source = v),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ToggleTile(
                    title: "거래자금 본인 여부",
                    subtitle: "본인 자금이면 켜주세요",
                    value: _isOwner,
                    onChanged: (v) => setState(() => _isOwner = v),
                  ),
                  const SizedBox(height: 12),
                  _LabeledField(
                    label: "계좌 비밀번호",
                    child: _TextField(
                      controller: _acctPwCtrl,
                      hint: "4자리",
                      keyboardType: TextInputType.number,
                      obscureText: _hideAcctPw,
                      maxLength: 4,
                      suffix: IconButton(
                        onPressed: () => setState(() => _hideAcctPw = !_hideAcctPw),
                        icon: Icon(_hideAcctPw ? Icons.visibility_off : Icons.visibility),
                      ),
                      validator: (v) {
                        final t = (v ?? "").trim();
                        if (t.isEmpty) return null; // 선택
                        if (t.length != 4) return "4자리로 입력해주세요";
                        if (!RegExp(r'^\d{4}$').hasMatch(t)) return "숫자만 입력해주세요";
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.subIvoryBeige.withOpacity(0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final bool requiredMark;
  final Widget child;
  const _LabeledField({required this.label, this.requiredMark = false, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            if (requiredMark) ...[
              const SizedBox(width: 6),
              const Text("*", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800)),
            ]
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final int? maxLength;
  final String? Function(String?)? validator;

  const _TextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.maxLength,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        counterText: "",
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.black12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.black12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.pointDustyNavy, width: 1.3)),
        suffixIcon: suffix,
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _Dropdown({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(14),
          icon: const Icon(Icons.expand_more),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.pointDustyNavy,
          ),
        ],
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  final String title;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _ChipRow({
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final selected = opt == value;
            return ChoiceChip(
              label: Text(opt),
              selected: selected,
              onSelected: (_) => onChanged(opt),
              selectedColor: AppColors.mainPaleBlue,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.pointDustyNavy : Colors.black87,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: BorderSide(color: selected ? AppColors.pointDustyNavy : Colors.black12),
              ),
              backgroundColor: Colors.white,
            );
          }).toList(),
        ),
      ],
    );
  }
}
