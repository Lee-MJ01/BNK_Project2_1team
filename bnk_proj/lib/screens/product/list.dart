import 'package:flutter/material.dart';
import 'view.dart';

class DepositListPage extends StatelessWidget {
  const DepositListPage({super.key});

  final List<Map<String, String>> products = const [
    {
      "title": "SOL트래블 외화예금",
      "desc":
      "총 21개국 통화로 자유롭게 전환 가능하며, 고객이 지정한 환율로 처리되는 입출금형 외화예금 상품입니다.",
    },
    {
      "title": "외화 체인지업 예금",
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
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        title: const Text(
          "외화예금상품",
          style: TextStyle(
            color: Color(0xff22304E),
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xff22304E)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "조회결과 [총 ${products.length}건]",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // 리스트
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
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["title"]!,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff22304E),
                          ),
                        ),
                        const SizedBox(height: 6),
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
                                    builder: (_) =>
                                        DepositViewPage(title: item["title"]!),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(90, 40),
                                side: const BorderSide(color: Color(0xff22304E)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text(
                                "상세보기",
                                style: TextStyle(
                                  color: Color(0xff22304E),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // 가입하기 버튼
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff22304E),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(90, 40),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                surfaceTintColor: Colors.transparent,
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
