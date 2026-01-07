import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart'; // 생체인증 패키지
import 'package:test_main/screens/auth/pin_login_screen.dart'; // 핀 화면 import
import 'package:test_main/screens/auth/pin_setup_screen.dart'; // 핀 설정 화면 import
import '../../services/exchange_service.dart'; // 환전 서비스
import '../../services/api_service.dart'; // API 서비스 (PIN 여부 확인용)
import 'forex_insight.dart';
import 'package:local_auth/local_auth.dart';

class ExchangeSellPage extends StatefulWidget {
  final CurrencyRate rate;

  const ExchangeSellPage({
    super.key,
    required this.rate,
  });

  @override
  State<ExchangeSellPage> createState() => _ExchangeSellPageState();
}

class _ExchangeSellPageState extends State<ExchangeSellPage> {
  String usdAmount = "1";

  final LocalAuthentication auth = LocalAuthentication();

  void _onKeyTap(String value) {
    setState(() {
      if (value == "back") {
        if (usdAmount.isNotEmpty) {
          usdAmount = usdAmount.substring(0, usdAmount.length - 1);
          if (usdAmount.isEmpty) usdAmount = "0";
        }
        return;
      }

      // 🔹 소수점 처리
      if (value == ".") {
        // 이미 소수점이 있으면 무시
        if (usdAmount.contains(".")) return;

        // "0"이거나 비어있으면 "0."
        if (usdAmount == "0" || usdAmount.isEmpty) {
          usdAmount = "0.";
        } else {
          usdAmount += ".";
        }
        return;
      }

      // 🔹 숫자 입력
      if (usdAmount == "0") {
        usdAmount = value;
      } else {
        usdAmount += value;
      }
    });
  }

  // 통합 인증 및 환전 실행 로직
  Future<void> _handleAuthAndSell() async {
    // 0. 금액 검증
    if (usdAmount.isEmpty || double.parse(usdAmount) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("판매할 금액을 입력해주세요.")),
      );
      return;
    }

    // 1. PIN 등록 여부 확인 (API 필요)
    bool hasPin = await ApiService.checkHasPin(); // 실제 구현 시 주석 해제

    if (!hasPin) {
      // PIN이 없으면 생성 화면으로 이동
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("보안을 위해 간편비밀번호 설정이 필요합니다.")),
      );

      // PinSetupScreen으로 이동 (구현되어 있다고 가정)
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PinSetupScreen(userId: "user123")), // 실제 ID 넣기
      );
      return;
    }

    // 2. 생체 인증 시도
    bool authenticated = false;
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      if (canCheckBiometrics) {
        authenticated = await auth.authenticate(
          localizedReason: '환전을 진행하려면 인증해주세요.',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
      }
    } catch (e) {
      print("생체 인증 실패 또는 미지원: $e");
      // 생체 인증 오류 시 무시하고 PIN으로 넘어감
    }

    // 3. 생체 인증 실패 시 -> PIN 인증 화면으로 이동
    if (!authenticated) {
      if (!mounted) return;
      // isAuthMode: true로 설정하여 결과를 받아옴
      final bool? pinResult = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PinLoginScreen(
            userId: "user123", // 실제 사용자 ID (Provider나 Storage에서 가져오기)
            isAuthMode: true,  // ★ 인증 모드 활성화
          ),
        ),
      );

      if (pinResult != true) {
        // PIN 인증 취소 또는 실패
        return;
      }
    }

    // 4. 인증 성공 (생체 or PIN) -> 환전 실행
    _executeSell();
  }

  // 실제 환전 API 호출 함수
  Future<void> _executeSell() async {
    try {
      int sellAmount = double.parse(usdAmount).toInt();

      await ExchangeService.sellForeignCurrency(
        fromCurrency: widget.rate.code,
        frgnAmount: sellAmount,
      );

      if (!mounted) return;
      // 성공 알림
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("환전 성공"),
          content: Text("$sellAmount ${widget.rate.code}를 원화로 환전했습니다."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
                Navigator.pop(context); // 화면 닫기
              },
              child: const Text("확인"),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("환전 실패: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 팔기: USD → KRW
    final int krwAmount =
    ((double.tryParse(usdAmount) ?? 0) * widget.rate.rate).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FB),
      appBar: AppBar(
        title: Text('${widget.rate.code} 팔기'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // 환율
          Text(
            '1 ${widget.rate.code} = ${widget.rate.rate.toStringAsFixed(2)}원',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),

          const SizedBox(height: 4),

          Text(
            '(${widget.rate.regDt} 기준)',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 20),

          // USD 카드 (보유 달러)
          _currencyCard(
            flag: widget.rate.flagEmoji,
            title: widget.rate.name,
            amount: "$usdAmount ${widget.rate.code}",
            isActive: true,
            balance: "잔액 120 USD",
          ),

          const SizedBox(height: 12),

          // 스왑 아이콘
          _swapIcon(),

          const SizedBox(height: 12),

          // KRW 카드 (받을 금액)
          _currencyCard(
            flag: "🇰🇷",
            title: "대한민국 원",
            amount: "$krwAmount KRW",
            isActive: false,
            balance: "입금 예정",
          ),

          const Spacer(),

          // 1. 키패드 표시
          _keypad(),

          const SizedBox(height: 16), // 간격 조절

          // 2. 법적 고지 문구
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "확인을 누르면 환전 유의사항에 동의한 것으로 간주합니다.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 12), // 문구와 버튼 사이 간격

          // 3. 확인 버튼 호출
          _confirmButton(),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ================= 공통 UI =================

  Widget _currencyCard({
    required String flag,
    required String title,
    required String amount,
    required String balance,
    required bool isActive,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                balance,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          const Spacer(),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.redAccent : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // 약관 동의 다이얼로그
  Future<bool?> _showTermsDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // 바깥 클릭해서 닫기 방지
      builder: (context) => AlertDialog(
        title: const Text("환전 서비스 약관 동의"),
        content: const SingleChildScrollView(
          child: ListBody(
            children: [
              Text("비대면 외화 환전 서비스를 이용하기 위해 최초 1회 약관 동의가 필요합니다."),
              SizedBox(height: 10),
              Text(
                "제1조 (목적)\n본 약관은 고객이 모바일 앱을 통해 외화를 환전함에 있어...",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              // 필요한 약관 내용을 더 추가하세요
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // 거부
            child: const Text("취소"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // 동의
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F5073),
            ),
            child: const Text("동의합니다", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _swapIcon() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: const Icon(Icons.swap_vert),
    );
  }

  Widget _confirmButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _handleAuthAndSell,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3F5073),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            "확인",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _keypad() {
    final keys = [
      "1","2","3",
      "4","5","6",
      "7","8","9",
      ".", "0", "back",
    ];



    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.2,
        ),
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final key = keys[index];
          return GestureDetector(
            onTap: () => _onKeyTap(key),
            child: Center(
              child: key == "back"
                  ? const Icon(Icons.backspace_outlined)
                  : Text(key, style: const TextStyle(fontSize: 20)),
            ),
          );
        },
      ),
    );
  }
}
