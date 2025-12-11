import 'package:flutter/material.dart';
import 'package:test_main/screens/product/list.dart';
import '../app_colors.dart';
import '../../main.dart';
import '../mypage/transaction_history.dart';

import '../remit/remit_step1.dart';

import '../mypage/mypage.dart';
import '../exchange/forex_insight.dart';





class BankHomePage extends StatefulWidget {
  const BankHomePage({super.key});

  @override
  State<BankHomePage> createState() => _BankHomePageState();
}

class _BankHomePageState extends State<BankHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          elevation: 6,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          onPressed: () {
            print("챗봇 이동");
          },
          child: SizedBox.expand(
            child: Image.asset(
              "images/chatboticon.png",
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6FB),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: CircleAvatar(
            backgroundColor: const Color(0xFF3C4F76),
            child: const Icon(Icons.pets, color: Colors.white), // 은행 로고 대용
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black87),
              onPressed: () {
                Scaffold.of(context).openEndDrawer(); // ✅ 오른쪽 슬라이드 메뉴
              },
            ),
          ),
        ],
      ),

      /// ✅ 오른쪽 슬라이드 메뉴 (햄버거 메뉴)
      endDrawer: Drawer(
        child: Column(
          children: [
            Container(
              height: 160,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              alignment: Alignment.bottomLeft,
              color: const Color(0xFF3C4F76),
              child: const Text(
                "홍길동님\n환영합니다",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("마이페이지"),
              onTap: () {
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text("거래내역"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.send),
              title: const Text("외화송금"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.currency_exchange),
              title: const Text("환율"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ExchangeRateScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text("고객센터"),
              onTap: () {},
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("로그아웃"),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),

      /// ✅ 하단 네비
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i == 3) { // 마이페이지 탭
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MyPageScreen(),
              ),
            );
            return;
          }

          setState(() => _currentIndex = i);
        },
        selectedItemColor: const Color(0xFF3C4F76),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "거래내역"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "외화상품"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "마이페이지"),
        ],
      ),

      /// ✅ 메인 바디
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [

              const _AccountCard(),

              /// ✅ 상단 계좌 카드
              /*
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF44449E), Color(0xFF484A9C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("대표계좌", style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 4),
                    Text("110-480-691488",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 14),
                    Text("438,467원",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold)),
                  ],
                ),


              ),

              const SizedBox(height: 14),


              /// ✅ 조회 / 이체 버튼
              Row(
                children: [
                  _ActionButton("조회", Icons.search, () {}),
                  const SizedBox(width: 12),
                  _ActionButton("이체", Icons.swap_horiz, () {}),
                ],
              ),

             */

              const SizedBox(height: 22),

              /// ✅ 퀵메뉴 (환전 / 환율 / 외화예금 / 외화송금)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                childAspectRatio: 0.9,
                children: [
                  _QuickMenu("환전", "images/flobankicon1.png"),
                  _QuickMenu(
                    "환율",
                    "images/flobankicon2.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ExchangeRateScreen(),
                        ),
                      );
                    },
                  ),
                  _QuickMenu(
                    "외화예금",
                    "images/flobankicon3.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DepositListPage(),
                        ),
                      );
                    },
                  ),
                  _QuickMenu("외화송금", "images/flobankicon4.png"),
                ],
              ),



              //const SizedBox(height: 10),

              /// ✅ 실시간 환율 배너
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForexInsightScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "오늘의 실시간 환율",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),


              const _RateSection(),
              const SizedBox(height: 24),

              /// ✅ AI & 외환 서비스 타이틀
              _SectionTitle(
                title: 'AI & 외환 서비스',
                actionText: '더 알아보기',
                onTap: () {},
              ),

              const SizedBox(height: 8),

              /// ✅ AI & 외환 서비스 리스트
              _ServiceList(services: aiAndFxServices),
            ],
          ),
        ),
      ),
    );
  }
}

/// ✅ 상단 버튼
Widget _ActionButton(String text, IconData icon, VoidCallback onTap) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 6),
            Text(text),
          ],
        ),
      ),
    ),
  );
}



//////////////////
// 🔵 환율 박스 (USD / JPY / EUR / CNY) — 헤더 포함 버전
////////////////////////////////////////////////////////////////////////////////
class _RateSection extends StatelessWidget {
  const _RateSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // ✅ 전체 중앙
        children: [
          const Text(
            "환율 정보",
            textAlign: TextAlign.center,               // ✅ 제목 중앙
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // ✅ 헤더 중앙 정렬
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 50,
                child: Center(
                  child: Text(
                    "통화",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "매매기준율",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "송금받을 때",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "송금보낼 때",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Container(height: 1, color: Colors.black12),
          const SizedBox(height: 10),

          _RateRow(currency: "USD", base: "1,321.50", ttb: "1,309.00", tts: "1,334.00"),
          _RateRow(currency: "JPY", base: "875.20", ttb: "870.10", tts: "882.90"),
          _RateRow(currency: "EUR", base: "1,443.10", ttb: "1,430.00", tts: "1,455.30"),
          _RateRow(currency: "CNY", base: "182.50", ttb: "180.20", tts: "185.60"),
        ],
      ),
    );
  }
}
class _RateRow extends StatelessWidget {
  final String currency;
  final String base;
  final String ttb;
  final String tts;

  const _RateRow({
    super.key,
    required this.currency,
    required this.base,
    required this.ttb,
    required this.tts,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // ✅ 행 전체 중앙
        children: [
          SizedBox(
            width: 50,
            child: Center(
              child: Text(
                currency,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          Expanded(
            child: Center(
              child: Text(base, textAlign: TextAlign.center),
            ),
          ),

          Expanded(
            child: Center(
              child: Text(ttb, textAlign: TextAlign.center),
            ),
          ),

          Expanded(
            child: Center(
              child: Text(tts, textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }
}



class _AccountCard extends StatelessWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 통장 이름 + 계좌번호
          const Text(
            "FLOBANK 외화 종합통장",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "104-20302-40293",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 18),

          // 잔액
          const Text(
            "1,250,000원",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          // 버튼 2개 (이체 / 내역)
          Row(
            children: [
              // 🔵 이체 버튼
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RemitStep1Page(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3E5D9C),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        "이체",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // ⚪ 내역 버튼
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TransactionHistoryPage(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEFEF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        "내역",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.actionText,
    required this.onTap,
  });

  final String title;
  final String actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        TextButton(onPressed: onTap, child: Text(actionText)),
      ],
    );
  }
}

class _ServiceList extends StatelessWidget {
  const _ServiceList({required this.services});

  final List<ServiceHighlight> services;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: services
          .map(
            (service) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            tileColor: Colors.white,
            leading: CircleAvatar(
              backgroundColor:
              const Color(0xFF4F6280).withOpacity(0.1),
              child: Icon(service.icon,
                  color: const Color(0xFF4F6280)),
            ),
            title: Text(
              service.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(service.description),
            trailing: const Icon(Icons.chevron_right),
            onTap: service.onTap,
          ),
        ),
      )
          .toList(),
    );
  }
}

class ServiceHighlight {
  const ServiceHighlight({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
}

List<ServiceHighlight> get aiAndFxServices => const [
  ServiceHighlight(
    icon: Icons.smart_toy_outlined,
    title: 'AI 플로봇 상담',
    description: '계좌 조회, 한도 변경, 상품 추천을 AI에게 물어보세요.',
    onTap: _noop,
  ),
  ServiceHighlight(
    icon: Icons.language,
    title: '글로벌 송금',
    description: 'SWIFT 코드 기반 해외 송금과 진행 상황 확인.',
    onTap: _noop,
  ),
  ServiceHighlight(
    icon: Icons.calendar_month,
    title: '출석 이벤트',
    description: '매일 출석하고 포인트를 받아보세요.',
    onTap: _noop,
  ),
  ServiceHighlight(
    icon: Icons.picture_as_pdf,
    title: '약관 요약 뷰어',
    description: 'AI가 금융 약관 핵심만 요약해줍니다.',
    onTap: _noop,
  ),
];

void _noop() {}

Widget _QuickMenu(String title, dynamic iconOrImage, {VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: iconOrImage is String
                ? Image.asset(
              iconOrImage,
              width: 70,
              height: 70,
              fit: BoxFit.contain,
            )
                : Icon(
              iconOrImage,
              color: const Color(0xFF5255B1),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    ),
  );
}