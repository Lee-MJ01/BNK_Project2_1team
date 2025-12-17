import 'package:flutter/material.dart';
import '../../app_colors.dart';

// 나의 외화예금 화면 //
class MyFxDepositScreen extends StatelessWidget {
  const MyFxDepositScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fxDeposits = const <_FxDeposit>[
      _FxDeposit(currencyCode: 'USD', productName: 'FLOBANK 외화정기예금', accountNo: '8888-72-0015-0001', balance: r'$ 1,000'),
      _FxDeposit(currencyCode: 'EUR', productName: 'FLOBANK 외화정기예금', accountNo: '8888-72-0809-0001', balance: '€ 10,000'),
      _FxDeposit(currencyCode: 'JPY', productName: 'FLOBANK 외화정기예금', accountNo: '8888-72-0016-0001', balance: '¥ 100,000'),
      // ...
    ];

    // ✅ 통화별 그룹핑
    final grouped = <String, List<_FxDeposit>>{};
    for (final d in fxDeposits) {
      grouped.putIfAbsent(d.currencyCode, () => <_FxDeposit>[]).add(d);
    }

    // ✅ 통화 순서 고정(원하면)
    const order = ['USD', 'EUR', 'JPY', 'GBP', 'CNY', 'AUD', 'CAD', 'CHF'];
    final keys = grouped.keys.toList()
      ..sort((a, b) {
        final ia = order.indexOf(a);
        final ib = order.indexOf(b);
        if (ia == -1 && ib == -1) return a.compareTo(b);
        if (ia == -1) return 1;
        if (ib == -1) return -1;
        return ia.compareTo(ib);
      });

    return Scaffold(
        backgroundColor: const Color(0xFFF5F6FA), // ✅ 밝은 배경
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              16, 16, 16, 16 + MediaQuery.of(context).padding.bottom,
            ),
            children: [
              // (원하면) 전체 요약 바는 딱 1번만
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEFEF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '총 ${fxDeposits.length}개',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF3D5C9B),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ✅ 통화별 섹션 + 해당 통화 카드만 출력
              for (final code in keys) ...[
                _CurrencySectionHeader(
                  code: code,
                  count: grouped[code]!.length,
                ),
                const SizedBox(height: 8),

                for (final fx in grouped[code]!) ...[
                  _FxDepositCompactTile(
                    item: fx,
                    onManage: () {},
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 8),
              ],
            ],
          ),
        )
    );
  }
}

class _CurrencySectionHeader extends StatelessWidget {
  const _CurrencySectionHeader({
    required this.code,
    required this.count,
  });

  final String code;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
          children: [
            TextSpan(text: code),
            const TextSpan(text: ' '),
            TextSpan(
              text: '$count',
              style: const TextStyle(
                color: Color(0xFFD32F2F), // ✅ 1번처럼 카운트만 강조(원하면 색 변경)
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FxDepositCompactTile extends StatelessWidget {
  const _FxDepositCompactTile({
    required this.item,
    required this.onManage,
  });

  final _FxDeposit item;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 왼쪽 빨간 원(1번 스샷 느낌)
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFD32F2F),
              shape: BoxShape.circle,
            ),
            child: const Text(
              'BNK',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // 가운데 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onManage,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        '관리',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.accountNo,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // 오른쪽 금액
          Text(
            item.balance,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}


/// 카드 1개 (원화계좌 UI 느낌으로 간소화)
class _FxDepositCard extends StatelessWidget {
  const _FxDepositCard({
    required this.item,
    required this.onView,
    required this.onDeposit,
  });

  final _FxDeposit item;
  final VoidCallback onView;
  final VoidCallback onDeposit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(18, 40, 18, 30),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: 상품명 / 잔액
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                item.balance,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 중단: 계좌번호
          Text(
            '계좌번호 · ${item.accountNo}',
            style: const TextStyle(
              color: Colors.black45,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 14),

          // 하단: 액션 버튼(오른쪽 정렬)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _ActionPillButton(label: '조회', onTap: onView),
              const SizedBox(width: 8),
              _ActionPillButton(label: '입금', onTap: onDeposit),
            ],
          ),
        ],
      ),
    );
  }
}

/// 외화예금 데이터
class _FxDeposit {
  final String currencyCode; // ✅ 추가 (USD, EUR, JPY...)
  final String productName;
  final String accountNo;
  final String balance;

  const _FxDeposit({
    required this.currencyCode,
    required this.productName,
    required this.accountNo,
    required this.balance,
  });
}


/// 조회 / 입금 작은 버튼
class _ActionPillButton extends StatelessWidget {
  const _ActionPillButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          minimumSize: const Size(0, 28),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: const Color(0xFF3D5C9B),
          side: const BorderSide(color: Color(0xFF3D5C9B)),
          shape: const StadiumBorder(),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
