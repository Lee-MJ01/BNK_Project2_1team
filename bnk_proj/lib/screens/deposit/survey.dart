import 'package:flutter/material.dart';
import 'package:test_main/screens/app_colors.dart';
import 'survey_result.dart';

class DepositSurveyScreen extends StatefulWidget {
  static const routeName = "/deposit-survey";

  const DepositSurveyScreen({super.key});

  @override
  State<DepositSurveyScreen> createState() => _DepositSurveyScreenState();
}

class _DepositSurveyScreenState extends State<DepositSurveyScreen> {
  int? q1, q2, q3, q4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pointDustyNavy,
        title: const Text(
          "외화예금 성향 테스트",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _header(),

            const SizedBox(height: 25),
            _questionCard(
              title: "1. 투자 목적이 무엇인가요?",
              options: [
                "단기 돈 관리 (1개월 내 운용)",
                "안정적으로 유지하면서 적당한 수익",
                "고수익을 위해 리스크 감수 가능",
              ],
              groupValue: q1,
              onChanged: (val) => setState(() => q1 = val),
            ),

            const SizedBox(height: 25),
            _questionCard(
              title: "2. 환율 변동에 대한 태도는?",
              options: [
                "손실 위험은 거의 원하지 않음",
                "어느 정도 변동은 괜찮음",
                "수익 위해 변동성도 감수 가능",
              ],
              groupValue: q2,
              onChanged: (val) => setState(() => q2 = val),
            ),

            const SizedBox(height: 25),
            _questionCard(
              title: "3. 납입 방식 선호는?",
              options: [
                "일시납(한 번에 예치)",
                "정기적립(매달 일정 금액)",
                "자유적립(원할 때마다)",
              ],
              groupValue: q3,
              onChanged: (val) => setState(() => q3 = val),
            ),

            const SizedBox(height: 25),
            _questionCard(
              title: "4. 선호 예치 기간은?",
              options: [
                "1~3개월 (단기)",
                "6~12개월 (중기)",
                "12개월 이상 (장기)",
              ],
              groupValue: q4,
              onChanged: (val) => setState(() => q4 = val),
            ),

            const SizedBox(height: 35),
            _submit(context),
          ],
        ),
      ),
    );
  }

  // -------------------------------
  // Intro Box UI
  // -------------------------------
  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.mainPaleBlue.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              "4개의 질문으로 고객님의 예금 성향을 분석하고\n"
                  "가장 적합한 외화 예금 상품을 추천해드립니다!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                fontWeight: FontWeight.w700,
                color: AppColors.pointDustyNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------
  // Question Card UI
  // -------------------------------
  Widget _questionCard({
    required String title,
    required List<String> options,
    required int? groupValue,
    required Function(int?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.mainPaleBlue.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.pointDustyNavy,
            ),
          ),
          const SizedBox(height: 14),

          ...List.generate(options.length, (i) {
            return RadioListTile(
              title: Text(
                options[i],
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.pointDustyNavy,
                ),
              ),
              value: i,
              groupValue: groupValue,
              activeColor: AppColors.pointDustyNavy,
              onChanged: onChanged,
              dense: true,
            );
          }),
        ],
      ),
    );
  }

  // -------------------------------
  // Submit Button
  // -------------------------------
  Widget _submit(BuildContext context) {
    final isFilled = q1 != null && q2 != null && q3 != null && q4 != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: !isFilled
            ? null
            : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SurveyResultScreen(
                resultType: _calculateType(),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
          isFilled ? AppColors.pointDustyNavy : Colors.grey.shade400,
          padding: const EdgeInsets.symmetric(vertical: 15),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          "결과 보기",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _calculateType() {
    int score = (q1 ?? 0) + (q2 ?? 0) + (q3 ?? 0) + (q4 ?? 0);

    if (score <= 3) return "안정형";
    if (score <= 7) return "균형형";
    return "적극투자형";
  }
}
