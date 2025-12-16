import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_main/screens/member/signup_19.dart';
import '../app_colors.dart';

import 'signup_18_addr.dart';


class CustomerInfoPage extends StatefulWidget {
  const CustomerInfoPage({super.key, required this.name, required this.rrn, required this.phone});
  final String name;
  final String rrn;
  final String phone;

  @override
  State<CustomerInfoPage> createState() => _CustomerInfoPageState();
}

class _CustomerInfoPageState extends State<CustomerInfoPage> {
  // 휴대폰
  String phonePrefix = "010";
  final TextEditingController phoneCtrl = TextEditingController();

  // 이메일
  final TextEditingController emailIdCtrl = TextEditingController();
  String emailDomain = "gmail.com";
  bool noEmail = false;

  // 주소
  final TextEditingController addr2Ctrl = TextEditingController();
  String zip = "";
  String addr1 = "";
  String addr2 = "";
  String email = "";

  String get fullEmail {
    if (noEmail) return "";
    if (emailIdCtrl.text.isEmpty || emailDomain.isEmpty) return "";
    return "${emailIdCtrl.text}@${emailDomain}";
  }



  // 고객관리 안내수단
  String mailAgree = "자택";
  String phoneAgree = "수신";
  String emailAgree = "수신";
  String smsAgree = "수신";

  @override
  void initState() {
    super.initState();
    phoneCtrl.text = widget.phone.substring(3);
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소", style: TextStyle(color: Colors.black54)),
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const SizedBox(height: 24),

                const Text(
                  "고객정보 등록",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 32),

                _phoneInput(),
                const SizedBox(height: 32),

                _emailInput(),
                const SizedBox(height: 32),

                _addressInput(),
                const SizedBox(height: 32),

                const Divider(),

                const SizedBox(height: 24),
                const Text(
                  "고객관리 안내수단",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _selectRow("우편물", ["자택", "직장", "거부"], mailAgree,
                        (v) => setState(() => mailAgree = v)),

                _selectRow("전화", ["수신", "거부"], phoneAgree,
                        (v) => setState(() => phoneAgree = v)),

                _selectRow("이메일", ["수신", "거부"], emailAgree,
                        (v) => setState(() => emailAgree = v)),

                _selectRow("SMS", ["수신", "거부"], smsAgree,
                        (v) => setState(() => smsAgree = v)),



                const SizedBox(height: 20),
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
                        builder: (_) => ExtraInfoPage(name: widget.name, rrn: widget.rrn, phone: widget.phone, zip: zip, addr1: addr1, addr2: addr2Ctrl.text, email: fullEmail, mailAgree: mailAgree, phoneAgree: phoneAgree, emailAgree: emailAgree, smsAgree: smsAgree)
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
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // 휴대폰 입력
  Widget _phoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("휴대폰", style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 6),

        Row(
          children: [
            // 010 영역
            SizedBox(
              width: 90,
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: phonePrefix,
                    isDense: true,
                    items: ["010", "011", "016"]
                        .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => phonePrefix = v!),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // 뒷번호
            Expanded(
              child: TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.number,
                maxLength: 8, // ✅ 길이 제한
                decoration: const InputDecoration(
                  hintText: "휴대폰 번호",
                  border: UnderlineInputBorder(),
                  counterText: "", // 글자수 표시 제거
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // 숫자만
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }


  // -------------------------
  // 이메일 입력 + 도메인 선택
  Widget _emailInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("이메일", style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 6),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: emailIdCtrl,
                enabled: !noEmail,
                decoration: const InputDecoration(
                  hintText: "아이디",
                  border: UnderlineInputBorder(),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text("@", style: TextStyle(fontSize: 18)),
            ),
            Expanded(
              child: InkWell(
                onTap: noEmail ? null : _showEmailDomainSheet,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                  ),
                  child: Text(
                    emailDomain,
                    style: TextStyle(
                      color: noEmail ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        InkWell(
          onTap: () => setState(() => noEmail = !noEmail),
          child: Row(
            children: [
              Icon(
                size: 18,
                noEmail
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: noEmail
                    ? AppColors.mainPaleBlue
                    : Colors.grey,
              ),
              const SizedBox(width: 4),
              const Text("이메일 없음"),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------
  // 주소 입력
  Widget _addressInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("자택주소", style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 6),

        // ── 우편번호 + 주소검색
        Row(
          children: [
            Expanded(
              child: Text(
                zip.isEmpty ? "우편번호" : zip,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (_) => const AddressSearchPage()),
                );

                if (result != null) {
                  final parts = result.split('|');
                  setState(() {
                    zip = parts[0];
                    addr1 = parts[1];
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointDustyNavy,
              ),
              child: const Text(
                "주소검색",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // ── 기본 주소
        Text(
          addr1.isEmpty ? "주소" : addr1,
          style: const TextStyle(fontSize: 16),
        ),

        const SizedBox(height: 8),

        // ── 상세 주소 입력 (신규)
        TextField(
          controller: addr2Ctrl,
          decoration: const InputDecoration(
            hintText: "상세 주소",
            border: UnderlineInputBorder(),
          ),
          onChanged: (v) => addr2 = v,
        ),

        const SizedBox(height: 6),

        const Text(
          "입력된 주소가 다르면 주소검색 후 변경해 주세요",
          style: TextStyle(fontSize: 13, color: Colors.black45),
        ),
      ],
    );
  }


  // -------------------------
  // 이메일 도메인 바텀시트
  void _showEmailDomainSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final domains = [
          "직접입력",
          "naver.com",
          "gmail.com",
          "daum.net",
          "hanmail.net",
          "nate.com",
        ];

        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6, // ✅ 핵심
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  "이메일도메인 선택",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: ListView(
                    children: domains.map((d) => ListTile(
                      title: Center(child: Text(d)),
                      onTap: () {
                        setState(() {
                          emailDomain = d == "직접입력" ? "" : d;
                        });
                        Navigator.pop(context);
                      },
                    )).toList(),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------
  // 라디오 행
  // -------------------------
  // 선택 버튼 행 (은행 스타일)
  Widget _selectRow(
      String title,
      List<String> options,
      String value,
      void Function(String) onChanged,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 8),

        Row(
          children: options.map((o) {
            final selected = o == value;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(o),
                child: Container(
                  height: 44,
                  margin: const EdgeInsets.only(right: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.pointDustyNavy.withOpacity(0.08)
                        : Colors.white,
                    border: Border.all(
                      color: selected
                          ? AppColors.pointDustyNavy
                          : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    o,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColors.pointDustyNavy
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

}
