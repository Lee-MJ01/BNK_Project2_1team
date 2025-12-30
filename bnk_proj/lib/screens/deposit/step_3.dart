import 'package:flutter/material.dart';
import 'package:test_main/screens/app_colors.dart';

import 'package:test_main/models/deposit/application.dart';
import 'package:intl/intl.dart';
import 'package:test_main/services/deposit_draft_service.dart';

class DepositStep3Screen extends StatelessWidget {
  static const routeName = "/deposit-step3";

  final DepositApplication application;
  final DepositDraftService _draftService = DepositDraftService();

   DepositStep3Screen({
    super.key,
    required this.application,
  });


  @override
  Widget build(BuildContext context) {
    final productName = application.product?.name ?? application.dpstId;
    final formatter = NumberFormat.decimalPattern();

    final krwAmountLabel = _resolveKrwDepositAmountLabel(
      application,
      formatter,
    );

    final withdrawAccountLabel = application.withdrawType == "fx"
        ? (application.selectedFxAccount ?? "미입력")
        : (application.selectedKrwAccount ?? "미입력");

    final withdrawCurrencyLabel = application.withdrawType == "fx"
        ? (application.fxWithdrawCurrency ?? "미입력")
        : "KRW";

    final amountLabel = application.newAmount != null
        ? "${application.newCurrency} ${formatter.format(application.newAmount)}"
        : "미입력";

    final periodLabel = application.newPeriodMonths != null
        ? "${application.newPeriodMonths}개월"
        : "미입력";

    final rateLabel = _resolveRateLabel(application);
    final maturityLabel = _resolveMaturityLabel(application);

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        title: Text("$productName 입력확인", style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.pointDustyNavy,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildSteps(),

            const SizedBox(height: 30),
            _sectionTitle("출금계좌정보"),
            _infoCard([
              ["출금 구분", application.withdrawType == "fx" ? "외화출금계좌" : "원화출금계좌"],

              [
                "출금계좌",
                withdrawAccountLabel,
              ],

              ["출금통화", withdrawCurrencyLabel],
              ["비밀번호 입력 여부", application.withdrawPassword != null
                  ? "입력완료"
                  : "미입력"],
            ]),

            const SizedBox(height: 28),
            _sectionTitle("신규상품가입정보"),
            _infoCard([
              ["신규 통화", application.newCurrency.isNotEmpty
                  ? application.newCurrency
                  : "미입력"],
              ["신규 금액", amountLabel],
              ["원화 환산 금액", krwAmountLabel],
              ["가입기간", periodLabel],
              ["예금이율", rateLabel],
              ["만기일", maturityLabel],

            ]),

            const SizedBox(height: 28),
            _sectionTitle("만기자동연장"),
            _infoCard([
              ["자동연장 여부", application.autoRenew == "apply" ? "신청" : "미신청"],

              [
                "만기 자동 해지",
                application.autoTerminateAtMaturity
                    ? "예"
                    : "아니오",
              ],
            ]),



            const SizedBox(height: 28),
            _sectionTitle("비밀번호"),
            _infoCard([
              ["정기예금 비밀번호", application.depositPassword.isNotEmpty
                  ? "입력완료"
                  : "미입력"],
            ]),

            const SizedBox(height: 40),
            _buttons(context),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------
  // STEP UI
  // -----------------------------------------
  Widget _buildSteps() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepCircle("1", false),
        _divider(),
        _stepCircle("2", false),
        _divider(),
        _stepCircle("3", true),
      ],
    );
  }

  Widget _stepCircle(String num, bool active) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor:
          active ? AppColors.pointDustyNavy : AppColors.mainPaleBlue,
          child: Text(
            num,
            style: TextStyle(
              color: active ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          num == "1"
              ? "약관동의"
              : num == "2"
              ? "정보입력"
              : "입력확인",
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active
                ? AppColors.pointDustyNavy
                : AppColors.pointDustyNavy.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _divider() => Container(
    width: 40,
    height: 2,
    color: AppColors.mainPaleBlue,
    margin: const EdgeInsets.symmetric(horizontal: 10),
  );

  // -----------------------------------------
  // 섹션 제목
  // -----------------------------------------
  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.pointDustyNavy,
        ),
      ),
    );
  }

  // -----------------------------------------
  // 정보 카드
  // -----------------------------------------
  Widget _infoCard(List<List<String>> rows) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
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

  // -----------------------------------------
  // 버튼 UI
  // -----------------------------------------
  Widget _buttons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 이전 버튼
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mainPaleBlue,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "이전",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        // 가입하기 버튼
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.pointDustyNavy,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => _goToSignature(context),
          child: const Text(
            "가입하기",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _goToSignature(BuildContext context) async {
    await _draftService.saveDraft(
      application,
      step: 3,
      customerCode: application.customerCode,
    );

    if (!context.mounted) return;

    debugPrint('''
DepositApplication {
  dpstId: ${application.dpstId}
  customerCode: ${application.customerCode}
  withdrawType: ${application.withdrawType}
  selectedKrwAccount: ${application.selectedKrwAccount}
  selectedFxAccount: ${application.selectedFxAccount}
  fxWithdrawCurrency: ${application.fxWithdrawCurrency}
  newCurrency: ${application.newCurrency}
  newAmount: ${application.newAmount}
  newPeriodMonths: ${application.newPeriodMonths}
  appliedRate: ${application.appliedRate}
  appliedFxRate: ${application.appliedFxRate}
  depositPassword: ${application.depositPassword}
}
''');

    if (application.appliedRate == null){
      application.appliedRate = 0;
    }

    Navigator.pushNamed(
      context,
      "/deposit-signature",
      arguments: application,
    );
  }

  String _resolveRateLabel(DepositApplication application) {
    final rate = application.appliedRate;
    if (rate != null) {
      return "${rate.toStringAsFixed(2)}%";
    }

    return "확인중";
  }

  String _resolveMaturityLabel(DepositApplication application) {
    final maturity = application.dpstHdrFinDy;
    if (maturity != null && maturity.isNotEmpty) {
      final parsedMaturity = DateTime.tryParse(maturity);
      if (parsedMaturity != null) {
        return DateFormat('yyyy.MM.dd').format(parsedMaturity);
      }

      return maturity.replaceAll('-', '.');
    }

    if (application.newPeriodMonths != null) {
      final today = DateTime.now();
      final derived = DateTime(
        today.year,
        today.month + application.newPeriodMonths!,
        today.day,
      );

      return DateFormat('yyyy.MM.dd').format(derived);
    }

    return "-";
  }

  String _resolveKrwDepositAmountLabel(
      DepositApplication application,
      NumberFormat formatter,
      ) {
    final amount = application.newAmount?.toDouble();
    if (amount == null) return "미입력";

    final currency = application.newCurrency.toUpperCase();
    if (currency == "KRW" || currency.isEmpty) {
      return "KRW ${formatter.format(amount)}";
    }

    final rate = application.appliedFxRate;
    if (rate == null) return "미입력";

    final krwAmount = amount * rate;
    return "KRW ${formatter.format(krwAmount)}";
  }

}
