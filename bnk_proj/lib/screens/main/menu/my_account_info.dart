import 'package:flutter/material.dart';
import '../../app_colors.dart';

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
          side: const BorderSide(color: Color(0xFF3D5C9B)),
          minimumSize: const Size(0, 28),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: const Color(0xFF3D5C9B),
        ),
        child: const Text(
          '이체',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}