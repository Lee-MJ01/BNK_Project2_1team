import 'package:flutter/material.dart';
import '../../app_colors.dart';


// ✅ 외화자산(통화코드) -> 국기 이모지 매핑
// 환율 인사이트 화면에서 쓰던 flagEmoji와 동일한 이모지들을 그대로 사용합니다.
String _flagEmojiFor(String code) {
  final normalized = (code == 'CHN') ? 'CNY' : code;
  switch (normalized) {
    case 'KRW':
      return '🇰🇷';
    case 'USD':
      return '🇺🇸';
    case 'JPY':
      return '🇯🇵';
    case 'EUR':
      return '🇪🇺';
    case 'CNY':
      return '🇨🇳';
    case 'HKD':
      return '🇭🇰';
    case 'TWD':
      return '🇹🇼';
    case 'THB':
      return '🇹🇭';
    case 'SGD':
      return '🇸🇬';
    case 'PHP':
      return '🇵🇭';
    case 'GBP':
      return '🇬🇧';
    default:
      return '🏳️';
  }
}

class _FlagEmoji extends StatelessWidget {
  final String emoji;
  const _FlagEmoji(this.emoji);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04), // 밝은 배경
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}

// 보유 외화자산 상세 화면 //
class MyFxAssetScreen extends StatelessWidget {
  const MyFxAssetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: API로 교체
    final assets = const <_FxAsset>[
      _FxAsset(code: 'USD', nameKo: '미국 달러',   flagEmoji: '🇺🇸', amount: '\$ 1,000',   krwValue: '₩ 1,300,000'),
      _FxAsset(code: 'JPY', nameKo: '일본 엔',     flagEmoji: '🇯🇵', amount: '¥ 100,000',  krwValue: '₩ 900,000'),
      _FxAsset(code: 'EUR', nameKo: '유럽 유로',   flagEmoji: '🇪🇺', amount: '€ 5,000',    krwValue: '₩ 7,000,000'),
      _FxAsset(code: 'GBP', nameKo: '영국 파운드', flagEmoji: '🇬🇧', amount: '£ 2,000',    krwValue: '₩ 3,400,000'),
      _FxAsset(code: 'CHN', nameKo: '중국 위안',   flagEmoji: '🇨🇳', amount: '元 30,000',   krwValue: '₩ 500,000'),
      _FxAsset(code: 'AUD', nameKo: '호주 달러', flagEmoji: '🇦🇺', amount: '\$ 1,000,000', krwValue: '₩ 500,000')
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),

      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        children: [
          const Text(
            '외화자산을 한눈에 확인\n수수료 없는 환전',
            style: TextStyle(
              fontSize: 28,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 18),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assets.length,
            itemBuilder: (context, index) {
              final a = assets[index];
              return InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    children: [
                      _FlagEmoji(a.flagEmoji),
                      const SizedBox(width: 12),
                      // 좌측: 통화명/코드
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.nameKo,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 우측: 큰 금액 + 작은 보조
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            a.amount,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            a.krwValue,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FxAsset {
  final String code;      // USD
  final String nameKo;    // 미국 달러
  final String flagEmoji; // 🇺🇸
  final String amount;    // $ 1,000
  final String krwValue;  // ₩ 1,300,000

  const _FxAsset({
    required this.code,
    required this.nameKo,
    required this.flagEmoji,
    required this.amount,
    required this.krwValue,
  });
}
