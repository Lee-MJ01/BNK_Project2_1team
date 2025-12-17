import 'package:flutter/material.dart';
import 'package:test_main/models/cust_info.dart';
import 'package:test_main/screens/member/signup_16.dart';
import '../app_colors.dart';

class AccountVerifyPage extends StatefulWidget {
  const AccountVerifyPage({super.key, required this.custInfo, });

  final CustInfo custInfo;


  @override
  State<AccountVerifyPage> createState() => _AccountVerifyPageState();
}

class _AccountVerifyPageState extends State<AccountVerifyPage> {
  String bank = "부산";
  String accountNumber = "";



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text("계좌인증", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소", style: TextStyle(color: Colors.black54)),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 24),

            const Text(
              "계좌인증",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 40),

            const Text("입금은행/증권사",
                style: TextStyle(fontSize: 14, color: Colors.black54)),

            const SizedBox(height: 6),

            _underlineRow(
              text: bank,
              onTap: () => _openBankSheet()
            ),

            const SizedBox(height: 30),

            const Text("계좌번호",
                style: TextStyle(fontSize: 14, color: Colors.black54)),

            const SizedBox(height: 6),

            /// ✅ 계좌번호 입력 영역 (터치 시 키패드)
            GestureDetector(
              onTap: _openAccountKeypad,
              child: _underlineRow(
                text: accountNumber.isEmpty ? "계좌번호" : accountNumber,
                isPlaceholder: accountNumber.isEmpty,
              ),
            ),

          ],
        ),
      ),

      bottomNavigationBar: GestureDetector(
        onTap: accountNumber.isNotEmpty
            ? () {
          // 다음 단계 (1원 인증 페이지)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AccountVerifyConfirmPage(
                custInfo: widget.custInfo,
                bank: bank,
                accountNumber: accountNumber,
              ),
            ),
          );

        }
            : null,
        child: Container(
          height: 64,
          alignment: Alignment.center,
          color: accountNumber.isNotEmpty
              ? AppColors.pointDustyNavy
              : Colors.grey.shade300,
          child: Text(
            "다음",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: accountNumber.isNotEmpty
                  ? Colors.white
                  : Colors.grey,
            ),
          ),
        ),
      ),

    );
  }

  /// 공통 밑줄 스타일
  Widget _underlineRow({
    required String text,
    VoidCallback? onTap,
    bool isPlaceholder = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.pointDustyNavy, width: 2),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isPlaceholder ? Colors.grey : Colors.black,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }


  /// 키패드 호출
  void _openAccountKeypad() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AccountKeypadSheet(initial: accountNumber),
    );

    if (result != null) {
      setState(() => accountNumber = result);
    }
  }


  void _openBankSheet() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _BankSelectSheet(selected: bank),
    );

    if (result != null) {
      setState(() => bank = result);
    }
  }

}


class _BankSelectSheet extends StatelessWidget {
  final String selected;
  const _BankSelectSheet({required this.selected});

  @override
  Widget build(BuildContext context) {
    final banks = ["부산", "국민", "신한", "우리", "하나", "농협"];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "입금은행/증권사",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          ...banks.map((b) => ListTile(
            title: Text(b),
            trailing: b == selected
                ? const Icon(Icons.check, color: Colors.blue)
                : null,
            onTap: () => Navigator.pop(context, b),
          )),
        ],
      ),
    );
  }
}




class AccountKeypadSheet extends StatefulWidget {
  final String initial;
  const AccountKeypadSheet({super.key, required this.initial});

  @override
  State<AccountKeypadSheet> createState() => _AccountKeypadSheetState();
}

class _AccountKeypadSheetState extends State<AccountKeypadSheet> {
  late String input;

  @override
  void initState() {
    super.initState();
    input = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // 제목
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "계좌번호",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 입력 표시
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black, width: 2),
                ),
              ),
              child: Text(
                input.isEmpty ? "계좌번호 입력" : input,
                style: TextStyle(
                  fontSize: 20,
                  color: input.isEmpty ? Colors.grey : Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildKeypad(),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pointDustyNavy,
                ),
                onPressed: input.isEmpty
                    ? null
                    : () => Navigator.pop(context, input),
                child: const Text(
                  "확인",
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
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        // 1 ~ 9
        for (int row = 0; row < 3; row++) ...[
          Row(
            children: [
              for (int col = 0; col < 3; col++) ...[
                Expanded(
                  child: _keyButton(
                    label: "${row * 3 + col + 1}",
                  ),
                ),
                if (col != 2) const SizedBox(width: 12),
              ],
            ],
          ),
          const SizedBox(height: 12),
        ],

        // 마지막 줄: 공백 | 0 | 백스페이스
        Row(
          children: [
            const Expanded(child: SizedBox()),

            const SizedBox(width: 12),

            Expanded(
              child: _keyButton(label: "0"),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _iconKeyButton(
                icon: Icons.backspace_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _keyButton({required String label}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          input += label;
        });
      },
      child: Container(
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFF7F8FA), // 은행 키패드 배경
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _iconKeyButton({required IconData icon}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (input.isNotEmpty) {
            input = input.substring(0, input.length - 1);
          }
        });
      },
      child: Container(
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFFFFFFF),
        ),
        child: Icon(
          icon,
          size: 26,
          color: Colors.black87,
        ),
      ),
    );
  }


}
