import 'dart:async';

import 'package:flutter/material.dart';
import 'package:test_main/models/cust_info.dart';
import 'package:test_main/screens/app_colors.dart';
import 'package:test_main/screens/member/signup_17.dart';


class AccountVerifyConfirmPage extends StatefulWidget {
  const AccountVerifyConfirmPage({super.key,required this.bank, required this.accountNumber, required this.custInfo, });


  final String bank;
  final String accountNumber;
  final CustInfo custInfo;




  @override
  State<AccountVerifyConfirmPage> createState() =>
      _AccountVerifyConfirmPageState();
}

class _AccountVerifyConfirmPageState extends State<AccountVerifyConfirmPage> {
  final TextEditingController _codeController = TextEditingController();
  int remainSeconds = 5 * 60; // 4:52 예시
  Timer? _timer;

  bool get isFilled => _codeController.text.length == 6;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFakePush();
    });

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainSeconds <= 0) {
        timer.cancel();
      } else {
        setState(() {
          remainSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }


  void _showFakePush() {
    final overlay = Overlay.of(context);

    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: FakePushNotification(bank: widget.bank, accountNumber: widget.accountNumber, custInfo: widget.custInfo,),
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 2), () {
      entry.remove();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text("계좌인증", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소", style: TextStyle(color: Colors.black54)),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 24),

              const Text(
                "계좌인증",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 36),

              /// 은행
              const Text("입금은행/증권사",
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 6),
              _underlineText(widget.bank),

              const SizedBox(height: 28),

              /// 계좌번호
              const Text("계좌번호",
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 6),
              _underlineText(widget.accountNumber),

              const SizedBox(height: 20),

              /// 인증번호 요청 버튼 (비활성)
              Container(
                width: double.infinity,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "인증번호 요청",
                  style: TextStyle(color: Colors.black38, fontSize: 16),
                ),
              ),

              const SizedBox(height: 24),

              /// 1원 입금 안내 박스
              _depositGuide(),

              const SizedBox(height: 32),

              /// 인증번호 입력
              const Text("인증번호",
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 6),

              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "인증번호",
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                    BorderSide(color: AppColors.pointDustyNavy, width: 2),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                    BorderSide(color: AppColors.pointDustyNavy, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text(
                    "잔여시간 ${_formatTime(remainSeconds)}",
                    style: const TextStyle(color: Colors.blue),
                  ),
                ],
              ),

              const SizedBox(height: 60),


            ],
          ),
        ),
      ),

      bottomNavigationBar: GestureDetector(
        onTap: isFilled
            ? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AcctAgreementPage(custInfo: widget.custInfo,),
            ),
          );
        }
            : null,
        child: Container(
          height: 64,
          alignment: Alignment.center,
          color: isFilled
              ? AppColors.pointDustyNavy
              : Colors.grey.shade300,
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

    );
  }

  /// 밑줄 텍스트
  Widget _underlineText(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.pointDustyNavy, width: 2),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 1원 입금 안내
  Widget _depositGuide() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("입금자명",
                  style: TextStyle(fontSize: 13, color: Colors.black54)),
              Spacer(),
              Text("입금액",
                  style: TextStyle(fontSize: 13, color: Colors.black54)),
            ],
          ),
          SizedBox(height: 6),
          Row(
            children: [
              Container(

                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.mainPaleBlue,
                  borderRadius: BorderRadius.circular(4), // 은행 앱 느낌
                ),
                child: const Text(
                  "⁕ ⁕ ⁕ ⁕ ⁕ ⁕",
                  style: TextStyle(
                    fontSize: 22,

                    color: Colors.black,

                  ),
                ),
              ),
              Spacer(),
              Text("1원",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 12),
          Text(
            "${widget.bank} ${widget.accountNumber} 계좌로 1원을 입금해 드렸습니다. 입금메모에 표시된 숫자 6자리를 입력해주세요.",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString();
    final s = (sec % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }
}

class FakePushNotification extends StatelessWidget {
  final String bank;
  final String accountNumber;
  final CustInfo custInfo;

  const FakePushNotification({
    super.key,
    required this.bank,
    required this.accountNumber, required this.custInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 14,
                color: Colors.black.withOpacity(0.18),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.mainPaleBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.account_balance,
                  size: 25,
                  color: AppColors.pointDustyNavy,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$bank은행",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "1원이 입금되었습니다.",
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${_maskAccount(accountNumber)}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const Text(
                "방금",
                style: TextStyle(fontSize: 11, color: Colors.black38),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _maskAccount(String acc) {
    if (acc.length < 4) return acc;
    return "계좌 ${acc.substring(0, 4)}****";
  }
}
