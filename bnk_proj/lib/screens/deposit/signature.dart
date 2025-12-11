import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:test_main/screens/app_colors.dart';
import '../deposit/step_4.dart';

class DepositSignatureScreen extends StatefulWidget {
  static const routeName = "/deposit-signature";

  const DepositSignatureScreen({super.key});

  @override
  State<DepositSignatureScreen> createState() => _DepositSignatureScreenState();
}

class _DepositSignatureScreenState extends State<DepositSignatureScreen> {
  bool agreeAll = false;

  // Signature Controller
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pointDustyNavy,
        title: const Text(
          "전자서명",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "상품 가입을 위해 전자서명이 필요합니다.",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.pointDustyNavy,
              ),
            ),
            const SizedBox(height: 16),

            // 안내 박스
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mainPaleBlue),
              ),
              child: const Text(
                "전자서명은 본인확인을 위해 필수이며, 해당 서명은 법적 효력이 있습니다.\n\n"
                    "아래 서명란에 이름을 서명하고, '전체 동의' 체크 후 전자서명을 완료해 주세요.",
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "서명란",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.pointDustyNavy,
              ),
            ),
            const SizedBox(height: 10),

            // 서명 박스
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mainPaleBlue),
              ),
              child: Signature(
                controller: _controller,
                backgroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            // 서명 지우기
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _controller.clear(),
                child: const Text(
                  "서명 지우기",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 전체 동의
            CheckboxListTile(
              value: agreeAll,
              onChanged: (v) => setState(() => agreeAll = v!),
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text(
                "위 내용을 모두 확인하였으며 전자서명에 동의합니다.",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.pointDustyNavy,
                ),
              ),
            ),

            const Spacer(),

            // 전자서명 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (agreeAll && !_controller.isEmpty)
                    ? () async {
                  final signatureImage = await _controller.toPngBytes();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DepositStep4Screen(),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pointDustyNavy,
                  disabledBackgroundColor: Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "전자서명 완료",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
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
}
