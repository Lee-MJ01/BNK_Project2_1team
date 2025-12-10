import 'package:flutter/material.dart';

class DepositViewPage extends StatelessWidget {
  final String title;

  const DepositViewPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xff22304E),
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xff22304E)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상품명
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xff22304E),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                "이 상품은 다양한 외화 통화를 쉽고 편리하게 관리할 수 있도록 설계된 외화 예금 상품입니다.\n"
                    "환율 우대, 입출금 편의성, 모바일 간편 가입 등의 장점을 제공합니다.",
                style: TextStyle(fontSize: 15, height: 1.7, color: Colors.black87),
              ),

              const SizedBox(height: 24),
              const Divider(),

              const Text(
                "가입조건",
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xff22304E),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              infoRow("가입 연령", "만 17세 이상"),
              infoRow("가입 채널", "모바일 / 영업점"),
              infoRow("가입 가능 통화", "USD, JPY, EUR 등 21개 통화"),
              infoRow("수익률", "환율에 따라 상이"),

              const SizedBox(height: 30),

              // 가입하기 버튼
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff22304E),
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "가입하기",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 15, color: Colors.black87)),
          Text(value,
              style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xff22304E),
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
