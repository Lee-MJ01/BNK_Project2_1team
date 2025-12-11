import 'package:flutter/material.dart';
import '../app_colors.dart';

enum ExchangePage { rates, alerts, risk }

class CurrencyRate {
  final String code;
  final String name;
  final double rate;
  final double change;
  final double dailyHigh;
  final double dailyLow;

  const CurrencyRate({
    required this.code,
    required this.name,
    required this.rate,
    required this.change,
    required this.dailyHigh,
    required this.dailyLow,
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
    code: 'USD/KRW',
    name: '미국 달러',
    rate: 1392.42,
    change: -4.12,
    dailyHigh: 1403.10,
    dailyLow: 1389.00,
  ),
  CurrencyRate(
    code: 'JPY/KRW',
    name: '일본 엔화',
    rate: 9.15,
    change: 0.02,
    dailyHigh: 9.20,
    dailyLow: 9.10,
  ),
  CurrencyRate(
    code: 'EUR/KRW',
    name: '유로',
    rate: 1510.08,
    change: 3.44,
    dailyHigh: 1518.20,
    dailyLow: 1507.55,
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
          const _HighlightCard(),
          const SizedBox(height: 16),
          const _SectionTitle('환율 조회'),
          const SizedBox(height: 8),
          ...currencyRates.map((rate) => _RateCard(rate: rate)),
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
      for (final rate in currencyRates) rate.code: rate.code != 'JPY/KRW'
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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

class _HighlightCard extends StatelessWidget {
  const _HighlightCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.mainPaleBlue.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.swap_horizontal_circle_outlined,
              color: AppColors.pointDustyNavy,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '환율 조회, 알림, 리스크를 한눈에',
                  style: TextStyle(
                    color: AppColors.pointDustyNavy,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '주요 통화 환율을 확인하고 지정가 알림을 설정하세요. 변동성 지표로 환리스크 노출도도 관리할 수 있습니다.',
                  style: TextStyle(
                    color: AppColors.pointDustyNavy,
                    fontSize: 13,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.pointDustyNavy,
      ),
    );
  }
}

class _RateCard extends StatelessWidget {
  const _RateCard({required this.rate});

  final CurrencyRate rate;

  @override
  Widget build(BuildContext context) {
    final Color changeColor =
    rate.change >= 0 ? Colors.redAccent : Colors.blueAccent;
    final String changeLabel = rate.change >= 0
        ? '+${rate.change.toStringAsFixed(2)}'
        : rate.change.toStringAsFixed(2);

    return Container(
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.subIvoryBeige,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.trending_up,
              color: AppColors.pointDustyNavy,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      rate.code,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.pointDustyNavy,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      rate.name,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      rate.rate.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pointDustyNavy,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      changeLabel,
                      style: TextStyle(
                        color: changeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '고 ${rate.dailyHigh.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '저 ${rate.dailyLow.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.chevron_right,
              color: AppColors.pointDustyNavy,
            ),
            onPressed: () => _goTo(context, ExchangePage.alerts),
          ),
        ],
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
          color: enabled ? AppColors.pointDustyNavy : AppColors.subIvoryBeige,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '목표 환율 ${target.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.black87),
                    ),
                    Slider(
                      value: target,
                      min: rate.rate * 0.95,
                      max: rate.rate * 1.05,
                      activeColor: AppColors.pointDustyNavy,
                      inactiveColor: AppColors.mainPaleBlue,
                      onChanged: enabled ? onChange : null,
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
                  color: AppColors.mainPaleBlue.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
            style: const TextStyle(color: Colors.black54),
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
            child: Icon(icon, color: AppColors.pointDustyNavy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  style: const TextStyle(color: Colors.black87),
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
                color: AppColors.mainPaleBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.pointDustyNavy),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
            const Icon(Icons.chevron_right, color: AppColors.pointDustyNavy),
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

  if (ModalRoute.of(context)?.settings.name == target.runtimeType.toString()) {
    return;
  }

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => target,
      settings: RouteSettings(name: target.runtimeType.toString()),
    ),
  );
}
