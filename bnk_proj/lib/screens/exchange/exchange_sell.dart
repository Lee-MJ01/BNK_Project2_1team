import 'package:flutter/material.dart';
import 'forex_insight.dart';

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

  @override
  Widget build(BuildContext context) {
    // 🔥 팔기: USD → KRW
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

          const SizedBox(height: 20),

          // USD 카드 (보유 달러)
          _currencyCard(
            flag: widget.rate.flagEmoji,
            title: widget.rate.name,
            amount: "$usdAmount ${widget.rate.code}",
            isActive: true,
            balance: "잔액 120 USD", // 👉 나중에 실제 데이터로 교체
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

          _keypad(),

          const SizedBox(height: 12),

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
          onPressed: () {
            // TODO: 팔기 로직
          },
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
