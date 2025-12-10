import 'package:flutter/material.dart';

class SignUp1Page extends StatefulWidget {
  const SignUp1Page({super.key});

  @override
  State<SignUp1Page> createState() => _SignUp1PageState();
}

class _SignUp1PageState extends State<SignUp1Page> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소", style: TextStyle(color: Colors.black)),
          ),
        ],
        title: const Text("본인확인", style: TextStyle(color: Colors.black)),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                const Text(
                  "만나서 반가워요!\n고객님의 이름을 입력해주세요",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "이미 가입하셨어도 필요한 절차에요.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),

                const SizedBox(height: 40),

                const Text(
                  "이름",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),

                TextField(
                  controller: _nameController,
                  autofocus: true, // ✅ 클릭 없이 바로 키보드 표시
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.only(top: 8, bottom: 12),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF40578A), width: 2),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF40578A), width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                GestureDetector(
                  onTap: () {
                    // 본인 명의 휴대폰 아님 처리
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "본인명의 휴대폰이 아니에요",
                        style: TextStyle(fontSize: 14),
                      ),
                      Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// ✅ 하단 고정 "다음" 버튼 (키보드 위 자동 이동)
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomInset,
            child: Container(
              color: const Color(0xFFE9ECEF),
              padding: const EdgeInsets.symmetric(vertical: 18),
              alignment: Alignment.center,
              child: const Text(
                "다음",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
