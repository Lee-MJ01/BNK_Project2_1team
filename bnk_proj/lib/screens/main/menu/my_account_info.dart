import 'package:flutter/material.dart';

class MyAccountInfoScreen extends StatefulWidget {
  const MyAccountInfoScreen({super.key});

  @override
  State<MyAccountInfoScreen> createState() => _MyAccountInfoScreenState();
}

class _MyAccountInfoScreenState extends State<MyAccountInfoScreen> {

  @override
  Widget build(BuildContext context) {
    final accounts = const <_AccountItem>[
      _AccountItem(
        name: '쌰@갈 통장',
        type: '입출금',
        number: '4444-44-44444',
        balanceText: '999,999원',
      ),
      _AccountItem(
        name: '아자스 통장',
        type: '입출금',
        number: '123-456-789012',
        balanceText: '111,235원',
      ),
      _AccountItem(
        name: '연봉 통장',
        type: '입출금',
        number: '123-456-789013',
        balanceText: '520원',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        surfaceTintColor: const Color(0xFFFFFFFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(25, 15, 25, 25),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Text(
                  '내 계좌',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              // IconButton(
              //   tooltip: _hideBalance ? '잔액 표시' : '잔액 가리기',
              //   onPressed: () => setState(() => _hideBalance = !_hideBalance),
              //   icon: Icon(
              //     _hideBalance ? Icons.visibility_off : Icons.visibility,
              //     color: Colors.black54,
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 30),

          // 요약 바 (총 n개)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFEF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      const TextSpan(text: '총 '),
                      TextSpan(
                        text: '${accounts.length}개',
                        style: const TextStyle(color: Color(0xFF2F6BFF)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          ...accounts.map((a) => _AccountCard(key: ValueKey(a.number),item: a,)),

          const SizedBox(height: 24),

          // 하단 링크 느낌
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('해지계좌', style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w600)),
              SizedBox(width: 12),
              Text('|', style: TextStyle(color: Colors.black26)),
              SizedBox(width: 12),
              Text('휴면예금', style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatefulWidget {
  const _AccountCard({
    super.key,
    required this.item,
  });

  final _AccountItem item;

  @override
  State<_AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<_AccountCard> {

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(18, 32, 18, 32), // ✅ 위/아래 크게(2배 느낌)
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 왼쪽 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${item.type} · ${item.number}',
                    style: const TextStyle(
                      color: Colors.black45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.balanceText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _AccountItem {
  final String name;
  final String type;
  final String number;
  final String balanceText;

  const _AccountItem({
    required this.name,
    required this.type,
    required this.number,
    required this.balanceText,
  });
}
