import 'package:flutter/material.dart';
import '../../app_colors.dart';

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
          side: const BorderSide(color: Color(0xFF3D5C9B)),
          minimumSize: const Size(0, 28),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: const Color(0xFF3D5C9B),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}