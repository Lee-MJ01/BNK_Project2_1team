import 'package:flutter/material.dart';
import 'package:test_main/models/cust_info.dart';
import 'package:test_main/screens/app_colors.dart';
import 'package:test_main/screens/member/signup_12.dart';

class IdVerifyCompletePage extends StatelessWidget {
  const IdVerifyCompletePage({super.key, required this.custInfo, });

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
            onPressed: () {
              Navigator.pop(context);
            },
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
          const SizedBox(height: 40,),

          // ✅ 체크 아이콘
          SizedBox(
            width: double.infinity,
            height: 170,
            child: Image.asset(
              "images/character6.png",
              fit: BoxFit.contain,
            ),
          ),


          // ✅ 안내 문구
          const Text(
            "신분증 확인이\n완료되었습니다.",
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

      // ✅ 하단 버튼
      bottomNavigationBar: GestureDetector(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(
              builder: (_) => FaceVerifyGuidePage(custInfo: custInfo,)));
        },
        child: Container(
          height: 64,
          alignment: Alignment.center,
          color: AppColors.pointDustyNavy, // 노란색 버튼
          child: const Text(
            "다음",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
