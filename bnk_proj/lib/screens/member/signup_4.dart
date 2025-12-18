import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_main/models/cust_info.dart';
import 'package:test_main/screens/app_colors.dart';
import 'package:test_main/screens/member/signup_5.dart';
import 'package:test_main/services/signup_service.dart';

class SignUp4Page extends StatefulWidget {
  const SignUp4Page({super.key,
    required this.custInfo});
  final CustInfo custInfo;

  @override
  State<SignUp4Page> createState() => _SignUp4PageState();
}

class _SignUp4PageState extends State<SignUp4Page> {
  final List<String> _code = ["", "", "", "", "", ""];
  final List<FocusNode> _focusNodes =
  List.generate(6, (_) => FocusNode());

  int remainingSeconds = 6 * 60 + 59; // 6:59
  Timer? timer;

  bool get isFilled =>
      _code.every((element) => element.isNotEmpty);

  @override
  void initState() {
    super.initState();
    _startTimer();
    _focusNodes.first.requestFocus();
  }

  @override
  void dispose() {
    timer?.cancel();
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        timer?.cancel();
      }
    });
  }

  String get timerText {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return "$m:${s.toString().padLeft(2, '0')}";
  }

  void _onNumberInput(int index, String value) {
    if (value.isEmpty) {
      setState(() => _code[index] = "");
      return;
    }

    setState(() => _code[index] = value);

    // 다음 칸으로 자동 이동
    if (index < 5) {
      _focusNodes[index + 1].requestFocus();
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
        title: const Text(
          "휴대폰 본인인증",
          style: TextStyle(color: Colors.black),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                "취소",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
            ),
          )
        ],
      ),

      body: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: _handleBackspace,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            const Text(
              "인증번호를 입력해주세요",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            // 인증번호 6자리 박스
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) {
                return Container(
                  width: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: TextField(
                    focusNode: _focusNodes[i],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: const InputDecoration(
                      counterText: "",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF40578A),
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (v) => _onNumberInput(i, v),
                  ),
                );
              }),
            ),

            const SizedBox(height: 12),

            // 타이머 + 다시받기
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    timerText,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  GestureDetector(
                    onTap: remainingSeconds == 0
                        ? () {
                      setState(() {
                        remainingSeconds = 6 * 60 + 59;
                        _startTimer();
                      });
                    }
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: remainingSeconds == 0
                            ? Colors.black.withOpacity(0.7)
                            : Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "다시받기",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            GestureDetector(
              onTap: () {},
              child: const Text(
                "인증번호가 오지않나요?",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            const Spacer(),

            // 확인 버튼
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: isFilled ? () async {
                  // ⛔ 타이머 만료 시 차단
                  if (remainingSeconds == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("인증 시간이 만료되었습니다. 다시 요청해주세요.")),
                    );
                    return;
                  }

                  final code = _code.join(); // "123456"

                  try {
                    final isVerified = await SignupService.verifyAuthCodeHp(
                      widget.custInfo.phone!,
                      code,
                    );

                    if (!mounted) return;

                    if (isVerified) {
                      _showSuccessDialog();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("인증번호가 올바르지 않습니다.")),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("인증 처리 중 오류가 발생했습니다.")),
                    );
                  }
                } : null,


                style: ElevatedButton.styleFrom(
                  backgroundColor: isFilled
                      ? AppColors.pointDustyNavy
                      : Colors.grey.shade300,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // 직사각형 모양!
                  ),
                ),
                child: Text(
                  "확인",
                  style: TextStyle(
                    fontSize: 18,
                    color: isFilled ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

  String get inputCode => _code.join();

  void _handleBackspace(RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {

      // 뒤에서 앞으로 찾음
      for (int i = 5; i >= 0; i--) {
        if (_code[i].isNotEmpty) {
          setState(() => _code[i] = "");

          // 해당 칸으로 포커스 이동
          _focusNodes[i].requestFocus();
          return;
        }
      }
    }
  }


  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 바깥 터치로 닫히지 않도록
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 30),

              const Text(
                "본인인증에 성공했습니다.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 30),

              // 확인 버튼 (남색)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pointDustyNavy,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // 팝업 닫기

                    // SignUp5 로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SignUp5Page(
                          custInfo : widget.custInfo
                        ),
                      ),
                    );
                  },
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
            ],
          ),
        );
      },
    );
  }


}
