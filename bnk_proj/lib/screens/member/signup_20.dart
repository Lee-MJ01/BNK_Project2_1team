import 'package:flutter/material.dart';
import 'package:test_main/screens/app_colors.dart';
import 'package:test_main/screens/member/signup_21_esign.dart';

class DemandAccountOpenPage extends StatefulWidget {
  const DemandAccountOpenPage({
    super.key,
    required this.email, required this.name, required this.rrn, required this.phone, required this.zip, required this.addr1, required this.addr2, required this.mailAgree, required this.phoneAgree, required this.emailAgree, required this.smsAgree, required this.jobType, required this.purpose, required this.source, required this.isOwner, required this.isForeignTax, required this.showForeignInfo, required this.showNotice,
  });

  final String name;
  final String rrn;
  final String phone;
  final String zip;
  final String addr1;
  final String addr2;
  final String email;
  final String mailAgree;
  final String phoneAgree;
  final String emailAgree;
  final String smsAgree;

  final String jobType;
  final String purpose;
  final String source;
  final bool isOwner;          // 거래자금 본인 소유
  final bool isForeignTax;   // 해외 납세 의무자
  final bool showForeignInfo;
  final bool showNotice;

  @override
  State<DemandAccountOpenPage> createState() => _DemandAccountOpenPageState();
}

class _DemandAccountOpenPageState extends State<DemandAccountOpenPage> {
  bool salaryExist = false; // 급여일 여부
  bool manageBranch = false; // 관리희망점
  String contractMethod = "이메일";

  late final String emailId;
  late final String emailDomain;

  @override
  void initState() {
    super.initState();
    final parts = widget.email.split('@');
    emailId = parts.isNotEmpty ? parts.first : "";
    emailDomain = parts.length > 1 ? parts.last : "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text("회원가입", style: TextStyle(color: Colors.black)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text("취소", style: TextStyle(color: Colors.black54)),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const SizedBox(height: 16),

                const Text(
                  "입출금 통장 개설",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 24),

                // 💳 통장 카드
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 105,
                        child: Image.asset(
                          "images/krwaccounticon.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "FLO 입출금통장",
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "조건 없이 누구나\n 혜택을 받을 수 있는\n 입출금 통장",
                              style: TextStyle(fontSize: 15),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "#수수료 면제",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                _toggleRow(
                  title: "급여일",
                  left: "있음",
                  right: "없음",
                  value: salaryExist,
                  onChanged: (v) => setState(() => salaryExist = v),
                ),

                const SizedBox(height: 28),

                _toggleRow(
                  title: "계약서류 수신방법",
                  left: "이메일",
                  right: "LMS 등",
                  value: contractMethod == "이메일",
                  onChanged: (v) =>
                      setState(() => contractMethod = v ? "이메일" : "LMS"),
                ),


                const SizedBox(height: 20),

                // 📧 이메일 표시
                if (contractMethod == "이메일")
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("이메일",
                          style: TextStyle(color: Colors.black54)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: Colors.grey.shade400, width: 2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "$emailId@$emailDomain",
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      _infoText(
                          "고객님이 입력하신 이메일주소로 발송되며,\n이메일 주소는 변경되지 않습니다."),
                    ],
                  ),

                const SizedBox(height: 32),

                _toggleRow(
                  title: "관리 희망점",
                  left: "있음",
                  right: "없음",
                  value: manageBranch,
                  onChanged: (v) => setState(() => manageBranch = v),
                ),

                const SizedBox(height: 16),

                _infoText("관리점은 자동으로 지정됩니다."),

                const SizedBox(height: 24),

                const Text(
                  "※ 위 상품정보와 관련한 자세한 내용은 상품설명서를 참고해 주세요.",
                  style: TextStyle(color: Color(0x8A750000), fontSize: 13),
                ),
                const SizedBox(height: 40),

              ],
            ),
          ),

          // 하단 버튼
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ElectronicSignaturePage(
                        name: widget.name,
                        rrn: widget.rrn,
                        purpose: widget.purpose,
                        source: widget.source,
                        isOwner: widget.isOwner,
                        isForeignTax: widget.isForeignTax,
                        jobType: widget.jobType,
                        phone: widget.phone,
                        zip: widget.zip,
                        addr1: widget.addr1,
                        addr2: widget.addr2,
                        email: widget.email,
                        mailAgree: widget.mailAgree,
                        phoneAgree: widget.phoneAgree,
                        emailAgree: widget.emailAgree,
                        smsAgree: widget.smsAgree,
                        showForeignInfo: widget.showForeignInfo,
                        showNotice: widget.showNotice,
                        salaryExist: salaryExist,
                        manageBranch: manageBranch,
                        contractMethod: contractMethod,
                      ),
                    )
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointDustyNavy,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: const Text(
                "다음",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------
  Widget _toggleRow({
    required String title,
    required String left,
    required String right,
    required bool value, // true = left, false = right
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 8),

        Row(
          children: [
            _toggleButton(
              text: left,
              selected: value == true,
              onTap: () => onChanged(true),
            ),
            const SizedBox(width: 12),
            _toggleButton(
              text: right,
              selected: value == false,
              onTap: () => onChanged(false),
            ),
          ],
        ),
      ],
    );
  }

  Widget _toggleButton({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: selected
                  ? AppColors.pointDustyNavy
                  : Colors.grey.shade400,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected
                  ? AppColors.pointDustyNavy
                  : Colors.black,
            ),
          ),
        ),
      ),
    );
  }



  Widget _infoText(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, size: 16, color: Colors.black45),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black45),
          ),
        ),
      ],
    );
  }
}
