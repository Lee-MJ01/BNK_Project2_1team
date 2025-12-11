import 'package:flutter/material.dart';
import 'package:test_main/screens/app_colors.dart';
import 'step_1.dart';
import 'step_2.dart';
import 'step_3.dart';
import 'package:test_main/screens/main/bank_homepage.dart';

class DepositStep4Screen extends StatelessWidget {
  static const routeName = "/deposit-step4";

  const DepositStep4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pointDustyNavy,
        title: const Text(
          "가입완료",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              _completeTop(),

              const SizedBox(height: 30),
              _completeTable(),

              const SizedBox(height: 40),
              _bottomButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------
  // 상단 완료 안내 + 캐릭터 이미지
  // -------------------------------------------------
  Widget _completeTop() {
    return Column(
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Image(
            image: const AssetImage("images/character10.png"),
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "상품 신규가입이 완료되었습니다.",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.pointDustyNavy,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          "상품 가입을 진심으로 감사드립니다.\n더 나은 서비스로 보답하겠습니다.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.pointDustyNavy.withOpacity(0.7),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------
  // 가입 정보 테이블
  // -------------------------------------------------
  Widget _completeTable() {
    final rows = [
      ["고객명", "홍홍홍"],
      ["예금명", "외화정기예금"],
      ["신규계좌번호", "104368-11-027105"],
      ["신규통화", "CNY (중국 위안)"],
      ["신규금액", "1.00"],
      ["입금회차", "1"],
      ["예금이율", "0%"],
      ["적용과세", "일반"],
      ["만기일", "2025.12.07"],
      ["예치기간", "1개월"],
      ["출금계좌번호", "104302-04-412952"],
      ["출금통화", "KRW (한국 원)"],
      ["출금적용환율", "205.87"],
      ["출금금액", "205"],
      ["자동연장신청 여부", "아니오"],
      ["자동해지신청 여부", "예"],
      ["계약체결일시", "2025.11.07 13:44:56"],
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.mainPaleBlue.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: rows.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  row[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.pointDustyNavy,
                  ),
                ),
                Text(
                  row[1],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.pointDustyNavy.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // -------------------------------------------------
  // 하단 메인으로 이동 버튼
  // -------------------------------------------------
  Widget _bottomButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pointDustyNavy,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const BankHomePage()),
                (route) => false, // 기존 모든 화면 제거
          );
        },

        child: const Text(
          "메인으로 가기",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
