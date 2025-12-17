import 'package:flutter/material.dart';
import 'package:test_main/models/cust_info.dart';
import 'package:test_main/screens/app_colors.dart';
import 'package:test_main/screens/member/signup_5_id_pw.dart';
import 'package:test_main/screens/member/signup_5_jumin.dart';


class SignUp5Page extends StatefulWidget {
  final CustInfo custInfo;

  const SignUp5Page({
    super.key, required this.custInfo,

  });

  @override
  State<SignUp5Page> createState() => _SignUp5PageState();
}

class _SignUp5PageState extends State<SignUp5Page> {
  final TextEditingController _rrnBackController = TextEditingController();

  bool get isFilled => _rrnBackController.text.length == 7;

  late final String rrnFront6 = widget.custInfo.rrn!.substring(0, 6);

  String? fullRrn;

  @override
  void dispose() {
    _rrnBackController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    debugPrint("name: ${widget.custInfo.name}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text("회원가입",
            style: TextStyle(color: Colors.black, fontSize: 18)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text("취소",
                  style: TextStyle(color: Colors.black54, fontSize: 16)),
            ),
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "약관 동의",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 36),

                // 이름 라벨
                const Text(
                  "이름",
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 6),

                // 이름 표시 (읽기전용)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    widget.custInfo.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),

                const SizedBox(height: 32),

                // 주민등록번호 라벨
                const Text(
                  "주민등록번호",
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    // 앞 6자리
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      width: 130,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade400, width: 2),
                        ),
                      ),
                      child: Text(
                        widget.custInfo.rrn!.substring(0, 6),   // ← 앞 6자리만 표시
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),


                    const SizedBox(width: 12),
                    const Text("-", style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),

                    // 뒤 7자리 입력
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RrnBackInputPage(),
                            ),
                          );

                          if (result != null && result is String) {
                            setState(() {
                              _rrnBackController.text = result;

                              // 전체 주민번호 13자리 조립
                              fullRrn = widget.custInfo.rrn!.substring(0, 6) + result;

                              print("전체 주민번호: $fullRrn");   // ← 여기서 13자리 완성됨
                              // TODO: fullRrn 을 서버 전송용 변수에 저장하거나 다음 페이지로 넘기면 됨
                            });
                          }
                        },

                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade400, width: 2),
                            ),
                          ),
                          child: Text(
                            _rrnBackController.text.isEmpty
                                ? "뒤 7자리"
                                : "●" * _rrnBackController.text.length,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: _rrnBackController.text.isEmpty
                                    ? Colors.grey : Colors.black
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          // 확인 버튼
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointDustyNavy,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
              ),
              onPressed: isFilled ? () {
                _showAgreementSheet();
              } : null,
              child: Text(
                "확인",
                style: TextStyle(
                  fontSize: 18,
                  color: isFilled ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
  void _showAgreementSheet() {
    widget.custInfo.rrn = fullRrn;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) =>AgreementSheet(custInfo: widget.custInfo,),
    );
  }

}


class AgreementSheet extends StatefulWidget {
  final CustInfo custInfo;
  const AgreementSheet({super.key, required this.custInfo,});

  @override
  State<AgreementSheet> createState() => _AgreementSheetState();
}

class _AgreementSheetState extends State<AgreementSheet> {
  bool allAgree = false;


  bool reqAgree = false;

  Map<String, bool> requiredAgreements = {
    "개인(신용)정보 수집·이용 동의서(비여신금융거래)": false,
    "고객정보 취급방침": false,
    "공공 마이데이터 개인(신용)정보 수집 이용 제공 동의서": false,
  };

  Map<String, bool> optionalAgreements = {
    "FB뱅킹 서비스 이용약관": false,
    "개인(신용)정보 수집·이용·제공 동의서(회원가입용)": false,
    "[필수] 개인(신용)정보 수집·이용·제공 동의서(FB금융그룹 API 서비스용)": false,
  };

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      maxChildSize: 0.95,
      minChildSize: 0.60,
      builder: (_, controller) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 상단바 + 닫기 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "약관동의",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),

              const SizedBox(height: 6),
              const Text(
                "서비스 이용을 위한 약관동의가 필요해요.",
                style: TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: ListView(
                  controller: controller,
                  children: [

                    // 전체동의
                    _buildAllAgree(),

                    const Divider(height: 32),

                    // [필수] 섹션
                    const Text("약관 전체동의 [필수]",
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),

                    ...requiredAgreements.keys.map(
                          (title) => _buildAgreementItem(
                        title,
                        requiredAgreements,
                        isRequired: true,
                      ),
                    ),

                    const SizedBox(height: 26),

                    // [선택] 섹션
                    const Text("KB스타클럽멤버십 서비스 약관 등 동의사항 [선택]",
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),

                    ...optionalAgreements.keys.map(
                          (title) => _buildAgreementItem(
                        title,
                        optionalAgreements,
                        isRequired: false,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 다음 버튼
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: reqAgree ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LoginCredentialSetupPage(custInfo : widget.custInfo))
                    );
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    reqAgree ?
                        AppColors.pointDustyNavy : Colors.grey.shade300,
                  ),
                  child: Text(
                    "다음",
                    style: TextStyle(
                      color: reqAgree ? Colors.white : Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            ],
          ),
        );
      },
    );
  }

  // 전체동의
  Widget _buildAllAgree() {
    return GestureDetector(
      onTap: () {
        final newValue = !allAgree;

        setState(() {
          allAgree = newValue;
          reqAgree = newValue;

          requiredAgreements.updateAll((key, value) => newValue);
          optionalAgreements.updateAll((key, value) => newValue);
        });
      },
      child: Row(
        children: [
          Icon(allAgree ? Icons.check_circle : Icons.radio_button_unchecked,
              color: allAgree ? AppColors.mainPaleBlue : Colors.grey),
          const SizedBox(width: 12),
          const Text(
            "약관 전체동의",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // 개별 약관 항목
  Widget _buildAgreementItem(
      String title,
      Map<String, bool> map, {
        required bool isRequired,
      }) {
    final checked = map[title] ?? false;

    return GestureDetector(
      onTap: () {
        setState(() {
          map[title] = !checked;

          allAgree = requiredAgreements.values.every((v) => v == true) &&
              optionalAgreements.values.every((v) => v == true);
          reqAgree = requiredAgreements.values.every((v) => v == true);
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              checked ? Icons.check_circle : Icons.radio_button_unchecked,
              color: checked ? AppColors.mainPaleBlue : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}
