import 'package:flutter/material.dart';
import '../app_colors.dart';
import 'package:test_main/screens/main/menu/review_write.dart';

import 'menu/my_account_info.dart';
import 'menu/my_fx_deposit.dart';
import 'menu/my_fx_asset.dart';
import 'menu/review_write.dart';

/// 마이페이지 메인 화면
class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   backgroundColor: AppColors.backgroundOffWhite,
      //   elevation: 0,
      //   leading: const BackButton(color: AppColors.pointDustyNavy),
      //   centerTitle: true,
      //   title: const Text(
      //     '마이페이지',
      //     style: TextStyle(
      //       color: AppColors.pointDustyNavy,
      //       fontWeight: FontWeight.w700,
      //     ),
      //   ),
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(height: 60),
            _MyPageUserSummary(),
            SizedBox(height: 10),
            _MyPageShortcutGrid(),
            SizedBox(height: 34),
            // 필요하면 여기 아래에 다른 내용(배너, 추천 카드 등) 추가
          ],
        ),
      ),
    );
  }
}
/// ✅ Drawer(오른쪽 슬라이드)로 띄울 마이페이지 내용
class MyPageDrawer extends StatelessWidget {
  const MyPageDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ 닫기 버튼 (오른쪽 상단)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context), // drawer 닫기
                  ),
                ],
              ),


              const SizedBox(height: 10),


              const _MyPageUserSummary(),
              const SizedBox(height: 10),
              const _MyPageShortcutGrid(),
              SizedBox(
                width: double.infinity,           // ✅ 가로 꽉
                child: Image.asset(
                  'images/character_ant.png',
                  fit: BoxFit.fitWidth,           // ✅ 가로에 맞춰 꽉
                ),
              ),

              const _AllMenuSectionList(),

              const SizedBox(height: 16),
              const Divider(height: 1),

              Padding(
                padding: const EdgeInsets.only(right: 16, top: 10, bottom: 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login',
                            (route) => false,
                      );
                      // LoginPage로 가는 방식이면 여기만 너 코드로 교체
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 28), // ✅ 작게
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      shape: const StadiumBorder(),   // ✅ 알약 모양
                      side: const BorderSide(color: Color(0xFFDDDDDD)), // 테두리 연하게
                      foregroundColor: Colors.black87,
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('로그아웃'),
                  ),
                ),
              ),


              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// 상단 사용자 요약 카드
class _MyPageUserSummary extends StatelessWidget {
  const _MyPageUserSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 8.0),
      //  left:12, top:0, right:12, bottom:8
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 왼쪽: 홍길동 >
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MyProfileScreen(),
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  '홍길동',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pointDustyNavy,
                  ),
                ),
                SizedBox(width: 1),
                Icon(
                  Icons.chevron_right,
                  size: 22,
                  color: Colors.black38,
                ),
              ],
            ),
          ),

          // 오른쪽: 환경설정
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MySettingsScreen(),
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.settings_outlined,
                  size: 22,
                  color: Colors.black54,
                ),
                SizedBox(width: 4),
                Text(
                  '설정',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
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



class _MyPageShortcutGrid extends StatelessWidget {
  const _MyPageShortcutGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final shortcuts = <_ShortcutItem>[
      _ShortcutItem(
        icon: Icons.account_balance_wallet_outlined,
        label: '내 원화계좌',
        hasBadge: true,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const MyAccountInfoScreen(),
            ),
          );
        },
      ),
      _ShortcutItem(
        icon: Icons.savings_outlined,
        label: '나의 외화예금',
        hasBadge: false,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const MyFxDepositScreen(),
            ),
          );
        },
      ),
      _ShortcutItem(
        icon: Icons.pie_chart_outline,
        label: '보유 외화자산',
        hasBadge: false,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const MyFxAssetScreen(),
            ),
          );
        },
      ),
      _ShortcutItem(
        icon: Icons.rate_review_outlined,
        label: '상품 리뷰 작성',
        hasBadge: false,
        onTap: () {
          Navigator.pushNamed(
            context,
            DepositReviewWriteScreen.routeName,
          );
        },
      ),
      _ShortcutItem(
        icon: Icons.verified_outlined,
        label: '내 신용정보',
        hasBadge: true,
        onTap: () {},
      ),
      _ShortcutItem(
        icon: Icons.badge_outlined,
        label: '모바일 신분증',
        hasBadge: false,
        onTap: () {},
      ),
      _ShortcutItem(
        icon: Icons.campaign_outlined,
        label: '공지사항',
        hasBadge: true,
        onTap: () {},
      ),
      _ShortcutItem(
        icon: Icons.lock_outline,
        label: '인증/보안',
        hasBadge: false,
        onTap: () {},
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shortcuts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 18,
        crossAxisSpacing: 18,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final item = shortcuts[index];
        return _ShortcutIconButton(item: item);
      },
    );
  }
}
class _AllMenuSectionList extends StatelessWidget {
  const _AllMenuSectionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _MenuSection(
          title: '외화예금',
          items: [
            _MenuItem('외화예금상품'),
            _MenuItem('외화예금안내'),
          ],
        ),
        _MenuSection(
          title: '외화송금',
          items: [
            _MenuItem('외화송금하기'),
            _MenuItem('외화송금안내'),
          ],
        ),
        _MenuSection(
          title: '환전',
          items: [
            _MenuItem('환전하기'),
            _MenuItem('환전 가능 통화'),
            _MenuItem('환전안내'),
          ],
        ),
        _MenuSection(
          title: '환율',
          items: [
            _MenuItem('환율조회'),
            _MenuItem('환전계산기'),
          ],
        ),
        _MenuSection(
          title: '고객센터',
          items: [
            _MenuItem('flobank소개'),
            _MenuItem('QnA'),
            _MenuItem('FAQ'),
            _MenuItem('이벤트'),
            _MenuItem('공지사항'),
            _MenuItem('뉴스리스트'),
          ],
        ),
      ],
    );
  }
}

class _MenuItem {
  final String label;
  final VoidCallback? onTap;
  final String? midAsset;
  const _MenuItem(this.label, {this.onTap, this.midAsset});
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ 타이틀: 작게/연하게
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),

          // ✅ 항목: 개별 둥근 타일로 쭉
          ...items.map((it) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _MenuRow(
              label: it.label,
              onTap: it.onTap ?? () {},
              leadingIcon: _iconForLabel(it.label),
              midAsset: it.midAsset,
              badge: null, // 필요하면 'Beta'/'신규' 넣어
            ),
          )),
        ],
      ),
    );
  }

  static IconData _iconForLabel(String label) {
    if (label.contains('예금')) return Icons.savings_outlined;
    if (label.contains('송금')) return Icons.send_outlined;
    if (label.contains('환전')) return Icons.currency_exchange_outlined;
    if (label.contains('환율')) return Icons.show_chart_outlined;
    if (label.contains('계산기')) return Icons.calculate_outlined;
    if (label.contains('QnA') || label.contains('FAQ')) return Icons.help_outline;
    if (label.contains('공지')) return Icons.campaign_outlined;
    if (label.contains('뉴스')) return Icons.article_outlined;
    if (label.contains('이벤트')) return Icons.celebration_outlined;
    return Icons.circle_outlined;
  }
}


class _MenuRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData leadingIcon;
  final String? badge;
  final String? midAsset;

  const _MenuRow({
    required this.label,
    required this.onTap,
    required this.leadingIcon,
    this.badge,
    this.midAsset,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,                     // ✅ 흰색
          borderRadius: BorderRadius.circular(16), // ✅ 둥글게
        ),
        child: Row(
          children: [
            // ✅ 좌측 아이콘 원형
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFFF6F7F8),          // 아이콘 배경만 살짝 회색
                shape: BoxShape.circle,
              ),
              child: Icon(leadingIcon, size: 16, color: Colors.black87),
            ),
            const SizedBox(width: 12),

            if (midAsset != null) ...[
              Image.asset(
                midAsset!,
                width: 22,
                height: 22,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
            ],

            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),

            if (badge != null) _BadgeChip(badge!),

            // ✅ chevron(>) 제거
          ],
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String text;
  const _BadgeChip(this.text);

  @override
  Widget build(BuildContext context) {
    final isNew = text == '신규';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isNew ? const Color(0xFFFFEBEE) : const Color(0xFFEFF1F3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isNew ? const Color(0xFFD32F2F) : Colors.black87,
        ),
      ),
    );
  }
}


class _ShortcutIconButton extends StatelessWidget {
  final _ShortcutItem item;

  const _ShortcutIconButton({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: item.onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 둥근 카드 + 아이콘 + 뱃지
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.black.withOpacity(0.06),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    item.icon,
                    size: 30,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (item.hasBadge)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ShortcutItem {
  final IconData icon;
  final String label;
  final bool hasBadge;
  final VoidCallback? onTap;

  const _ShortcutItem({
    required this.icon,
    required this.label,
    required this.hasBadge,
    this.onTap,
  });
}


/// 공통 섹션 카드 (제목 + 설명 + 내용)
class _MyPageSection extends StatelessWidget {
  final String title;
  final String description;
  final Widget? child;          // ⬅️ nullable 로 변경
  final VoidCallback? onTap;

  const _MyPageSection({
    super.key,
    required this.title,
    required this.description,
    this.child,                 // ⬅️ 선택값
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final contentWidgets = <Widget>[
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
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pointDustyNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: Colors.black38,
            ),
        ],
      ),
    ];

    if (child != null) {
      contentWidgets.add(const SizedBox(height: 12));
      contentWidgets.add(child!);
    }

    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: contentWidgets,
      ),
    );

    if (onTap == null) {
      return card;
    }
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: card,
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


class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundOffWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.pointDustyNavy),
        centerTitle: true,
        title: const Text(
          '개인정보',
          style: TextStyle(
            color: AppColors.pointDustyNavy,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          '개인정보 화면 (추후 구현 예정)',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
    );
  }
}
class MySettingsScreen extends StatelessWidget {
  const MySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundOffWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.pointDustyNavy),
        centerTitle: true,
        title: const Text(
          '환경설정',
          style: TextStyle(
            color: AppColors.pointDustyNavy,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          '환경설정 화면 (추후 구현 예정)',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}



