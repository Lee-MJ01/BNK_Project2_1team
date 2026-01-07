import 'package:flutter/material.dart';
import '../../services/exchange_api.dart';
import '../../services/exchange_service.dart';
import '../app_colors.dart';
import 'exchange_buy.dart';
import 'exchange_risk.dart';
import 'exchange_sell.dart';
import 'exchange_chart.dart';

enum ExchangePage { rates, alerts }

class ExchangeHistory {
  final DateTime date;
  final double rate;

  ExchangeHistory({
    required this.date,
    required this.rate,
  });
}




class CurrencyRate {
  final String code;
  final String name;
  final String flagEmoji;
  final double rate;
  final double change;
  final double changePercent;
  final String regDt;
  final List<ExchangeHistory> history;

  CurrencyRate({
    required this.code,
    required this.name,
    required this.flagEmoji,
    required this.rate,
    required this.change,
    required this.changePercent,
    required this.history,
    required this.regDt,
  });

  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    return CurrencyRate(
      code: json['rhistCurrency'],
      name: json['rhistCurName'],
      flagEmoji: _flagFromCode(json['rhistCurrency']),
      rate: (json['rhistBaseRate'] as num).toDouble(),
      change: 0,
      changePercent: 0,
      history: const [],
      regDt: json['rhistRegDt'],
    );
  }
  CurrencyRate copyWith({
    String? code,
    String? name,
    String? flagEmoji,
    double? rate,
    double? change,
    double? changePercent,
    List<ExchangeHistory>? history,
    String? regDt,
  }) {
    return CurrencyRate(
      code: code ?? this.code,
      name: name ?? this.name,
      flagEmoji: flagEmoji ?? this.flagEmoji,
      rate: rate ?? this.rate,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      history: history ?? this.history,
      regDt: regDt ?? this.regDt,
    );
  }
}

String _flagFromCode(String code) {
  switch (code) {
    case 'USD': return '🇺🇸';
    case 'JPY': return '🇯🇵';
    case 'EUR': return '🇪🇺';
    case 'CNY':
    case 'CNH': return '🇨🇳';
    case 'GBP': return '🇬🇧';
    case 'AUD': return '🇦🇺';
    case 'CAD': return '🇨🇦';
    case 'CHF': return '🇨🇭';
    case 'HKD': return '🇭🇰';
    case 'SGD': return '🇸🇬';
    case 'THB': return '🇹🇭';
    case 'KRW': return '🇰🇷';
    case 'NZD': return '🇳🇿';
    case 'DKK': return '🇩🇰';
    case 'NOK': return '🇳🇴';
    case 'SEK': return '🇸🇪';
    case 'IDR': return '🇮🇩';
    case 'MYR': return '🇲🇾';
    case 'SAR': return '🇸🇦';
    case 'AED': return '🇦🇪';
    case 'BHD': return '🇧🇭';
    case 'BND': return '🇧🇳';
    default: return '🏳️';
  }
}

class ForexInsightScreen extends StatefulWidget {
  const ForexInsightScreen({super.key});

  @override
  State<ForexInsightScreen> createState() => _ForexInsightScreenState();
}

class _ForexInsightScreenState extends State<ForexInsightScreen> {

  @override
  void initState() {
    super.initState();
    print("🚩 ForexInsightScreen initState 실행됨"); // 로그 추가 1
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("🚩 화면 렌더링 후 콜백 실행됨"); // 로그 추가 2
      _checkExchangeTerms();
    });
  }

  /// 약관 동의 상태 확인 및 모달 표시 로직
  Future<void> _checkExchangeTerms() async {
    print("🚩 _checkExchangeTerms 함수 진입"); // 로그 추가 3
    try {
      bool isAgreed = await ExchangeService.checkTermsAgreed();
      print("🚩 서버 응답 결과 (동의여부): $isAgreed"); // 로그 추가 4 (true면 이미 동의해서 안 뜨는 것)

      if (!isAgreed) {
        if (!mounted) return;
        print("🚩 바텀시트 호출 시도"); // 로그 추가 5
        _showTermsBottomSheet();
      }
    } catch (e) {
      debugPrint("약관 확인 중 오류 발생: $e");
    }
  }

  /// 약관 동의 바텀시트
  void _showTermsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false, // 동의 전에는 닫지 못하게 설정 (선택 사항)
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "환전 서비스 이용 동의",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.pointDustyNavy),
            ),
            const SizedBox(height: 16),
            const Text(
              "빠르고 안전한 외화 거래를 위해\n아래의 약관에 동의가 필요합니다.",
              style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 24),
            // 약관 항목 리스트 (추후 필요 시 추가)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.check_circle_outline, color: AppColors.pointDustyNavy),
              title: const Text("외화 거래 유의사항 및 약관 동의 (필수)"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () { /* 상세 약관 보기 로직 */ },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  // DB에 동의 이력 저장 (AGREE_TERM_CATE = 3)
                  await ExchangeService.submitTermsAgreement();
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pointDustyNavy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  "동의하고 시작하기",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const ExchangeRateScreen();
  }
}

class ExchangeRateScreen extends StatelessWidget {
  const ExchangeRateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ExchangeBaseScaffold(
      currentPage: ExchangePage.rates,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const TabBar(
                labelColor: AppColors.pointDustyNavy,
                tabs: [
                  Tab(text: '실시간 환율'),
                  Tab(text: '환율 뉴스'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 🔥 이게 핵심
            Expanded(
              child: TabBarView(
                children: [
                  _RealtimeRateList(),          // ← 환율 리스트
                  _ExchangeNewsPlaceholder(
                    onTap: (){},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RealtimeRateList extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CurrencyRate>>(
      future: ExchangeApi.fetchRates(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('환율 정보를 불러오지 못했습니다.'));
        }

        final majorOrder = ['USD', 'JPY', 'EUR', 'CNY', 'CNH', 'VND'];

        final rates = snapshot.data!
          ..sort((a, b) {
            final aIndex = majorOrder.indexOf(a.code);
            final bIndex = majorOrder.indexOf(b.code);

            if (aIndex == -1 && bIndex == -1) return 0;
            if (aIndex == -1) return 1;
            if (bIndex == -1) return -1;
            return aIndex.compareTo(bIndex);
          });

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: rates.length,
          itemBuilder: (context, index) {
            final rate = rates[index];

            return FutureBuilder<List<ExchangeHistory>>(
              future: ExchangeApi.fetchHistory(rate.code),
              builder: (context, snap) {
                if (!snap.hasData || snap.data!.length < 2) {
                  return _RateCard(rate: rate);
                }

                final history = snap.data!
                  ..sort((a, b) => a.date.compareTo(b.date));

                final daily = <ExchangeHistory>[];
                for (final h in history) {
                  if (daily.isEmpty ||
                      daily.last.date.day != h.date.day ||
                      daily.last.date.month != h.date.month ||
                      daily.last.date.year != h.date.year) {
                    daily.add(h);
                  }
                }

                if (daily.length < 2) {
                  return _RateCard(rate: rate);
                }


                final yesterday = daily[daily.length - 2].rate;
                final today = daily.last.rate;

                final change = today - yesterday;
                final changePercent =
                yesterday == 0 ? 0.0 : (change / yesterday) * 100;

                final computedRate = rate.copyWith(
                  change: change,
                  changePercent: changePercent,
                );

                return _RateCard(
                  rate: computedRate,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExchangeDetailScreen(
                          rate: computedRate.copyWith(history: history),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}


            class _ExchangeNewsPlaceholder extends StatelessWidget {
  const _ExchangeNewsPlaceholder({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.newspaper,
              color: AppColors.pointDustyNavy,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              '환율 뉴스 알림을 설정하고 주요 시황을 받아보세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.pointDustyNavy,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '변동성이 큰 통화를 북마크하고 알림을 활성화하면 실시간 뉴스가 도착합니다.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointDustyNavy,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('알림 설정 이동'),
            ),
          ],
        ),
      ),
    );
  }
}

class ExchangeAlertScreen extends StatefulWidget {
  const ExchangeAlertScreen({super.key});

  @override
  State<ExchangeAlertScreen> createState() => _ExchangeAlertScreenState();
}

class _ExchangeAlertScreenState extends State<ExchangeAlertScreen> {
  final Map<String, bool> _alertEnabled = {};
  final Map<String, double> _alertTargets = {};

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CurrencyRate>>(
      future: ExchangeApi.fetchRates(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('알림 정보를 불러올 수 없습니다')),
          );
        }

        final rates = snapshot.data!;

        // 🔹 최초 1회만 초기화
        for (final rate in rates) {
          _alertEnabled.putIfAbsent(rate.code, () => rate.code != 'JPY');
          _alertTargets.putIfAbsent(rate.code, () => rate.rate);
        }

        return ExchangeBaseScaffold(
          currentPage: ExchangePage.alerts,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _InfoCard(
                title: '환율 알림 설정',
                body:
                '변동폭과 지정가를 설정해 주요 통화의 움직임을 놓치지 마세요. 슬라이더로 알림 기준을 조정할 수 있습니다.',
                icon: Icons.notifications_active_outlined,
              ),
              const SizedBox(height: 16),

              ...rates.map(
                    (rate) => _AlertCard(
                  rate: rate,
                  enabled: _alertEnabled[rate.code] ?? false,
                  target: _alertTargets[rate.code] ?? rate.rate,
                  onToggle: (value) {
                    setState(() {
                      _alertEnabled[rate.code] = value;
                    });
                  },
                  onChange: (value) {
                    setState(() {
                      _alertTargets[rate.code] =
                          double.parse(value.toStringAsFixed(2));
                    });
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ✅ 이 부분은 그대로 유지 (리스크 지표 이동)
              _SwitcherCard(
                title: '환율 조회로 이동',
                description: '현재가와 고·저가 흐름을 다시 확인합니다.',
                icon: Icons.table_chart_outlined,
                onTap: () => _goTo(context, ExchangePage.rates),
              ),
              const SizedBox(height: 10),
              _SwitcherCard(
                title: '리스크 지표 보기',
                description: 'R 기반 변동성, 헤지 권고를 살펴보세요.',
                icon: Icons.auto_graph_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ExchangeRiskScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}



class ExchangeBaseScaffold extends StatelessWidget {
  const ExchangeBaseScaffold({
    super.key,
    required this.currentPage,
    required this.child,
  });

  final ExchangePage currentPage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundOffWhite,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '환율 · 환전 인사이트',
          style: TextStyle(
            color: AppColors.pointDustyNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.pointDustyNavy,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ExchangeNavigation(
              current: currentPage,
              onSelected: (page) => _goTo(context, page),
            ),
            const SizedBox(height: 12),

            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _ExchangeNavigation extends StatelessWidget {
  const _ExchangeNavigation({
    required this.current,
    required this.onSelected,
  });

  final ExchangePage current;
  final ValueChanged<ExchangePage> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NavChip(
          label: '환율 조회',
          selected: current == ExchangePage.rates,
          onTap: () => onSelected(ExchangePage.rates),
        ),
        const SizedBox(width: 8),
        _NavChip(
          label: '환율 기상청',
          selected: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ExchangeRiskScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _NavChip extends StatelessWidget {
  const _NavChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.pointDustyNavy
                : AppColors.mainPaleBlue.withOpacity(0.25),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.pointDustyNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _RateCard extends StatelessWidget {
  const _RateCard({required this.rate, this.onTap});

  final CurrencyRate rate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isUp = rate.change >= 0;
    final Color changeColor =
    isUp ? Colors.redAccent : Colors.blueAccent;
    final String changeLabel =
        '${isUp ? '+' : ''}${rate.change.toStringAsFixed(2)}원 '
        '(${rate.changePercent.toStringAsFixed(2)}%)';



    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              rate.flagEmoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rate.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.pointDustyNavy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rate.code,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${rate.rate.toStringAsFixed(2)}원',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pointDustyNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${isUp ? '+' : ''}${rate.change.toStringAsFixed(2)}원 '
                      '(${rate.changePercent.toStringAsFixed(2)}%)',
                  style: TextStyle(
                    color: changeColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
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

class ExchangeDetailScreen extends StatefulWidget {
  const ExchangeDetailScreen({super.key, required this.rate});

  final CurrencyRate rate;

  @override
  State<ExchangeDetailScreen> createState() =>
      _ExchangeDetailScreenState();
}

class _ExchangeDetailScreenState
    extends State<ExchangeDetailScreen> {

  @override
  Widget build(BuildContext context) {
    final bool isUp = widget.rate.change >= 0;
    final Color changeColor =
    isUp ? Colors.redAccent : Colors.blueAccent;
    final String changeLabel =
        '${isUp ? '+' : ''}${widget.rate.change.toStringAsFixed(2)} (${widget
        .rate.changePercent.toStringAsFixed(2)}%)';

    final prices =
    widget.rate.history.map((e) => e.rate).toList();

    final dates =
    widget.rate.history.map((e) => e.date).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundOffWhite,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.rate.name,
          style: const TextStyle(color: AppColors.pointDustyNavy),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.rate.flagEmoji,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.rate.code} 환율',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pointDustyNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              widget.rate.rate.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.pointDustyNavy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '어제보다 $changeLabel',
              style: TextStyle(
                color: changeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ExchangeChart(
                prices: prices,
                dates: dates,
                lineColor: changeColor,
              ),
            ),

            const SizedBox(height: 16),

            _ActionButtons(
              changeColor: changeColor,
              isUp: isUp,
              rate: widget.rate,
            ),
          ],
        ),
      ),
    );
  }
}


class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    super.key,
    required this.changeColor,
    required this.isUp,
    required this.rate,
  });

  final Color changeColor;
  final bool isUp;
  final CurrencyRate rate;

  // 약관 확인 및 네비게이션 처리 로직 추가
  Future<void> _handleNavigation(BuildContext context, Widget targetPage) async {
    try {
      // 1. 약관 동의 여부 확인
      bool isAgreed = await ExchangeService.checkTermsAgreed();

      if (!isAgreed) {
        // 2. 동의 안 된 경우 다이얼로그 띄우기
        if (!context.mounted) return;
        bool? agreeResult = await _showTermsDialog(context);

        if (agreeResult == true) {
          // 3. 동의 시 서버 전송 후 페이지 이동
          await ExchangeService.submitTermsAgreement();
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => targetPage),
            );
          }
        }
      } else {
        // 4. 이미 동의한 경우 바로 이동
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => targetPage),
        );
      }
    } catch (e) {
      debugPrint("약관 확인 중 오류: $e");
      // 오류 발생 시에도 일단 진입시킬지, 막을지는 정책에 따라 결정 (여기선 일단 진입)
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => targetPage),
        );
      }
    }
  }

  // 약관 동의 다이얼로그
  Future<bool?> _showTermsDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "환전 서비스 약관 동의",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Container(
          height: 200,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: const SingleChildScrollView(
            child: Text(
              """제1조 (목적)
본 약관은 고객이 모바일 앱을 통해 외화를 환전함에 있어 은행과 고객 사이의 권리와 의무를 규정함을 목적으로 합니다.

제2조 (적용대상)
본 서비스는 실명 확인이 완료된 개인 고객에 한하여 제공됩니다.

제3조 (환율 적용)
1. 환전 시 적용되는 환율은 거래 시점에 은행이 고시한 전신환 매도율(살 때) 또는 전신환 매입율(팔 때)을 기준으로 합니다.
2. 우대율은 은행의 정책 및 고객 등급에 따라 차등 적용될 수 있습니다.

제4조 (취소 및 정정)
환전 거래가 완료된 이후에는 원칙적으로 취소나 정정이 불가능합니다. 단, 은행의 전산 장애 등 귀책사유가 있는 경우는 예외로 합니다.

제5조 (이용 한도)
1. 1일 최대 환전 한도는 미화 환산 기준 10,000 USD입니다.
2. 연간 누적 한도는 관련 외국환거래법 규정에 따릅니다.

제6조 (서비스 제한)
시스템 점검 시간(23:50 ~ 00:10)에는 서비스 이용이 제한될 수 있습니다.""",
              style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("취소", style: TextStyle(color: Colors.black54)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppColors.pointDustyNavy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("동의합니다", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              _handleNavigation(
                context,
                ExchangeSellPage(rate: rate),
              );
            },
            child: const Text('팔기'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  _handleNavigation(
                    context,
                    ExchangeBuyPage(rate: rate),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pointDustyNavy,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  '사기',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          backgroundColor: isUp
              ? Colors.redAccent.withOpacity(0.15)
              : Colors.blueAccent.withOpacity(0.15),
          child: Icon(
            isUp ? Icons.trending_up : Icons.trending_down,
            color: changeColor,
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.mainPaleBlue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.pointDustyNavy,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.rate,
    required this.enabled,
    required this.target,
    required this.onToggle,
    required this.onChange,
  });

  final CurrencyRate rate;
  final bool enabled;
  final double target;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: enabled
              ? AppColors.pointDustyNavy
              : AppColors.subIvoryBeige,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${rate.code} 지정가 알림',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.pointDustyNavy,
                ),
              ),
              Switch(
                value: enabled,
                activeColor: AppColors.pointDustyNavy,
                onChanged: onToggle,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      '목표 환율 ${target.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                    Slider(
                      value: target,
                      min: rate.rate * 0.95,
                      max: rate.rate * 1.05,
                      activeColor: AppColors.pointDustyNavy,
                      inactiveColor:
                      AppColors.mainPaleBlue,
                      onChanged:
                      enabled ? onChange : null,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.mainPaleBlue
                      .withOpacity(0.25),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: Text(
                  '현재 ${rate.rate.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.pointDustyNavy,
                    fontWeight: FontWeight.bold,
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




class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.subIvoryBeige,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.pointDustyNavy,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.pointDustyNavy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _SwitcherCard extends StatelessWidget {
  const _SwitcherCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.mainPaleBlue
                    .withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.pointDustyNavy,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.pointDustyNavy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(description),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.pointDustyNavy,
            ),
          ],
        ),
      ),
    );
  }
}

void _goTo(BuildContext context, ExchangePage page) {
  Widget target;

  switch (page) {
    case ExchangePage.rates:
    // [수정] 약관 체크 로직이 있는 Wrapper 위젯으로 이동
      target = const ForexInsightScreen();
      break;
    case ExchangePage.alerts:
      target = const ExchangeAlertScreen();
      break;
  }

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => target),
  );
}
