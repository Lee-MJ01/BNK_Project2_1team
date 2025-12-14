import 'dart:math';
import 'package:flutter/material.dart';

class RrnBackInputPage extends StatefulWidget {
  const RrnBackInputPage({super.key});

  @override
  State<RrnBackInputPage> createState() => _RrnBackInputPageState();
}

class _RrnBackInputPageState extends State<RrnBackInputPage> {
  String input = "";
  List<int> numbers = [];

  @override
  void initState() {
    super.initState();
    shuffleNumbers();
  }

  /// 1~9 랜덤배치 + 0은 마지막 줄 가운데 고정
  void shuffleNumbers() {
    numbers = List.generate(9, (i) => i + 1); // 1~9
    numbers.shuffle(Random());
  }

  void addNumber(int n) {
    if (input.length < 7) {
      setState(() {
        input += n.toString();
      });

      if (input.length == 7) {
        Future.delayed(const Duration(milliseconds: 150), () {
          Navigator.pop(context, input);
        });
      }
    }
  }

  void deleteNumber() {
    if (input.isNotEmpty) {
      setState(() {
        input = input.substring(0, input.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text("회원가입",
            style: TextStyle(color: Colors.black, fontSize: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              "주민등록번호 뒷자리",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(7, (index) {
                final filled = index < input.length;  // 입력된 부분인지 체크
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? Colors.black : Colors.grey,

                  ),
                );
              }),
            ),

            const Spacer(),

            // 🔥 숫자키패드
            Column(
              children: [
                // 1~9 랜덤 3줄
                for (int row = 0; row < 3; row++)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (int col = 0; col < 3; col++) ...[
                        Expanded(child: _buildKey(numbers[row * 3 + col])),
                        if (col != 2) const SizedBox(width: 8),
                      ],
                    ],
                  ),

                // 마지막 줄 : ↺ | 0 | 백스페이스
                Row(
                  children: [
                    Expanded(
                      child: _buildIconKey(
                        icon: Icons.refresh,
                        onTap: shuffleNumbers,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: _buildKey(0)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildIconKey(
                        icon: Icons.backspace_outlined,
                        onTap: deleteNumber,
                      ),
                    ),
                  ],
                ),

              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 숫자 키
  Widget _buildKey(int number) {
    return GestureDetector(
      onTap: () => addNumber(number),
      child: Container(
        height: 90, // 세로만 고정
        margin: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFEBF0F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            "$number",
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // 아이콘 키 (↺ / 백스페이스)
  Widget _buildIconKey({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 90,
        margin: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color:Color(0xFFEBF0F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Icon(icon, size: 30)),
      ),
    );
  }
}
