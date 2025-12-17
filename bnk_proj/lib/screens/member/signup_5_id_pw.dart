import 'package:flutter/material.dart';
import 'package:test_main/models/cust_info.dart';
import 'package:test_main/screens/app_colors.dart';
import 'package:test_main/screens/member/signup_6.dart';

class LoginCredentialSetupPage extends StatefulWidget {
  final CustInfo custInfo;

  const LoginCredentialSetupPage({
    super.key, required this.custInfo,
  });

  @override
  State<LoginCredentialSetupPage> createState() =>
      _LoginCredentialSetupPageState();
}

class _LoginCredentialSetupPageState
    extends State<LoginCredentialSetupPage> {

  

  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _pwCheckController = TextEditingController();

  bool get isFilled =>
      _idController.text.length >= 6 &&
      _pwController.text.length >= 8 &&
      _pwController.text == _pwCheckController.text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: const Text(
          "회원가입",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "로그인 정보 설정",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "앞으로 FLOBANK 로그인에 사용됩니다.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // 아이디
                  const Text(
                    "아이디",
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _idController,
                    decoration: InputDecoration(
                      hintText: "영문 또는 숫자 6자 이상",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 24),

                  // 비밀번호
                  const Text(
                    "비밀번호",
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _pwController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "8자 이상 (영문/숫자/특수문자)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 16),

                  // 비밀번호 확인
                  const Text(
                    "비밀번호 확인",
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _pwCheckController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "비밀번호 재입력",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "※ 로그인용 비밀번호이며, 계좌 비밀번호와는 다릅니다.",
                    style: TextStyle(fontSize: 13, color: Colors.black45),
                  ),
                ],
              ),
            )
          ),
          

          // 하단 버튼
          SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFilled
                      ? AppColors.pointDustyNavy
                      : Colors.grey.shade300,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // ← 완전 직각
                  ),
                ),
                onPressed: isFilled
                    ? () {
                        // TODO
                        // 1. loginId + loginPw 서버 전송
                        // 2. 회원 생성 완료


                        widget.custInfo.id = _idController.text;
                        widget.custInfo.pw = _pwController.text;
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (_) => SignUp6Page(custInfo: widget.custInfo,))
                        );
                      }
                    : null,
                child: Text(
                  "다음",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isFilled ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ), 
          ),
        ],
      ),
    );
  }
}
