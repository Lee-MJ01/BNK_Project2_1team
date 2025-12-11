import 'package:flutter/material.dart';
import 'package:test_main/screens/app_colors.dart';
import 'step_2.dart';
import 'step_4.dart';

class DepositStep3Screen extends StatelessWidget {
  static const routeName = "/deposit-step3";

  const DepositStep3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        title: const Text("입력확인", style: TextStyle(color: Colors.white)),
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
              ["출금계좌", "104302-04-412952"],
              ["출금가능금액", "0원"],
              ["비밀번호 입력 여부", "입력완료"],
            ]),

            const SizedBox(height: 28),
            _sectionTitle("신규상품가입정보"),
            _infoCard([
              ["신규 통화", "USD"],
              ["신규 금액", "1.00"],
              ["가입기간", "1개월"],
            ]),

            const SizedBox(height: 28),
            _sectionTitle("만기자동연장"),
            _infoCard([
              ["자동연장 여부", "미신청"],
              ["연장 주기", "-"],
            ]),

            const SizedBox(height: 28),
            _sectionTitle("비밀번호 및 서류 수령방법"),
            _infoCard([
              ["정기예금 비밀번호", "입력완료"],
              ["상품서류 수령방법", "이메일"],
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
          onPressed: () {
            Navigator.pushNamed(context, DepositStep2Screen.routeName);
          },
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
          onPressed: () {
            Navigator.pushNamed(context, "/deposit-signature");
          },
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
}
