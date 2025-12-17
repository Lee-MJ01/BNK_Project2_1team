import 'package:flutter/material.dart';
import 'package:test_main/models/cust_acct.dart';
import 'package:test_main/models/cust_info.dart';
import 'package:test_main/screens/app_colors.dart';
import 'package:test_main/screens/member/signup_21_esign.dart';

enum ReferralType { employee, none }

class DemandAccountOpenPage extends StatefulWidget {
  const DemandAccountOpenPage({
    super.key,
     required this.custInfo, required this.custAcct,
  });


  final CustInfo custInfo;
  final CustAcct custAcct;



  @override
  State<DemandAccountOpenPage> createState() => _DemandAccountOpenPageState();
}

class _DemandAccountOpenPageState extends State<DemandAccountOpenPage> {
  bool salaryExist = false; // 급여일 여부
  bool manageBranch = false; // 관리희망점
  String contractMethod = "이메일";

  late final String emailId;
  late final String emailDomain;



  ReferralType _type = ReferralType.none;
  final TextEditingController _searchController = TextEditingController();

  bool get isEmployee => _type == ReferralType.employee;

  List<int> numbers = [];

  @override
  void initState() {
    super.initState();
    final parts = widget.custInfo.email!.split('@');
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


                if (contractMethod == "LMS")
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("LMS",
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
                                widget.custInfo.phone!,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      _infoText(
                          "금융소비자보호법에 따라 FB뱅킹 알림, 이메일 및 LMS 수신 거절 여부과 관계없이 발송됩니다."),
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



                const SizedBox(height: 28),
                const Text(
                  "권유직원 선택",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    _selectButton(
                      label: "직원이름",
                      selected: isEmployee,
                      onTap: () {
                        setState(() {
                          _type = ReferralType.employee;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _selectButton(
                      label: "없음",
                      selected: _type == ReferralType.none,
                      onTap: () {
                        setState(() {
                          _type = ReferralType.none;
                          _searchController.clear();
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// 직원 검색바 (직원이름 선택 시만)
                if (isEmployee) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: "직원 이름을 입력하세요",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                            child: const Icon(Icons.close, size: 20),
                          ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade600,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "검색",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],


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
              onPressed: () async {
                // 1. 비밀번호 설정
                final pw1 = await showPasswordBottomSheet(context, title: "계좌 비밀번호 설정");
                if (pw1 == null) return;

                // 2. 비밀번호 확인
                final pw2 = await showPasswordBottomSheet(context, title: "비밀번호 확인");
                if (pw2 == null) return;

                // 3. 검증
                if (pw1 != pw2) {
                  showDialog(
                    context: context,
                    barrierDismissible: false, // 바깥 눌러서 닫히지 않게
                    builder: (_) {
                      return Dialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0), // 살짝만 각진 사각형
                        ),
                        child: SizedBox(
                          width: 300,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 28),

                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  "비밀번호가 일치하지 않습니다",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),
                              const Divider(height: 1),

                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: AppColors.pointDustyNavy,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero, // 버튼 직각
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    "확인",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );

                  return;
                }

                widget.custAcct.salaryExist = salaryExist;
                widget.custAcct.manageBranch = manageBranch;
                // 4. 다음 화면 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ElectronicSignaturePage(
                      custInfo: widget.custInfo,
                      custAcct: widget.custAcct,

                      contractMethod: contractMethod,

                    ),
                  ),
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
  Future<String?> showPasswordBottomSheet(
      BuildContext context, {
        required String title,
      }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) => _PasswordBottomSheet(title: title),
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

  Widget _selectButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? Colors.black : Colors.black26,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
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

class _PasswordBottomSheet extends StatefulWidget {
  final String title;
  const _PasswordBottomSheet({required this.title});

  @override
  State<_PasswordBottomSheet> createState() => _PasswordBottomSheetState();
}

class _PasswordBottomSheetState extends State<_PasswordBottomSheet> {
  String input = "";
  List<int> numbers = List.generate(9, (i) => i + 1);

  @override
  void initState() {
    super.initState();
    shuffleNumbers();
  }

  void addNumber(int n) {
    if (input.length >= 4) return;

    setState(() => input += n.toString());

    if (input.length == 4) {
      Future.delayed(const Duration(milliseconds: 150), () {
        Navigator.pop(context, input);
      });
    }
  }

  void deleteNumber() {
    if (input.isEmpty) return;
    setState(() => input = input.substring(0, input.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets +
          const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 30),
          Text(widget.title, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final filled = i < input.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? Colors.black : Colors.grey.shade300,
                ),
              );
            }),
          ),

          const SizedBox(height: 30),

          // 숫자 키패드
          Column(
            children: [
              // 1~9
              for (int row = 0; row < 3; row++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      for (int col = 0; col < 3; col++) ...[
                        Expanded(
                          child: _buildKey(numbers[row * 3 + col]),
                        ),
                        if (col != 2) const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),

              // 마지막 줄
              Row(
                children: [
                  Expanded(
                    child: _buildIconKey(
                      icon: Icons.refresh,
                      onTap: shuffleNumbers,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _buildKey(0)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildIconKey(
                      icon: Icons.backspace_outlined,
                      onTap: deleteNumber,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }


  Widget _buildKey(int number) {
    return GestureDetector(
      onTap: () => addNumber(number),
      child: Container(
        height: 90, // 세로만 고정
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFEBF0F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          "$number",
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildIconKey({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 90,
        margin: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color:Color(0xFFEBF0F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 30),
      ),
    );
  }



  void shuffleNumbers() {
    numbers = List.generate(9, (i) => i + 1); // 1~9
    numbers.shuffle();
    setState(() {});
  }

}
