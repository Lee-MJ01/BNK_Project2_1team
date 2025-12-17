import 'package:flutter/material.dart';
import '../../services/exchange_api.dart';
import '../app_colors.dart';
import 'exchange_buy.dart';
import 'exchange_risk.dart';
import 'exchange_sell.dart';

enum ExchangePage { rates, alerts }

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

  CurrencyRate({
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

  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    return CurrencyRate(
      code: json['rhistCurrency'],
      name: json['rhistCurName'],
      flagEmoji: _flagFromCode(json['rhistCurrency']),
      rate: (json['rhistBaseRate'] as num).toDouble(),
      change: 0,
      changePercent: 0,
      dailyHigh: (json['rhistBaseRate'] as num).toDouble(),
      dailyLow: (json['rhistBaseRate'] as num).toDouble(),
      history: const [],
    );
  }
  CurrencyRate copyWith({
    String? code,
    String? name,
    String? flagEmoji,
    double? rate,
    double? change,
    double? changePercent,
    double? dailyHigh,
    double? dailyLow,
    List<double>? history,
  }) {
    return CurrencyRate(
      code: code ?? this.code,
      name: name ?? this.name,
      flagEmoji: flagEmoji ?? this.flagEmoji,
      rate: rate ?? this.rate,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      dailyHigh: dailyHigh ?? this.dailyHigh,
      dailyLow: dailyLow ?? this.dailyLow,
      history: history ?? this.history,
    );
  }
}

String _flagFromCode(String code) {
  switch (code) {
    case 'USD': return '🇺🇸';
    case 'JPY': return '🇯🇵';
    case 'EUR': return '🇪🇺';
    case 'CNY': return '🇨🇳';
    case 'HKD': return '🇭🇰';
    case 'THB': return '🇹🇭';
    case 'SGD': return '🇸🇬';
    case 'PHP': return '🇵🇭';
    default: return '🏳️';
  }
}




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
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: AppColors.pointDustyNavy,
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
                          onTap: () =>
                              _goTo(context, ExchangePage.alerts),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

        if (snapshot.hasError) {
          return const Center(child: Text('환율 정보를 불러오지 못했습니다.'));
        }

        final rates = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: rates.length,
          itemBuilder: (context, index) {
            final rate = rates[index];
            return _RateCard(
              rate: rate,
              onTap: () async {
                final history =
                await ExchangeApi.fetchHistory(rate.code);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExchangeDetailScreen(
                      rate: rate.copyWith(history: history),
                    ),
                  ),
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
          label: '알림 설정',
          selected: current == ExchangePage.alerts,
          onTap: () => onSelected(ExchangePage.alerts),
        ),
        const SizedBox(width: 8),
        _NavChip(
          label: '리스크 지표',
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
              rate: widget.rate,
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
    required this.rate,
  });

  final Color changeColor;
  final bool isUp;
  final CurrencyRate rate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExchangeSellPage(rate: rate),
                ),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExchangeBuyPage(rate: rate),
                    ),
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
      target = const ExchangeRateScreen();
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
