import 'dart:math';
import 'package:flutter/material.dart';
import '../app_colors.dart';

/// ===============================
/// 환율 차트 위젯 (외부에서 호출)
/// ===============================
class ExchangeChart extends StatefulWidget {
  final List<double> prices;
  final List<DateTime> dates;
  final Color lineColor;

  const ExchangeChart({
    super.key,
    required this.prices,
    required this.dates,
    required this.lineColor,
  });



  @override
  State<ExchangeChart> createState() => _ExchangeChartState();
}

class ExchangeHistory {
  final DateTime date;
  final double rate;

  ExchangeHistory({
    required this.date,
    required this.rate,
  });
}

class _ExchangeChartState extends State<ExchangeChart> {
  int? selectedIndex;


  @override
  Widget build(BuildContext context) {
    // ✅ prices + dates 날짜 기준 오름차순 정렬
    final combined = List.generate(
      widget.prices.length,
          (i) => {
        'price': widget.prices[i],
        'date': widget.dates[i],
      },
    )..sort((a, b) =>
        (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    final prices =
    combined.map((e) => e['price'] as double).toList();
    final dates =
    combined.map((e) => e['date'] as DateTime).toList();

    final maxPrice = prices.reduce(max);
    final minPrice = prices.reduce(min);


    final valid = prices.where((e) => e > 0).toList();


    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '환율 추이',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.pointDustyNavy,
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;


                final maxPrice = prices.reduce(max);
                final minPrice = prices.reduce(min);
                final todayPrice = prices.last;

                // 🔹 기존 스케일 계산 그대로
                final center = todayPrice;
                final realRange = (maxPrice - minPrice).abs();
                final minVisualRange = center * 0.01;
                final visualRange = max(realRange * 1.5, minVisualRange);

                final top = center + visualRange;
                final bottom = center - visualRange;
                final range = top - bottom;

                double calcY(double price) =>
                    ((top - price) / range) * height;

                double calcX(int index) =>
                    width * (index / (prices.length - 1));

                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTapDown: (details) {
                    final dx = details.localPosition.dx;

                    // x좌표 → 가장 가까운 index
                    final ratio = (dx / width).clamp(0.0, 1.0);
                    final index =
                    (ratio * (prices.length - 1)).round();

                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Stack(
                    children: [
                      // 1️⃣ 선
                      CustomPaint(
                        painter: _LineChartPainter(
                          prices: prices,
                          lineColor: widget.lineColor,
                        ),
                        size: Size(width, height),
                      ),

                      // 2️⃣ 선택된 점 + 말풍선
                      if (selectedIndex != null)
                        _SelectedPoint(
                          x: calcX(selectedIndex!),
                          y: calcY(prices[selectedIndex!]),
                          price: prices[selectedIndex!],
                          date: dates[selectedIndex!],
                          chartWidth: width,
                          chartHeight: height,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PriceChip(label: '최고 ${maxPrice.toStringAsFixed(2)}'),
              _PriceChip(label: '최저 ${minPrice.toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    );
  }
}
class _ValueLabel extends StatelessWidget {
  final String text;

  const _ValueLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}



/// ===============================
/// 차트 없을 때
/// ===============================
class _EmptyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        '차트 데이터가 없습니다',
        style: TextStyle(color: Colors.black54),
      ),
    );
  }
}


class _LineChartPainter extends CustomPainter {
  final List<double> prices;
  final Color lineColor;

  _LineChartPainter({
    required this.prices,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maxPrice = prices.reduce(max);
    final minPrice = prices.reduce(min);

    // ✅ 기준값: 최신값 (가장 자연스러움)
    final center = prices.last;

    // 실제 변동폭
    final realRange = (maxPrice - minPrice).abs();

    // ✅ 최소로 보여줄 범위 (통화별 체감용)
    final minVisualRange = center * 0.01; // 1% (DKK면 약 2.3원)

    // ✅ 최종 적용 범위
    final visualRange = max(realRange * 1.5, minVisualRange);

    final top = center + visualRange;
    final bottom = center - visualRange;
    final range = (top - bottom).abs();

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    for (int i = 0; i < prices.length; i++) {
      final x = size.width * (i / (prices.length - 1));

      final y =
          ((top - prices[i]) / range) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);
  }


  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.prices != prices ||
        oldDelegate.lineColor != lineColor;
  }
}


/// ===============================
/// 가격 표시 Chip
/// ===============================
class _PriceChip extends StatelessWidget {
  final String label;

  const _PriceChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

class _SelectedPoint extends StatelessWidget {
  final double x;
  final double y;
  final double price;
  final DateTime date;
  final double chartWidth;
  final double chartHeight;

  const _SelectedPoint({
    required this.x,
    required this.y,
    required this.price,
    required this.date,
    required this.chartWidth,
    required this.chartHeight,
  });

  @override
  Widget build(BuildContext context) {
    const tooltipWidth = 70.0;
    const tooltipHeight = 48.0;
    const dotSize = 8.0;

    // ── 툴팁 위치 계산 ─────────────────
    double tooltipLeft = x - tooltipWidth / 2;
    tooltipLeft = tooltipLeft.clamp(4, chartWidth - tooltipWidth - 4);

    double tooltipTop = y - tooltipHeight - 12;
    if (tooltipTop < 4) {
      tooltipTop = y + 12;
    }

    final formattedDate = '${date.month}/${date.day}';

    return Stack(
      children: [
        // 🔵 정확한 위치의 점 (선 위)
        Positioned(
          left: x - dotSize / 2,
          top: y - dotSize / 2,
          child: Container(
            width: dotSize,
            height: dotSize,
            decoration: const BoxDecoration(
              color: AppColors.pointDustyNavy,
              shape: BoxShape.circle,
            ),
          ),
        ),

        // 🏷️ 툴팁 (점 기준 위/아래)
        Positioned(
          left: tooltipLeft,
          top: tooltipTop,
          child: Container(
            width: tooltipWidth,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4),
              ],
            ),
            child: Column(
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  '${price.toStringAsFixed(2)}원',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pointDustyNavy,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}