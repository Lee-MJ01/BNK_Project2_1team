import 'package:flutter/material.dart';
import 'package:test_main/models/cust_info.dart';
import 'package:test_main/screens/app_colors.dart';
import 'package:test_main/screens/member/signup_13_face.dart';

class FaceVerifyGuidePage extends StatefulWidget {
  const FaceVerifyGuidePage({super.key, required this.custInfo,});
  final CustInfo custInfo;
  @override
  State<FaceVerifyGuidePage> createState() => _FaceVerifyGuidePageState();
}

class _FaceVerifyGuidePageState extends State<FaceVerifyGuidePage> {
  Map<String, bool> agreements = {
    "개인(신용)정보 수집·이용 동의서 [필수]": false,
    "민감정보 수집·이용 동의(얼굴확인)": false,
    "개인(신용)정보 수집·이용 동의(얼굴확인)": false,
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    debugPrint("name: ${widget.custInfo.name}");
  }

  bool get allChecked => agreements.values.every((v) => v);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "회원가입",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "취소",
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 28),

            const Text(
              "얼굴확인 안내",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "얼굴 촬영을 통해 고객님께서 직접 거래하고 계신지를 확인합니다.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24),

            _buildGuideBox(),

            const SizedBox(height: 32),

            ...agreements.keys.map(_buildAgreementItem),

          ],
        ),
      ),

      bottomNavigationBar: GestureDetector(
        onTap: allChecked
            ? () {
          Navigator.push(context, MaterialPageRoute(builder: (_)=> FaceCapturePage(custInfo: widget.custInfo)));
        }
            : null,
        child: Container(
          height: 64,
          alignment: Alignment.center,
          color: allChecked
              ? AppColors.pointDustyNavy
              : Colors.grey.shade300,
          child: Text(
            "다음",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: allChecked ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  /// 얼굴 촬영 유의사항 박스
  Widget _buildGuideBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "얼굴 촬영 시 유의사항",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          _Bullet("전면카메라가 잘 작동하는지 확인해 주세요."),
          _Bullet("얼굴 촬영 영역에 맞추어 정면을 바라봐 주세요."),
          _Bullet("너무 어둡거나 조명이 강한 장소는 피해 주세요."),
        ],
      ),
    );
  }

  /// 약관 한 줄
  Widget _buildAgreementItem(String title) {
    final checked = agreements[title]!;

    return InkWell(
      onTap: () {
        setState(() {
          agreements[title] = !checked;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            Icon(
              checked
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: checked
                  ? AppColors.mainPaleBlue
                  : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}

/// ● bullet 텍스트
class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
