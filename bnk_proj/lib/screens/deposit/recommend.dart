import 'package:flutter/material.dart';
import 'package:test_main/screens/deposit/survey.dart';
import 'package:test_main/screens/app_colors.dart';

class RecommendScreen extends StatelessWidget {
  static const routeName = "/recommend";

  const RecommendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pointDustyNavy,
        title: const Text(
          "AI 외화예금 추천",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(" 내 투자 성향 기반 추천"),
            _productCard(
              name: "BNK 모아드림 외화적금",
              desc: "장기 적립에 유리한 계단식 금리 구조.\n안정형·균형형 고객에게 적합.",
              rate: "연 3.30%",
              tag: "안정형 추천",
            ),
            const SizedBox(height: 20),

            _sectionTitle("최신 금리 기반 추천"),
            _productCard(
              name: "BNK 외화정기예금 (USD)",
              desc: "최근 금리 인상 반영.\n단기~중기 예치에 적합.",
              rate: "연 3.45%",
              tag: "금리 상승 상품",
            ),
            const SizedBox(height: 20),

            _sectionTitle("환율 트렌드 기반 추천"),
            _productCard(
              name: "BNK 글로벌 환테크 예금 (JPY)",
              desc: "엔저 구간 접근으로 매수 타이밍 유리.\n수익성 기반 AI 추천.",
              rate: "연 2.10%",
              tag: "환율 기반 추천",
            ),
            const SizedBox(height: 30),

            // ------------------------------------
            // 하단 버튼 - 성향 테스트 이동
            // ------------------------------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    DepositSurveyScreen.routeName,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pointDustyNavy,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "외화예금 성향 테스트 시작하기",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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

  // -----------------------------------------------------
  // Section Title
  // -----------------------------------------------------
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.pointDustyNavy,
        ),
      ),
    );
  }

  // -----------------------------------------------------
  // Product Card UI
  // -----------------------------------------------------
  Widget _productCard({
    required String name,
    required String desc,
    required String rate,
    required String tag,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.mainPaleBlue,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // 왼쪽 텍스트들
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pointDustyNavy,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mainPaleBlue.withOpacity(0.30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.pointDustyNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 오른쪽 금리 표시
          Column(
            children: [
              const Text("금리", style: TextStyle(fontSize: 13)),
              Text(
                rate,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointDustyNavy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
