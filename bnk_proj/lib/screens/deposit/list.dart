import 'package:flutter/material.dart';
import 'package:test_main/screens/deposit/view.dart';
import 'package:test_main/screens/deposit/step_1.dart';
import 'package:test_main/screens/deposit/recommend.dart';
import 'package:test_main/screens/app_colors.dart';

class DepositListPage extends StatelessWidget {
  const DepositListPage({super.key});

  final List<Map<String, String>> products = const [
    {
      "title": "외화예금",
      "desc":
      "총 21개국 통화로 자유롭게 전환 가능하며, 고객이 지정한 환율로 처리되는 입출금형 외화예금 상품입니다.",
    },
    {
      "title": "예금2",
      "desc":
      "환율 우대 혜택과 함께 안정적인 외화 관리를 원하는 고객을 위한 상품입니다.",
    },
    {
      "title": "FLO 외화 스마트 예금",
      "desc":
      "모바일로 손쉽게 가입 가능한 외화 예금 상품으로 다양한 해외 통화를 지원합니다.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        title: const Text(
          "외화예금상품",
          style: TextStyle(
            color: AppColors.pointDustyNavy,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.subIvoryBeige,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.pointDustyNavy),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // AI 추천 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, RecommendScreen.routeName);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pointDustyNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "AI 외화예금 추천 받기",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              "조회결과 [총 ${products.length}건]",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView.separated(
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = products[index];

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.mainPaleBlue),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 상품명
                        Text(
                          item["title"]!,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.pointDustyNavy,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // 설명
                        Text(
                          item["desc"]!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            // 상세보기 버튼
                            OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DepositViewScreen(title: item["title"]!),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(90, 40),
                                side: const BorderSide(color: AppColors.pointDustyNavy),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text(
                                "상세보기",
                                style: TextStyle(
                                  color: AppColors.pointDustyNavy,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // 가입하기 버튼
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, DepositStep1Screen.routeName);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.pointDustyNavy,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(90, 40),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text(
                                "가입하기",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
