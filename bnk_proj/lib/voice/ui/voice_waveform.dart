import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:test_main/voice/ui/voice_ui_state.dart';


class VoiceWaveform extends StatefulWidget {
  final VoiceUiState state;
  final double volume; // 0.0 ~ 1.0

  const VoiceWaveform({
    super.key,
    required this.state,
    this.volume = 0.0,
  });

  @override
  State<VoiceWaveform> createState() => _VoiceWaveformState();
}

class _VoiceWaveformState extends State<VoiceWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 90, // ⭐️ 크게
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return CustomPaint(
            painter: _SiriWavePainter(
              state: widget.state,
              volume: widget.volume,
              time: _controller.value,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _SiriWavePainter extends CustomPainter {
  final VoiceUiState state;
  final double volume;
  final double time;

  _SiriWavePainter({
    required this.state,
    required this.volume,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (state == VoiceUiState.idle || state == VoiceUiState.thinking) return;

    final List<Path> paths = [];

    canvas.saveLayer(
      Offset.zero & size,
      Paint(), // 기본 normal
    );

    final centerY = size.height / 2;
    final width = size.width;

    final baseAmplitude =
    state == VoiceUiState.listening ? (12 + volume * 22) : 10;

    final layers = [
      _WaveLayer(0.6, 0.6, 0.0, const Color(0xFF3C4F76), 0.55),
      _WaveLayer(0.9, 1.0, 1.3, const Color(0xFF5F7DBA), 0.45),
      _WaveLayer(0.7, 0.30, 4.1, const Color(0xFF3C4F76), 0.25),
      _WaveLayer(0.8, 1.1, 2.6, const Color(0xFF8FA8D6), 0.40),
      _WaveLayer(0.2, 1.4, 2.6, const Color(0xFF909EB8), 0.40),
    ];

    for (final layer in layers) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 + layer.amplitude * 4
        ..strokeCap = StrokeCap.round
        ..blendMode = BlendMode.plus
        ..color = layer.color.withOpacity(layer.opacity);

      final path = Path();

      for (double x = 0; x <= width; x++) {
        final progress = x / width;

        final wave = math.sin(
          (progress * 2 * math.pi * layer.speed) +
              (time * 2 * math.pi) +
              layer.phase,
        );

        final noise = math.sin((progress + time) * 12.7) * 0.08;

        final y = centerY +
            (wave + noise) *
                baseAmplitude *
                layer.amplitude *
                _edgeDamping(progress);

        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      paths.add(path);
      canvas.drawPath(path, paint);
    }
    for (int i = 0; i < layers.length; i++) {
      final layer = layers[i];
      final path = paths[i]; //

      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2 + layer.amplitude * 1.5
        ..strokeCap = StrokeCap.round
        ..blendMode = BlendMode.plus
        ..color = Colors.white.withOpacity(0.08);

      canvas.drawPath(path, glowPaint);
    }


    canvas.restore();
  }

  double _edgeDamping(double t) {
    // 중앙은 크고, 양끝은 자연스럽게 사라지게
    return math.sin(math.pi * t);
  }

  @override
  bool shouldRepaint(covariant _SiriWavePainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.volume != volume ||
        oldDelegate.state != state;
  }
}

class _WaveLayer {
  final double speed;
  final double amplitude;
  final double phase;
  final Color color;
  final double opacity;

  _WaveLayer(
      this.speed,
      this.amplitude,
      this.phase,
      this.color,
      this.opacity,
      );
}




