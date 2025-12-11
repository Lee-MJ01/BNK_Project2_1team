import 'package:flutter/material.dart';
import 'package:test_main/screens/app_colors.dart';
import '../deposit/recommend.dart';

class SurveyResultScreen extends StatelessWidget {
  static const routeName = "/survey-result";

  final String resultType;

  const SurveyResultScreen({
    super.key,
    required this.resultType,
  });

  // 성향별 강조 색상
  Color _typeColor() {
    switch (resultType) {
      case "안정형":
        return const Color(0xFF4C86A8);
      case "균형형":
        return const Color(0xFF2C5DE5);
      case "적극투자형":
        return const Color(0xFFE65C47);
      default:
        return AppColors.pointDustyNavy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pointDustyNavy,
        title: const Text(
          "외화예금 성향 분석 결과",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _resultHeader(),
            const SizedBox(height: 25),
            _resultDescription(),
            const Spacer(),
            _bottomButton(context),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // 상단 성향 결과 카드
  // -------------------------------------------------------
  Widget _resultHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.mainPaleBlue.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "회원님의 투자 성향은",
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: AppColors.pointDustyNavy.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            resultType,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: _typeColor(),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: _typeColor(),
              borderRadius: BorderRadius.circular(4),
            ),
          )
        ],
      ),
    );
  }

  // -------------------------------------------------------
  // 성향별 설명
  // -------------------------------------------------------
  Widget _resultDescription() {
    String desc;

    switch (resultType) {
      case "안정형":
        desc =
        "손실을 최소화하며 안정성을 가장 중요하게 생각합니다.\n"
            "단기·중기 외화예금 등 보수적 자산 운영이 적합합니다.";
        break;

      case "균형형":
        desc =
        "안정성과 수익성을 균형 있게 고려하는 성향입니다.\n"
            "USD·EUR 기반 분산 예금, 중기 상품이 적합합니다.";
        break;

      case "적극투자형":
        desc =
        "변동성을 감수하고 수익 극대화를 추구하는 성향입니다.\n"
            "금리 단계형 또는 이벤트 금리형 외화예금이 적합합니다.";
        break;

      default:
        desc = "";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mainPaleBlue.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        desc,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
          height: 1.6,
          color: AppColors.pointDustyNavy,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // 하단 이동 버튼
  // -------------------------------------------------------
  Widget _bottomButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, RecommendScreen.routeName);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pointDustyNavy,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: const Text(
          "AI 기반 외화예금 추천받기",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
