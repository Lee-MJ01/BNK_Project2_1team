import 'package:flutter/material.dart';
import 'forex_insight.dart';
import '../../services/exchange_service.dart';
import 'exchange_complete_page.dart';




class ExchangeBuyPage extends StatefulWidget {
  final CurrencyRate rate;

  const ExchangeBuyPage({
    super.key,
    required this.rate,
  });

  @override
  State<ExchangeBuyPage> createState() => _ExchangeBuyPageState();
}


class _ExchangeBuyPageState extends State<ExchangeBuyPage> {
  String foreignAmount = "1";

  int krwBalance = 0;
  bool isLoading = true;
  int foreignBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadMyAccounts();
  }

  Future<void> _loadMyAccounts() async {
    try {
      final data = await ExchangeService.fetchMyExchangeAccounts(
        currency: widget.rate.code,
      );

      setState(() {
        krwBalance = (data['krwBalance'] as num?)?.toInt() ?? 0;
        foreignBalance = (data['frgnBalance'] as num?)?.toInt() ?? 0; // ✅ 추가
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("계좌 조회 실패: $e")),
      );
    }
  }

  void _onKeyTap(String value) {
    setState(() {
      if (value == "back") {
        if (foreignAmount.isNotEmpty) {
          foreignAmount =
              foreignAmount.substring(0, foreignAmount.length - 1);
          if (foreignAmount.isEmpty) foreignAmount = "0";
        }
        return;
      }

      // 🔹 소수점 처리
      if (value == ".") {
        // 이미 소수점이 있으면 무시
        if (foreignAmount.contains(".")) return;

        // "0" 또는 빈 값이면 "0."
        if (foreignAmount.isEmpty || foreignAmount == "0") {
          foreignAmount = "0.";
        } else {
          foreignAmount += ".";
        }
        return;
      }

      // 🔹 숫자 처리
      if (foreignAmount == "0") {
        foreignAmount = value;
      } else {
        foreignAmount += value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double foreign = double.tryParse(foreignAmount) ?? 0;
    final int krwAmount = (foreign * widget.rate.rate).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FB),
      appBar: AppBar(
        title: Text("${widget.rate.code} 사기"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // 환율 텍스트
          Text(
            "1 ${widget.rate.code} = ${widget.rate.rate.toStringAsFixed(2)}원",
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),

          const SizedBox(height: 4),


          Text(
            '기준일: ${widget.rate.regDt}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black38,
            ),


          ),

          const SizedBox(height: 20), // ✅ 이거 추가



          const SizedBox(height: 20),

          // 외화 카드
          _currencyCard(
            flag: widget.rate.flagEmoji,
            title: widget.rate.name,
            amount: "$foreignAmount ${widget.rate.code}",
            isActive: true,
            balance: "잔액 $foreignBalance ${widget.rate.code}",
          ),

          const SizedBox(height: 12),

          // 스왑 아이콘
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                )
              ],
            ),
            child: const Icon(Icons.swap_vert),
          ),

          const SizedBox(height: 12),

          // KRW 카드
          _currencyCard(
            flag: "🇰🇷",
            title: "대한민국 원",
            amount: "$krwAmount KRW",
            isActive: false,
            balance: "잔액 ${krwBalance.toString()}원",
          ),

          const Spacer(),

          _keypad(),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final double foreign = double.tryParse(foreignAmount) ?? 0;
                    final int krwAmount = (foreign * widget.rate.rate).round();

                    // 1️⃣ 서버 환전 요청
                    await ExchangeService.buyForeignCurrency(
                      toCurrency: widget.rate.code,
                      krwAmount: krwAmount,
                    );

                    // 2️⃣ 환전 완료 화면으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExchangeCompletePage(
                          currency: widget.rate.code,
                          foreignAmount: foreign,
                          krwAmount: krwAmount,
                          appliedRate: widget.rate.rate,
                        ),
                      ),
                    );

                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("환전 실패: $e")),
                    );
                  }
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
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

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
              color: isActive ? Colors.blue : Colors.black54,
            ),
          ),
        ],
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
                  : Text(
                key,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          );
        },
      ),
    );
  }
}
