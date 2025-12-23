import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test_main/screens/deposit/list.dart';
import 'package:test_main/screens/main/search.dart';
import 'package:test_main/voice/controller/voice_session_controller.dart';
import '../../services/api_service.dart';
import '../../voice/core/voice_state_machine.dart';
import '../../voice/script/voice_script_resolver.dart';
import '../../voice/service/voice_stt_service.dart';
import '../../voice/service/voice_tts_service.dart';
import '../../voice/ui/voice_assistant_overlay.dart';
import '../../voice/ui/voice_ui_state.dart';
import '../../voice/ui/voice_waveform.dart';
import '../app_colors.dart';
import '../../main.dart';
import '../mypage/transaction_history.dart';
import '../ai/camera_exchange_screen.dart';
import '../ai/voice_assistant_screen.dart';

import '../remit/remit_step1.dart';

import 'menu.dart';
import '../exchange/forex_insight.dart';

import 'alarm.dart';
import 'package:test_main/screens/main/live_camera.dart';
import '../chat/chat.dart';

class RateDTO {
  final String rhistCurrency;
  final double rhistBaseRate;
  final double rhistTtBuyRate;
  final double rhistTtSellRate;
  final String rhistRegDt;

  RateDTO({
    required this.rhistCurrency,
    required this.rhistBaseRate,
    required this.rhistTtBuyRate,
    required this.rhistTtSellRate,
    required this.rhistRegDt,
  });

  factory RateDTO.fromJson(Map<String, dynamic> json) {
    return RateDTO(
      rhistCurrency: json['rhistCurrency'],
      rhistBaseRate: (json['rhistBaseRate'] as num).toDouble(),
      rhistTtBuyRate: (json['rhistTtBuyRate'] as num).toDouble(),
      rhistTtSellRate: (json['rhistTtSellRate'] as num).toDouble(),
      rhistRegDt: json['rhistRegDt'],
    );
  }
}

Future<List<RateDTO>> fetchLatestRates() async {
  final headers = await ApiService.getAuthHeaders();

  final baseUrl =
  ApiService.currentUrl.replaceFirst('/api/mobile', '/api/exchange');

  final url = Uri.parse('$baseUrl/rates');

  print("📌 headers = $headers");
  print("📌 rates url = $url");

  final req = http.Request('GET', url)
    ..headers.addAll(headers)
    ..followRedirects = false; // ✅ 리다이렉트 추적 끔

  final streamed = await http.Client().send(req);
  final res = await http.Response.fromStream(streamed);

  print("📌 status = ${res.statusCode}");
  print("📌 location = ${res.headers['location']}"); // ✅ 302면 여기 찍힘
  print("📌 body = ${res.body}");

  if (res.statusCode != 200) {
    throw Exception("환율 조회 실패: ${res.statusCode} ${res.body}");
  }

  final List list = jsonDecode(utf8.decode(res.bodyBytes));
  return list.map((e) => RateDTO.fromJson(e)).toList();
}


class BankHomePage extends StatefulWidget {
  const BankHomePage({super.key});

  @override
  State<BankHomePage> createState() => _BankHomePageState();
}

class _BankHomePageState extends State<BankHomePage> {
  // int _currentIndex = 0;

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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ChatScreen(),
              ),
            );
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
            child: const Icon(Icons.pets, color: Colors.white),
          ),
        ),
        actions: [
          // 1. 스캔 버튼 (누르면 실시간 AR 카메라 화면으로 이동)
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.black87),
            onPressed: () {
              // _openCamera 함수 대신, 바로 페이지 이동 코드를 넣습니다.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LiveCameraPage(),
                ),
              );
            },
          ),
          // 2. 검색 버튼
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SearchScreen(),
                  fullscreenDialog: true,
                ),
              );
            },
          ),

          // 3. 알림 버튼
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlaramScreen()),
              );
            },
          ),

          // 4. 메뉴 버튼
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black87),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),


      endDrawer: Drawer(
        width: MediaQuery.sizeOf(context).width, // ✅ 거의 전체화면으로 슥 열림
        child: const MyPageDrawer(),             // ✅ 마이페이지를 Drawer로 표시
      ),
      endDrawerEnableOpenDragGesture: true,

      /// ✅ 하단 네비
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _currentIndex,
      //   onTap: (i) {
      //     if (i == 3) { // 마이페이지 탭
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder: (_) => const MyPageScreen(),
      //         ),
      //       );
      //       return;
      //     }
      //
      //     setState(() => _currentIndex = i);
      //   },
      //   selectedItemColor: const Color(0xFF3C4F76),
      //   unselectedItemColor: Colors.grey,
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
      //     BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "거래내역"),
      //     BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "외화상품"),
      //     BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: "전체"),
      //   ],
      // ),

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
              _ServiceList(services: buildAiAndFxServices(context)),
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
    return FutureBuilder<List<RateDTO>>(
      future: fetchLatestRates(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final rates = snapshot.data!;
        final visibleRates = rates.where((r) =>
        r.rhistCurrency == 'USD' ||
            r.rhistCurrency == 'JPY' ||
            r.rhistCurrency == 'EUR' ||
            r.rhistCurrency == 'CNH'
        ).toList();

        const order = ['USD', 'JPY', 'EUR', 'CNH'];
        visibleRates.sort((a, b) =>
            order.indexOf(a.rhistCurrency)
                .compareTo(order.indexOf(b.rhistCurrency)));

        final String today = rates.first.rhistRegDt; // DB 기준일

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 6),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// 제목 + 기준일
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "환율 정보",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "($today 기준)",
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// 헤더
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 50,
                    child: Center(
                      child: Text("통화",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54)),
                    ),
                  ),
                  Expanded(
                      child: Center(
                          child: Text("매매기준율",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54)))),
                  Expanded(
                      child: Center(
                          child: Text("송금받을 때",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54)))),
                  Expanded(
                      child: Center(
                          child: Text("송금보낼 때",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54)))),
                ],
              ),

              const SizedBox(height: 8),
              Container(height: 1, color: Colors.black12),
              const SizedBox(height: 10),

              /// DB 환율 Row
              ...visibleRates.map(
                    (r) => _RateRow(
                  currency: _displayCurrencyName(r.rhistCurrency),
                  base: r.rhistBaseRate.toStringAsFixed(2),
                  ttb: r.rhistTtBuyRate.toStringAsFixed(2),
                  tts: r.rhistTtSellRate.toStringAsFixed(2),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
String _displayCurrencyName(String code) {
  switch (code) {
    case 'USD':
      return 'USD';
    case 'JPY':
      return 'JPY';
    case 'EUR':
      return 'EUR';
    case 'CNH':
      return 'CNH';
    default:
      return code;
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
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: Colors.white,
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF4F6280).withOpacity(0.1),
              child: service.icon is String
                  ? Image.asset(
                service.icon as String,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              )
                  : Icon(
                service.icon as IconData,
                color: const Color(0xFF4F6280),
              ),
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

  final dynamic icon;
  final String title;
  final String description;
  final VoidCallback onTap;
}

List<ServiceHighlight> buildAiAndFxServices(BuildContext context) => [
  ServiceHighlight(
    icon: Icons.photo_camera_front_outlined,
    title: 'AI 카메라 환율 변환',
    description: '영수증·가격표를 촬영해 즉시 원화 금액을 받아보세요.',
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CameraExchangeScreen(),
        ),
      );
    },
  ),
  ServiceHighlight(
    icon: 'images/flobankIcon5_음성비서.png',
    title: 'AI 음성비서',
    description: '시리처럼 말로 송금·조회·추천을 요청해보세요.',
    onTap: () async {
      final agreed = await _ensureVoiceTermsAgreed(context);
      if (!agreed) return;

      final tts = VoiceTtsService();
      final stt = VoiceSttService();

      late VoiceSessionController controller;

      final fsm = VoiceStateMachine();

      controller = VoiceSessionController(
        stt: stt,
        tts: tts,
        fsm: fsm,
      );

      _openVoiceAssistantOverlay(
        context,
        controller,
      );

      controller.startSession(); // 🔊 여기서 첫 음성
    },

  ),
  const ServiceHighlight(
    icon: Icons.smart_toy_outlined,
    title: 'AI 플로봇 상담',
    description: '계좌 조회, 한도 변경, 상품 추천을 AI에게 물어보세요.',
    onTap: _noop,
  ),
  const ServiceHighlight(
    icon: Icons.language,
    title: '글로벌 송금',
    description: 'SWIFT 코드 기반 해외 송금과 진행 상황 확인.',
    onTap: _noop,
  ),
  const ServiceHighlight(
    icon: Icons.calendar_month,
    title: '출석 이벤트',
    description: '매일 출석하고 포인트를 받아보세요.',
    onTap: _noop,
  ),
  const ServiceHighlight(
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

Future<bool> _ensureVoiceTermsAgreed(BuildContext context) async {
  // TODO: 실제로는 SharedPreferences / SecureStorage
  bool alreadyAgreed = false;

  if (alreadyAgreed) return true;

  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const VoiceTermsSheet(),
  );

  return result == true;
}

void _openVoiceAssistantOverlay(BuildContext context, VoiceSessionController controller) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.transparent,
    builder: (_) {
      return VoiceAssistantOverlay(controller: controller,);
    },
  );
}



class VoiceTermsSheet extends StatefulWidget {
  const VoiceTermsSheet();

  @override
  State<VoiceTermsSheet> createState() => _VoiceTermsSheetState();
}

class _VoiceTermsSheetState extends State<VoiceTermsSheet> {
  bool agreed = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 드래그 핸들
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'AI 음성 가이드 이용 안내',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              '음성 명령 처리를 위해 마이크 접근 권한이 필요하며,\n'
                  '음성 데이터는 서비스 제공 목적에만 사용됩니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
            ),


            // 체크박스
            GestureDetector(
              onTap: () => setState(() => agreed = !agreed),
              child: Row(
                children: [
                  Checkbox(
                    value: agreed,
                    onChanged: (v) => setState(() => agreed = v ?? false),
                    activeColor: AppColors.mainPaleBlue,
                  ),
                  const Expanded(
                    child: Text(
                      'AI 음성비서 이용에 동의합니다. (필수)',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            // 동의 버튼
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: agreed
                    ? () {
                  // TODO: 동의 여부 저장
                  Navigator.pop(context, true);
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3C4F76),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: const Text(
                  '동의하고 시작하기',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


