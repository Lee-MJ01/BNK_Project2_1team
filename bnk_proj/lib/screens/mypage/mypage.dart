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
              description: '등록된 계좌 / 대표 계좌',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MyAccountInfoScreen(),
                  ),
                );
              },
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryRow(label: '등록된 계좌', value: '3개'),
                  SizedBox(height: 8),
                  _SummaryRow(label: '대표 계좌', value: '123-456-789012'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            /// 2) 나의 외화예금
            const _MyPageSection(
              title: '나의 외화예금',
              description: '보유 중인 외화예금 상품 요약',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MyFxDepositScreen(),
                  ),
                );
              },
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryRow(label: '외화예금 개수', value: '6개'),
                  SizedBox(height: 8),
                  _SummaryRow(label: '대표 통화', value: 'USD'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            /// 3) 보유 외화자산
            const _MyPageSection(
              title: '보유 외화자산',
              description: '예금/지갑 등 전체 외화자산 합산',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MyFxAssetScreen(),
                  ),
                );
              },
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryRow(label: '총 평가금액', value: '5,430,000원'),
                  SizedBox(height: 8),
                  _SummaryRow(label: '보유 통화 수', value: '6개'),
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
                  '방가방가.',
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
// 나의 계좌정보 화면 //
class MyAccountInfoScreen extends StatelessWidget {
  const MyAccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const headerStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.pointDustyNavy,
    );

    const cellStyle = TextStyle(
      fontSize: 13,
      color: Colors.black87,
    );

    // TODO: 나중에 실제 API로 교체
    final accounts = const <_AccountSummary>[
      _AccountSummary(
        name: '급여통장',
        accountNo: '123-456-789012',
        balance: '₩ 1,235,000',
      ),
      _AccountSummary(
        name: '생활비통장',
        accountNo: '123-456-789013',
        balance: '₩ 520,000',
      ),
      _AccountSummary(
        name: '적금통장',
        accountNo: '123-456-789014',
        balance: '₩ 3,000,000',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== 헤더 =====
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text('계좌명', style: headerStyle),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text('계좌번호', style: headerStyle),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('잔액', style: headerStyle),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text('이체', style: headerStyle),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ===== 데이터 행 =====
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: accounts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final acc = accounts[index];

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // 계좌명
                      Expanded(
                        flex: 3,
                        child: Text(
                          acc.name,
                          style: cellStyle.copyWith(
                            color: AppColors.pointDustyNavy,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // 계좌번호
                      Expanded(
                        flex: 3,
                        child: Text(
                          acc.accountNo,
                          style: cellStyle,
                        ),
                      ),
                      // 잔액
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            acc.balance,
                            style: cellStyle,
                          ),
                        ),
                      ),
                      // 이체 버튼
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: _TransferButton(
                              onTap: () {
                                // TODO: 이체 화면으로 이동
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 나의 계좌정보 한 줄 데이터
class _AccountSummary {
  final String name;       // 계좌명
  final String accountNo;  // 계좌번호
  final String balance;    // 잔액 (표시용 문자열)

  const _AccountSummary({
    required this.name,
    required this.accountNo,
    required this.balance,
  });
}

/// 이체 버튼
class _TransferButton extends StatelessWidget {
  final VoidCallback onTap;

  const _TransferButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          side: const BorderSide(color: Colors.grey),
          minimumSize: const Size(0, 28),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          '이체',
          style: TextStyle(
            fontSize: 11,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
// 나의 외화예금 화면 //
class MyFxDepositScreen extends StatelessWidget {
  const MyFxDepositScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 나중에 실제 API에서 불러오기
    final fxDeposits = const <_FxDeposit>[
      _FxDeposit(
        productName: 'FLOBANK 외화정기예금',
        accountNo: '8888-72-0014-0001',
        balance: '₩ 1,000,000',
      ),
      _FxDeposit(
        productName: 'FLOBANK 외화정기예금',
        accountNo: '8888-72-0015-0001',
        balance: '\$ 1,000',
      ),
      _FxDeposit(
        productName: 'FLOBANK 외화정기예금',
        accountNo: '8888-72-0016-0001',
        balance: '¥ 100,000',
      ),
      _FxDeposit(
        productName: 'FLOBANK 외화정기예금',
        accountNo: '8888-72-0809-0001',
        balance: '€ 10,000',
      ),
      _FxDeposit(
        productName: 'FLOBANK 외화정기예금',
        accountNo: '8888-72-0810-0001',
        balance: '£ 5,000',
      ),
      _FxDeposit(
        productName: 'FLOBANK 외화 거치식 정기예금',
        accountNo: '8888-76-0812-0001',
        balance: '元 30,000',
      ),
    ];

    const headerStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.pointDustyNavy,
    );

    const cellStyle = TextStyle(
      fontSize: 13,
      color: Colors.black87,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundOffWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.pointDustyNavy),
        centerTitle: true,
        title: const Text(
          '나의 외화예금',
          style: TextStyle(
            color: AppColors.pointDustyNavy,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== 헤더 영역 =====
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text('상품명', style: headerStyle),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text('계좌번호', style: headerStyle),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('잔액', style: headerStyle),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text('바로가기', style: headerStyle),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ===== 데이터 행들 =====
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: fxDeposits.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final fx = fxDeposits[index];

                return Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // 상품명
                      Expanded(
                        flex: 3,
                        child: Text(
                          fx.productName,
                          style: cellStyle.copyWith(
                            color: AppColors.pointDustyNavy,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // 계좌번호
                      Expanded(
                        flex: 3,
                        child: Text(
                          fx.accountNo,
                          style: cellStyle,
                        ),
                      ),

                      // 잔액
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            fx.balance,
                            style: cellStyle,
                          ),
                        ),
                      ),

                      // 바로가기 버튼 (조회 / 입금)
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.scaleDown, // 공간 안으로 알아서 축소
                            child: Row(
                              children: [
                                _FxActionButton(
                                  label: '조회',
                                  onTap: () {
                                    // TODO
                                  },
                                ),
                                const SizedBox(width: 4),
                                _FxActionButton(
                                  label: '입금',
                                  onTap: () {
                                    // TODO
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
// 보유 외화자산 상세 화면 //
class MyFxAssetScreen extends StatelessWidget {
  const MyFxAssetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const headerStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.pointDustyNavy,
    );

    const cellStyle = TextStyle(
      fontSize: 13,
      color: Colors.black87,
    );

    // TODO: 나중에 실제 API로 교체
    final assets = const <_FxAsset>[
      _FxAsset(currency: 'KRW', amount: '₩ 1,000,000', krwValue: '₩ 1,000,000'),
      _FxAsset(currency: 'USD', amount: '\$ 1,000', krwValue: '₩ 1,300,000'),
      _FxAsset(currency: 'JPY', amount: '¥ 100,000', krwValue: '₩ 900,000'),
      _FxAsset(currency: 'EUR', amount: '€ 5,000', krwValue: '₩ 7,000,000'),
      _FxAsset(currency: 'GBP', amount: '£ 2,000', krwValue: '₩ 3,400,000'),
      _FxAsset(currency: 'CHN', amount: '元 30,000', krwValue: '₩ 500,000'),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundOffWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.pointDustyNavy),
        centerTitle: true,
        title: const Text(
          '보유 외화자산',
          style: TextStyle(
            color: AppColors.pointDustyNavy,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text('통화', style: headerStyle),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text('보유 수량', style: headerStyle),
                  ),
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('원화 환산 금액', style: headerStyle),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 데이터 행
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: assets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final a = assets[index];
                return Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          a.currency,
                          style: cellStyle.copyWith(
                            color: AppColors.pointDustyNavy,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          a.amount,
                          style: cellStyle,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            a.krwValue,
                            style: cellStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FxAsset {
  final String currency;  // 통화 (USD 등)
  final String amount;    // 보유 수량
  final String krwValue;  // 원화 환산 금액

  const _FxAsset({
    required this.currency,
    required this.amount,
    required this.krwValue,
  });
}

/// 외화예금 한 줄 데이터
class _FxDeposit {
  final String productName;
  final String accountNo;
  final String balance;

  const _FxDeposit({
    required this.productName,
    required this.accountNo,
    required this.balance,
  });
}

/// 조회 / 입금 작은 버튼
class _FxActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FxActionButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          side: const BorderSide(color: Colors.grey),
          minimumSize: const Size(0, 28),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}


