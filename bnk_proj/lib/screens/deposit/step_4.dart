import 'package:flutter/material.dart';
import 'package:test_main/screens/app_colors.dart';
import 'package:test_main/models/deposit/application.dart';
import 'package:test_main/screens/main/bank_homepage.dart';
import 'package:intl/intl.dart';

class DepositStep4Screen extends StatelessWidget {
  static const routeName = "/deposit-step4";

  final DepositCompletionArgs args;

  const DepositStep4Screen({super.key, required this.args});


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
    final result = args.result;
    final productName = result.productName.isNotEmpty
        ? result.productName
        : (args.application.product?.name ?? args.application.dpstId);

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
            image: const AssetImage("images/character10_without_white.png"),
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "${result.customerName}님의 $productName 가입이 완료되었습니다.",          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.pointDustyNavy,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          "신규 계좌번호 ${result.newAccountNo.isNotEmpty ? result.newAccountNo : '-'}",
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
    final result = args.result;
    final application = args.application;

    final formatter = NumberFormat.decimalPattern();

    final productName = result.productName.isNotEmpty
        ? result.productName
        : (application.product?.name ?? application.dpstId);

    final amountLabel = result.amount.isNotEmpty
        ? result.amount
        : (application.newAmount != null
        ? '${application.newCurrency} ${formatter.format(application.newAmount)}'
        : "-");

    final withdrawCurrency = result.withdrawCurrency ??
        (application.withdrawType == 'fx'
            ? (application.fxWithdrawCurrency ?? '-')
            : 'KRW');

    final rows = [



      ["고객명", result.customerName],
      ["예금명", productName],
      ["신규계좌번호", result.newAccountNo.isNotEmpty ? result.newAccountNo : "-"],
      ["신규통화", result.currency.isNotEmpty ? result.currency : application.newCurrency],
      ["신규금액", amountLabel],
      ["예금이율", result.rate ?? "확인중"],
      ["만기일", result.maturityDate ?? "-"],
      ["예치기간", result.periodLabel ??
          (application.newPeriodMonths != null
              ? "${application.newPeriodMonths}개월"
              : "-")],
      ["출금계좌번호",
        result.withdrawalAccount ??
            (application.withdrawType == 'fx'
                ? (application.selectedFxAccount ?? '-')
                : (application.selectedKrwAccount ?? '-'))],
      ["출금통화", withdrawCurrency],
      ["출금금액", result.withdrawAmount ?? "-"],
      ["자동연장신청 여부",
        result.autoRenewLabel ?? (application.autoRenew == 'apply' ? '예' : '아니오')],
      [
        "계약체결일시",
        result.contractDateTime != null
            ? result.contractDateTime!
            .replaceAll('T', ' ')
            .substring(0, 16)
            .replaceAll('-', '.')
            : "-"
      ],



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
