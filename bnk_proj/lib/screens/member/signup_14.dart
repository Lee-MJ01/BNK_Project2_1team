import 'package:flutter/material.dart';
import 'package:test_main/models/cust_info.dart';
import 'package:test_main/screens/member/signup_15.dart';

import '../app_colors.dart';

class FaceCaptureCompletePage extends StatelessWidget {
  const FaceCaptureCompletePage({
    super.key, required this.custInfo,
  });

  final CustInfo custInfo;

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
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 170,
            child: Image.asset(
              "images/character6.png",
              fit: BoxFit.contain,
            ),
          ),

          const Text(
            "얼굴 촬영이\n완료되었습니다.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.4,
              color: Colors.black,
            ),
          ),

          const Spacer(),
        ],
      ),

      bottomNavigationBar: GestureDetector(
        onTap: () {
          // 다음 단계 (얼굴 비교 안내 / 로딩 / 서버 요청 등)
          Navigator.push(context, MaterialPageRoute(builder: (_) => AccountVerifyPage(custInfo: custInfo,)));
        },
        child: Container(
          height: 64,
          alignment: Alignment.center,
          color: AppColors.pointDustyNavy,
          child: const Text(
            "다음",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
