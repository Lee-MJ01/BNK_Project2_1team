import 'package:flutter/material.dart';
import '../app_colors.dart';

enum ExchangePage { rates, alerts, risk }

class CurrencyRate {
  final String code;
  final String name;
  final String flagEmoji;
  final double rate;
  final double change;
  final double changePercent;
  final double dailyHigh;
  final double dailyLow;
  final List<double> history;

  const CurrencyRate({
    required this.code,
    required this.name,
    required this.flagEmoji,
    required this.rate,
    required this.change,
    required this.changePercent,
    required this.dailyHigh,
    required this.dailyLow,
    required this.history,
  });
}

class RiskIndicator {
  final String title;
  final String value;
  final String subtitle;

  const RiskIndicator({
    required this.title,
    required this.value,
    required this.subtitle,
  });
}

const List<CurrencyRate> currencyRates = [
  CurrencyRate(
    code: 'USD',
    name: '미국 달러',
    flagEmoji: '🇺🇸',
    rate: 1469.06,
    change: -1.14,
    changePercent: 0.08,
    dailyHigh: 1472.09,
    dailyLow: 1464.80,
    history: [
      1468.2,
      1471.9,
      1472.1,
      1469.5,
      1468.9,
      1470.2,
      1467.3,
      1466.8,
      1464.8,
      1467.1,
    ],
  ),
  CurrencyRate(
    code: 'JPY',
    name: '일본 엔',
    flagEmoji: '🇯🇵',
    rate: 943.54,
    change: 4.63,
    changePercent: 0.49,
    dailyHigh: 945.10,
    dailyLow: 939.20,
    history: [
      941.2,
      942.0,
      942.4,
      943.8,
      943.0,
      944.3,
      945.1,
      944.0,
      943.4,
      943.5,
    ],
  ),
  CurrencyRate(
    code: 'EUR',
    name: '유럽 유로',
    flagEmoji: '🇪🇺',
    rate: 1718.77,
    change: 8.84,
    changePercent: 0.52,
    dailyHigh: 1725.10,
    dailyLow: 1714.10,
    history: [
      1710.2,
      1712.8,
      1715.1,
      1719.5,
      1718.0,
      1716.4,
      1717.9,
      1719.9,
      1720.2,
      1718.8,
    ],
  ),
  CurrencyRate(
    code: 'CNY',
    name: '중국 위안',
    flagEmoji: '🇨🇳',
    rate: 208.16,
    change: 0.38,
    changePercent: 0.19,
    dailyHigh: 208.80,
    dailyLow: 207.10,
    history: [
      207.3,
      207.6,
      207.9,
      208.2,
      208.6,
      208.5,
      208.1,
      208.0,
      208.3,
      208.1,
    ],
  ),
  CurrencyRate(
    code: 'HKD',
    name: '홍콩 달러',
    flagEmoji: '🇭🇰',
    rate: 188.91,
    change: 0.0,
    changePercent: 0.0,
    dailyHigh: 189.30,
    dailyLow: 188.30,
    history: [
      188.2,
      188.4,
      188.6,
      188.9,
      189.1,
      189.0,
      188.7,
      188.6,
      188.8,
      188.9,
    ],
  ),
  CurrencyRate(
    code: 'TWD',
    name: '대만 달러',
    flagEmoji: '🇹🇼',
    rate: 47.1518,
    change: 0.0057,
    changePercent: 0.01,
    dailyHigh: 47.30,
    dailyLow: 47.10,
    history: [
      47.08,
      47.10,
      47.14,
      47.12,
      47.18,
      47.20,
      47.16,
      47.15,
      47.13,
      47.15,
    ],
  ),
  CurrencyRate(
    code: 'THB',
    name: '태국 바트',
    flagEmoji: '🇹🇭',
    rate: 46.3432,
    change: 0.1730,
    changePercent: 0.37,
    dailyHigh: 46.60,
    dailyLow: 46.10,
    history: [
      46.0,
      46.2,
      46.5,
      46.4,
      46.6,
      46.5,
      46.3,
      46.2,
      46.3,
      46.34,
    ],
  ),
  CurrencyRate(
    code: 'SGD',
    name: '싱가포르 달러',
    flagEmoji: '🇸🇬',
    rate: 1136.62,
    change: 2.41,
    changePercent: 0.21,
    dailyHigh: 1139.5,
    dailyLow: 1132.0,
    history: [
      1131.2,
      1132.8,
      1133.6,
      1135.2,
      1136.9,
      1137.1,
      1135.8,
      1136.2,
      1136.8,
      1136.6,
    ],
  ),
  CurrencyRate(
    code: 'PHP',
    name: '필리핀 페소',
    flagEmoji: '🇵🇭',
    rate: 24.8255,
    change: 0.0064,
    changePercent: 0.03,
    dailyHigh: 24.90,
    dailyLow: 24.70,
    history: [
      24.72,
      24.75,
      24.79,
      24.82,
      24.84,
      24.83,
      24.81,
      24.82,
      24.83,
      24.82,
    ],
  ),
];

const List<RiskIndicator> riskIndicators = [
  RiskIndicator(
    title: '환율 변동성 (R 기반)',
    value: '0.83%',
    subtitle: '최근 30일 표준편차 추정',
  ),
  RiskIndicator(
    title: '시장 심리 지수',
    value: '중립 ↔',
    subtitle: 'R 샤프비율·모멘텀',
  ),
  RiskIndicator(
    title: '환리스크 한도',
    value: '70% 사용',
    subtitle: '사전 설정 대비 노출도',
  ),
  RiskIndicator(
    title: '헤지 적정도',
    value: '65%',
    subtitle: 'VaR·CVaR 조정 권고',
  ),
];

class ForexInsightScreen extends StatelessWidget {
  const ForexInsightScreen({super.key});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 하이라이트 카드 제거됨
          Container(
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
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: AppColors.pointDustyNavy,
                    unselectedLabelColor: Colors.black38,
                    indicatorColor: AppColors.pointDustyNavy,
                    tabs: [
                      Tab(text: '실시간 환율'),
                      Tab(text: '환율 뉴스'),
                    ],
                  ),
                  SizedBox(
                    height: 520,
                    child: TabBarView(
                      children: [
                        _RealtimeRateList(),
                        _ExchangeNewsPlaceholder(
                          onTap: () => _goTo(context, ExchangePage.alerts),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SwitcherCard(
            title: '리스크 지표 확인',
            description: 'R 기반 변동성·심리 지표로 노출도를 점검하세요.',
            icon: Icons.analytics_outlined,
            onTap: () => _goTo(context, ExchangePage.risk),
          ),
          const SizedBox(height: 10),
          _SwitcherCard(
            title: '알림 설정 이동',
            description: '지정가와 변동폭 알림을 바로 설정할 수 있습니다.',
            icon: Icons.notifications_active_outlined,
            onTap: () => _goTo(context, ExchangePage.alerts),
          ),
        ],
      ),
    );
  }
}

class _RealtimeRateList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: currencyRates.length,
      itemBuilder: (context, index) {
        final rate = currencyRates[index];
        return _RateCard(
          rate: rate,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExchangeDetailScreen(rate: rate),
            ),
          ),
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
  late Map<String, bool> _alertEnabled;
  late Map<String, double> _alertTargets;

  @override
  void initState() {
    super.initState();
    _alertEnabled = {
      for (final rate in currencyRates) rate.code: rate.code != 'JPY'
    };
    _alertTargets = {
      for (final rate in currencyRates) rate.code: rate.rate,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ExchangeBaseScaffold(
      currentPage: ExchangePage.alerts,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoCard(
            title: '환율 알림 설정',
            body:
            '변동폭과 지정가를 설정해 주요 통화의 움직임을 놓치지 마세요. 슬라이더로 알림 기준을 조정할 수 있습니다.',
            icon: Icons.notifications_active_outlined,
          ),
          const SizedBox(height: 16),
          ...currencyRates.map(
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
            onTap: () => _goTo(context, ExchangePage.risk),
          ),
        ],
      ),
    );
  }
}

class ExchangeRiskScreen extends StatelessWidget {
  const ExchangeRiskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ExchangeBaseScaffold(
      currentPage: ExchangePage.risk,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoCard(
            title: '환율 리스크 지표',
            body:
            'R 기반 변동성 분석과 심리 지표를 간략히 보여드립니다. VaR·CVaR를 포함한 헤지 적정도도 확인하세요.',
            icon: Icons.shield_outlined,
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: riskIndicators.length,
            itemBuilder: (context, index) {
              final indicator = riskIndicators[index];
              return _RiskCard(indicator: indicator);
            },
          ),
          const SizedBox(height: 16),
          _SwitcherCard(
            title: '환율 조회',
            description: '실시간 환율과 고·저가 흐름으로 이동합니다.',
            icon: Icons.swap_horizontal_circle_outlined,
            onTap: () => _goTo(context, ExchangePage.rates),
          ),
          const SizedBox(height: 10),
          _SwitcherCard(
            title: '알림 설정',
            description: '지정가 알림과 변동폭 알림을 세부 조정합니다.',
            icon: Icons.notifications_outlined,
            onTap: () => _goTo(context, ExchangePage.alerts),
          ),
        ],
      ),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ExchangeNavigation(
            current: currentPage,
            onSelected: (page) => _goTo(context, page),
          ),
          const SizedBox(height: 12),
          child,
        ],
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
          label: '리스크 지표',
          selected: current == ExchangePage.risk,
          onTap: () => onSelected(ExchangePage.risk),
        ),
        const SizedBox(width: 8),
        _NavChip(
          label: '알림 설정',
          selected: current == ExchangePage.alerts,
          onTap: () => onSelected(ExchangePage.alerts),
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
        '${isUp ? '+' : ''}${rate.change.toStringAsFixed(2)} (${rate.changePercent.toStringAsFixed(2)}%)';

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
                Row(
                  children: [
                    Text(
                      rate.rate.toStringAsFixed(4),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pointDustyNavy,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isUp
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      color: changeColor,
                      size: 24,
                    ),
                  ],
                ),
                Text(
                  changeLabel,
                  style: TextStyle(color: changeColor),
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
  String _selectedRange = '1일';

  @override
  Widget build(BuildContext context) {
    final bool isUp = widget.rate.change >= 0;
    final Color changeColor =
    isUp ? Colors.redAccent : Colors.blueAccent;
    final String changeLabel =
        '${isUp ? '+' : ''}${widget.rate.change.toStringAsFixed(2)} (${widget.rate.changePercent.toStringAsFixed(2)}%)';

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
        actions: const [
          Icon(
            Icons.file_download_outlined,
            color: AppColors.pointDustyNavy,
          ),
          SizedBox(width: 12),
        ],
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
            const SizedBox(height: 20),
            _RangeSelector(
              selected: _selectedRange,
              onSelected: (value) =>
                  setState(() => _selectedRange = value),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _RateChart(
                points: widget.rate.history,
                high: widget.rate.dailyHigh,
                low: widget.rate.dailyLow,
                changeColor: changeColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                _Chip(
                  label:
                  '최고 ${widget.rate.dailyHigh.toStringAsFixed(2)}원',
                ),
                _Chip(
                  label:
                  '최저 ${widget.rate.dailyLow.toStringAsFixed(2)}원',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ActionButtons(
              changeColor: changeColor,
              isUp: isUp,
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const ranges = ['1일', '1주', '3달', '1년'];
    return Row(
      children: ranges
          .map(
            (range) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(range),
            selected: selected == range,
            onSelected: (_) => onSelected(range),
            selectedColor: AppColors.pointDustyNavy,
            labelStyle: TextStyle(
              color: selected == range
                  ? Colors.white
                  : AppColors.pointDustyNavy,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: Colors.white,
          ),
        ),
      )
          .toList(),
    );
  }
}

class _RateChart extends StatelessWidget {
  const _RateChart({
    required this.points,
    required this.high,
    required this.low,
    required this.changeColor,
  });

  final List<double> points;
  final double high;
  final double low;
  final Color changeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '실시간 환율',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: CustomPaint(
              painter: _LineChartPainter(
                points: points,
                lineColor: changeColor,
              ),
              child: Container(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '매수 · 매도 시점에 맞춰 확인',
                style: TextStyle(color: Colors.black54),
              ),
              Icon(
                Icons.info_outline,
                size: 18,
                color: Colors.black45,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.points,
    required this.lineColor,
  });

  final List<double> points;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final double maxPoint =
    points.reduce((a, b) => a > b ? a : b);
    final double minPoint =
    points.reduce((a, b) => a < b ? a : b);
    final double range =
    (maxPoint - minPoint).abs() < 0.01
        ? 1
        : maxPoint - minPoint;

    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint areaPaint = Paint()
      ..color = lineColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final Path linePath = Path();
    final Path areaPath = Path();

    for (int i = 0; i < points.length; i++) {
      final double dx =
          size.width * (i / (points.length - 1));
      final double dy = size.height -
          ((points[i] - minPoint) / range) *
              size.height;

      if (i == 0) {
        linePath.moveTo(dx, dy);
        areaPath.moveTo(dx, size.height);
        areaPath.lineTo(dx, dy);
      } else {
        linePath.lineTo(dx, dy);
        areaPath.lineTo(dx, dy);
      }
    }

    areaPath.lineTo(size.width, size.height);
    areaPath.close();

    canvas.drawPath(areaPath, areaPaint);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(
      covariant _LineChartPainter oldDelegate,
      ) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor;
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.changeColor,
    required this.isUp,
  });

  final Color changeColor;
  final bool isUp;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.pointDustyNavy,
              side: const BorderSide(
                color: AppColors.pointDustyNavy,
              ),
              padding:
              const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('팔기'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointDustyNavy,
              padding:
              const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('사기'),
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

class _RiskCard extends StatelessWidget {
  const _RiskCard({required this.indicator});

  final RiskIndicator indicator;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            indicator.title,
            style: const TextStyle(
              color: AppColors.pointDustyNavy,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            indicator.value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.pointDustyNavy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            indicator.subtitle,
            style: const TextStyle(
              color: Colors.black54,
            ),
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
      target = const ExchangeRateScreen();
      break;
    case ExchangePage.alerts:
      target = const ExchangeAlertScreen();
      break;
    case ExchangePage.risk:
      target = const ExchangeRiskScreen();
      break;
  }

  if (ModalRoute.of(context)?.settings.name ==
      target.runtimeType.toString()) {
    return;
  }

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => target,
      settings: RouteSettings(
        name: target.runtimeType.toString(),
      ),
    ),
  );
}
