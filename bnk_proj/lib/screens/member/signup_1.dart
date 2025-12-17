import 'package:flutter/material.dart';
import 'package:test_main/screens/app_colors.dart';
import 'package:test_main/screens/member/signup_2.dart';

import '../../models/cust_info.dart';

class SignUp1Page extends StatefulWidget {
  const SignUp1Page({super.key});

  @override
  State<SignUp1Page> createState() => _SignUp1PageState();
}

class _SignUp1PageState extends State<SignUp1Page> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 키보드 높이 감지
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      // ⚠️ 중요: true로 두되, 아래 TextField가 영향을 덜 받도록 구조 변경
      resizeToAvoidBottomInset: false,
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
          // 1. 입력 폼 영역 (스크롤 가능하게 처리하여 키보드 대응)
          Positioned.fill(
            bottom: 80, // 버튼 공간 확보
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              // 키보드가 올라와도 내용이 올라가도록 하단 여백 추가
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
                  const SizedBox(height: 40),
                  const Text(
                    "이름",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  // 텍스트 필드
                  TextField(
                    controller: _nameController,
                    autofocus: true,
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

                  // 키보드만큼의 여백을 줘서 스크롤 가능하게 함
                  SizedBox(height: bottomInset),
                ],
              ),
            ),
          ),

          // 2. 하단 버튼 (키보드 위로 올라오도록 처리)
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomInset, // ✅ 키보드 높이만큼 버튼을 올림
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _nameController,
              builder: (context, value, child) {
                final isButtonEnabled = value.text.trim().isNotEmpty;
                return GestureDetector(
                  onTap: isButtonEnabled
                      ? () {
                    final name = value.text.trim();

                    final custInfo = CustInfo(
                      name: name
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SignUp2Page(custInfo: custInfo),
                      ),
                    );
                  }
                      : null,
                  child: Container(
                    color: isButtonEnabled
                        ? AppColors.pointDustyNavy
                        : const Color(0xFFE9ECEF),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    alignment: Alignment.center,
                    child: Text(
                      "다음",
                      style: TextStyle(
                        color: isButtonEnabled ? Colors.white : Colors.grey,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}