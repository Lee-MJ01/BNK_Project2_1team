// 파일 위치: lib/screens/remit/remit_done.dart
import 'package:flutter/material.dart';

import '../app_colors.dart';

class RemitDonePage extends StatelessWidget {
  final String name;   // 받는 사람 이름
  final String amount; // 보낸 금액 (포맷팅 된 문자열)

  const RemitDonePage({
    super.key,
    required this.name,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. 내용물을 중앙에 배치하기 위해 Spacer 사용
            const Spacer(),

            // 2. 캐릭터 이미지
            Image.asset(
              "images/character9.png",
              width: 320, // 이미지 크기 조절
              height: 320,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),

            // 3. 완료 텍스트
            Text(
              "${name}님에게",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pointDustyNavy, // 파란색 강조
                  ),
                ),
                const Text(
                  " 보냈어요",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 4. 계좌번호 (마스킹 처리됨)
            Text(
              "카카오뱅크 3333-**-*****",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                decoration: TextDecoration.underline, // 밑줄 스타일 (선택사항)
                decorationColor: Colors.grey[300],
              ),
            ),

            const Spacer(), // 하단 버튼을 바닥으로 밀어내기

            // 5. 확인 버튼
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // 확인 누르면 메인 화면(첫 화면)으로 돌아가기
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pointDustyNavy,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "확인",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}