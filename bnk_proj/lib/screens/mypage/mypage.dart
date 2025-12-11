import 'package:flutter/material.dart';
import '../app_colors.dart';
import 'package:test_main/screens/mypage/review_write.dart';

/// 마이페이지 메인 화면
class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundOffWhite,
        elevation: 0,
        leading: const BackButton(color: AppColors.pointDustyNavy),
        centerTitle: true,
        title: const Text(
          '마이페이지',
          style: TextStyle(
            color: AppColors.pointDustyNavy,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _MyPageUserSummary(),
            const SizedBox(height: 24),

            /// 1) 나의 계좌정보
            const _MyPageSection(
              title: '나의 계좌정보',
              description: '대표계좌 / 입출금계좌 요약',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const MyAccountInfoScreen(),
                  ),
                );
              },

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryRow(label: '대표 계좌', value: '123-456-789012'),
                  SizedBox(height: 8),
                  _SummaryRow(label: '원화 잔액', value: '1,235,000원'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            /// 2) 나의 외화예금
            const _MyPageSection(
              title: '나의 외화예금',
              description: '보유 중인 외화예금 상품 요약',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryRow(label: 'USD 예금', value: '3,200 USD'),
                  SizedBox(height: 8),
                  _SummaryRow(label: 'JPY 예금', value: '150,000 JPY'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            /// 3) 보유 외화자산
            const _MyPageSection(
              title: '보유 외화자산',
              description: '예금/지갑 등 전체 외화자산 합산',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryRow(label: '총 평가금액', value: '5,430,000원'),
                  SizedBox(height: 8),
                  _SummaryRow(label: '보유 통화 수', value: '3개'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// 4) 상품리뷰작성
            _MyPageSection(
              title: '상품 리뷰 작성',
              description: '만기된 외화상품에 대한 리뷰를 남겨주세요.',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  DepositReviewWriteScreen.routeName,
                );
              },
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryRow(label: '만기된 상품', value: 'FLOBANK 외화 예금'),
                  SizedBox(height: 8),
                  _SummaryRow(label: '리뷰 상태', value: '미작성'),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}

/// 상단 사용자 요약 카드
class _MyPageUserSummary extends StatelessWidget {
  const _MyPageUserSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.pointDustyNavy,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '홍길동 고객님',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pointDustyNavy,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '오늘도 안전하게 FLOBANK와 함께하세요.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 공통 섹션 카드 (제목 + 설명 + 내용)
class _MyPageSection extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;
  final VoidCallback? onTap;

  const _MyPageSection({
    super.key,
    required this.title,
    required this.description,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // 나중에 상세페이지 이동에 사용 가능
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 타이틀 + 화살표
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.pointDustyNavy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.pointDustyNavy,
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// 라벨/값 한 줄
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.pointDustyNavy,
          ),
        ),
      ],
    );
  }
}
class MyAccountInfoScreen extends StatelessWidget {
  const MyAccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 나중에 API 연동해서 실제 계좌 리스트로 교체
    final accounts = <_AccountSummary>[
      const _AccountSummary(
        name: '원화 입출금 통장',
        number: '123-456-789012',
        currency: 'KRW',
        balance: '1,235,000원',
      ),
      const _AccountSummary(
        name: '외화예금 (USD)',
        number: '245-111-998877',
        currency: 'USD',
        balance: '1,250 USD',
      ),
      const _AccountSummary(
        name: '외화예금 (JPY)',
        number: '987-222-333444',
        currency: 'JPY',
        balance: '230,000 JPY',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundOffWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.pointDustyNavy),
        centerTitle: true,
        title: const Text(
          '나의 계좌정보',
          style: TextStyle(
            color: AppColors.pointDustyNavy,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: accounts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final acc = accounts[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상품명
                Text(
                  acc.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pointDustyNavy,
                  ),
                ),
                const SizedBox(height: 6),
                // 계좌번호
                Text(
                  acc.number,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),
                // 잔액 + 통화 배지
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      acc.balance,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.pointDustyNavy,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        acc.currency,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AccountSummary {
  final String name;
  final String number;
  final String currency;
  final String balance;

  const _AccountSummary({
    required this.name,
    required this.number,
    required this.currency,
    required this.balance,
  });
}

