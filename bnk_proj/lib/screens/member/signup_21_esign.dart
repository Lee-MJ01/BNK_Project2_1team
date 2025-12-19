import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:test_main/models/cust_acct.dart';
import 'package:test_main/models/cust_info.dart';
import 'package:test_main/screens/app_colors.dart';
import 'package:test_main/screens/member/signup_22.dart';
import 'package:test_main/services/signup_service.dart';

import '../../utils/device_manager.dart';

class ElectronicSignaturePage extends StatefulWidget {
  const ElectronicSignaturePage({
    super.key,
    required this.custInfo, required this.custAcct,
  });

  final CustInfo custInfo;
  final CustAcct custAcct;



  @override
  State<ElectronicSignaturePage> createState() =>
      _ElectronicSignaturePageState();
}

class _ElectronicSignaturePageState extends State<ElectronicSignaturePage> {


  bool _agreeAll = false;

  bool _agreeProductDesc = false;
  bool _agreeProductTerms = false;
  bool _agreeDepositBase = false;
  bool _agreeSignature = false;
  bool _agreeAuth = false;
  bool _agreePrivacy = false;

  bool get _allAgreed =>
      _agreeProductDesc &&
          _agreeProductTerms &&
          _agreeDepositBase &&
          _agreeSignature &&
          _agreeAuth &&
          _agreePrivacy;

  void _syncAgreeAll() {
    _agreeAll = _allAgreed;
  }


  String _deviceId = "UNKNOWN_DEVICE";


  Map<String, dynamic> _buildContractSnapshot(String personId) {
    return {
      "personId": personId,
      "jobType": widget.custInfo.jobType,
      "purpose": widget.custAcct.purpose,
      "source": widget.custAcct.source,
      "isOwner": widget.custAcct.isOwner,
      "isForeignTax": widget.custInfo.isForeignTax,
      "productCode": "CHECKING_ACCOUNT",
      "termsVersion": "v1.0",
      "contractAt": DateTime.now().toIso8601String(),
      "deviceId": _deviceId,
    };
  }




  late final String personId;


  String sha256Hex(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);  // convert 사용
    return digest.toString();
  }

  @override
  void initState() {
    super.initState();
    personId = sha256Hex(widget.custInfo.rrn!);   // rrn → personId
    _initDeviceId();
  }

  Future<void> _initDeviceId() async {
    _deviceId = await DeviceManager.getDeviceId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text("전자서명", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle("전자서명"),

                    const SizedBox(height: 12),

                    // ✅ STEP 2: 전자서명 안내 박스
                    _SignatureNoticeBox(),

                    const SizedBox(height: 20),

                    // ✅ STEP 3: 약관 동의
                    _AgreementGroup(
                      title: "계좌개설 약관",
                      children: [
                        _AgreementTile(
                          value: _agreeProductDesc,
                          text: "상품설명서 확인 및 동의 (필수)",
                          onChanged: (v) => setState(() {
                            _agreeProductDesc = v;
                            _syncAgreeAll();
                          }),
                        ),
                        _AgreementTile(
                          value: _agreeProductTerms,
                          text: "상품약관 동의 (필수)",
                          onChanged: (v) => setState(() {
                            _agreeProductTerms = v;
                            _syncAgreeAll();
                          }),
                        ),
                        _AgreementTile(
                          value: _agreeDepositBase,
                          text: "예금거래기본약관 동의 (필수)",
                          onChanged: (v) => setState(() {
                            _agreeDepositBase = v;
                            _syncAgreeAll();
                          }),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _AgreementGroup(
                      title: "전자서명 및 개인정보",
                      children: [
                        _AgreementTile(
                          value: _agreeSignature,
                          text: "전자서명 이용약관 동의 (필수)",
                          onChanged: (v) => setState(() {
                            _agreeSignature = v;
                            _syncAgreeAll();
                          }),
                        ),
                        _AgreementTile(
                          value: _agreeAuth,
                          text: "본인확인 서비스 이용약관 동의 (필수)",
                          onChanged: (v) => setState(() {
                            _agreeAuth = v;
                            _syncAgreeAll();
                          }),
                        ),
                        _AgreementTile(
                          value: _agreePrivacy,
                          text: "개인정보 수집 및 이용 동의 (필수)",
                          onChanged: (v) => setState(() {
                            _agreePrivacy = v;
                            _syncAgreeAll();
                          }),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    _AgreementTile(
                      value: _agreeAll,
                      text: "전체 약관에 동의합니다 (필수)",
                      small: true,
                      onChanged: (v) => setState(() {
                        _agreeAll = v;
                        _agreeProductDesc = v;
                        _agreeProductTerms = v;
                        _agreeDepositBase = v;
                        _agreeSignature = v;
                        _agreeAuth = v;
                        _agreePrivacy = v;
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // ✅ 하단 버튼
            _PrimaryButton(
              text: "동의하고 가입 완료",
              enabled: _allAgreed,
              onPressed: _onSubmit,
            ),
          ],
        ),
      ),

    );
  }

  Future<void> _onSubmit() async {
    // if (_points.isEmpty) return;

    // 계약 스냅샷 생성
    final contractSnapshot = _buildContractSnapshot(personId);



    // 서버로 보낼 payload
    final payload = {
      "contractSnapshot": contractSnapshot,
      "signType": "TERMS_AGREEMENT",
      "agreedTerms": {
        "productDesc": true,
        "productTerms": true,
        "depositBase": true,
        "signature": true,
        "auth": true,
        "privacy": true,
      },
      "agreedAt": DateTime.now().toIso8601String(),
    };

    /*
    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("회원가입 데이터 전송 실패");
    }
     */

    // rrn 메모리 폐기 (의미적)
    // widget.rrn = null; // ← final이라 실제 제거는 scope 종료로 처리

    widget.custInfo.deviceId = _deviceId;
    debugPrint('📦 custInfo = ${widget.custInfo}');



    final signupService = SignupService();
    try {
      await signupService.submitSignup(
        widget.custInfo,
        widget.custAcct,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AccountCreateCompletePage(
            custAcct: widget.custAcct,
            custInfo: widget.custInfo,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("회원가입에 실패했습니다.")),
      );
    }


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

class _AgreementGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _AgreementGroup({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mainPaleBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.pointDustyNavy,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _AgreementTile extends StatelessWidget {
  final bool value;
  final String text;
  final bool small;
  final ValueChanged<bool> onChanged;

  const _AgreementTile({
    required this.value,
    required this.text,
    required this.onChanged,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      title: Text(
        text,
        style: TextStyle(fontSize: small ? 12.5 : 14.5),
      ),
    );
  }
}

class _SignatureNoticeBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mainPaleBlue),
      ),
      child: const Text(
        "[전자서명 안내]\n"
            "본 동의는 전자서명 방식으로 처리되며 전자서명법 및 "
            "전자금융거래법에 따라 서면 서명과 동일한 법적 효력을 가집니다.\n\n"
            "[전자서명 동의서]\n"
            "상품설명서, 상품약관, 예금거래기본약관의 내용을 확인하였으며 "
            "전자서명에 동의합니다.",
        style: TextStyle(fontSize: 13, height: 1.5),
      ),
    );
  }
}

