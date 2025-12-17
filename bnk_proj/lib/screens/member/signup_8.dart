


import 'package:flutter/material.dart';
import 'package:test_main/models/cust_info.dart';
import 'package:test_main/screens/member/signup_9_cam.dart';

import '../app_colors.dart';

class SignUp8Page extends StatefulWidget {
  const SignUp8Page({super.key, required this.custInfo});
  final CustInfo custInfo;

  @override
  State<SignUp8Page> createState() => _SignUp8PageState();
}

class _SignUp8PageState extends State<SignUp8Page> {


  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("회원가입"),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("취소", style: TextStyle(color: Colors.black54)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            const Text(
              "신분증 확인",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            const Text(
              "어떤 신분증을 가지고 계신가요?",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),

            // 주민등록증 / 운전면허증 (전체 폭)
            Center(
              child: Container(
                width: screenWidth * 0.7,
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.pointDustyNavy, width: 3),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.credit_card, size: 36),
                    SizedBox(height: 8),
                    Text(
                      "주민등록증 / 운전면허증",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            ),

            const SizedBox(height: 30),

            // 촬영 버튼
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pointDustyNavy,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => IdCameraPage(custInfo: widget.custInfo,)));
                },
                child: const Text(
                  "촬영",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 안내사항 접기/펼치기 (나중에 ExpansionTile로)
            ListTile(
              title: const Text("신분증 촬영 시 유의사항"),
              trailing: const Icon(Icons.keyboard_arrow_down),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
