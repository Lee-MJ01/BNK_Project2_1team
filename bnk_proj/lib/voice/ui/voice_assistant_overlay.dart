
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:test_main/screens/deposit/list.dart';
import 'package:test_main/screens/deposit/view.dart';
import 'package:test_main/voice/core/voice_overlay_mode.dart';
import 'package:test_main/voice/overlay/voice_overlay_manager.dart';
import 'package:test_main/voice/ui/voice_nav_command.dart';
import 'package:test_main/voice/ui/voice_ui_state.dart';
import 'package:test_main/voice/ui/voice_waveform.dart';

import '../controller/voice_session_controller.dart';

class VoiceAssistantOverlay extends StatefulWidget {
  final VoiceSessionController controller;
  final VoiceOverlayMode mode;
  final ValueChanged<VoiceOverlayMode> onModeChanged;

  const VoiceAssistantOverlay({
    super.key,
    required this.controller, 
    required this.mode, 
    required this.onModeChanged,
  });

  @override
  State<VoiceAssistantOverlay> createState() =>
      _VoiceAssistantOverlayState();
}

class _VoiceAssistantOverlayState extends State<VoiceAssistantOverlay> {


  double _dragDy = 0;



  @override
  Widget build(BuildContext context) {
    final overlayHeight = MediaQuery.of(context).size.height * 0.55;

    switch (widget.mode) {
      case VoiceOverlayMode.expanded:
        return _buildExpanded(context, overlayHeight);

      case VoiceOverlayMode.minimized:
        return _buildMinimized(context);

      case VoiceOverlayMode.hidden:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildExpanded(BuildContext context, double overlayHeight) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                height: overlayHeight,
                color: Colors.black.withOpacity(0.15),
              ),
            ),
          ),
        ),

        // 🔹 음성 UI 본체
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            top: false, // 상단은 필요 없음
            child: SizedBox(
              height: overlayHeight,
              child: Column(
                children: [
                  const SizedBox(height: 65),

                  // ⬆️ 드래그 핸들
                  GestureDetector(
                    behavior: HitTestBehavior.translucent, // ← 중요
                    onVerticalDragUpdate: (d) {
                      _dragDy += d.delta.dy;
                    },
                    onVerticalDragEnd: (_) {
                      if (_dragDy > 40) {
                        // 아래로 충분히 끌림
                        widget.onModeChanged(VoiceOverlayMode.minimized);
                      } else if (_dragDy < -40) {
                        widget.onModeChanged(VoiceOverlayMode.expanded);
                      }
                      _dragDy = 0;
                    },
                    child: Container(
                      width: 80,
                      height: 15, // 터치 영역 확보 (4px는 너무 얇음)
                      alignment: Alignment.center,
                      child: Container(
                        width: 70,
                        height: 11,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),


                  const SizedBox(height: 15),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ValueListenableBuilder<VoiceUiState>(
                          valueListenable: widget.controller.uiState,
                          builder: (_, state, __) {
                            return ValueListenableBuilder<double>(
                              valueListenable: widget.controller.volume,
                              builder: (_, volume, __) {
                                return Column(
                                  children: [
                                    VoiceWaveform(
                                      state: state,
                                      volume: volume,
                                    ),
                                    const SizedBox(height: 7),
                                    Text(
                                      _stateText(state),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        GestureDetector(
                          onTap: _onMicTap,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF3C4F76),
                            ),
                            child: const Icon(
                              Icons.mic,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),


      ],
    );
  
  }

  Widget _buildMinimized(BuildContext context) {
    return Stack(
      children: [
        // 🔹 전체 영역은 터치 통과
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: Container(color: Colors.transparent),
          ),
        ),

        // 🔹 하단 바만 터치 가능
        Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onVerticalDragEnd: (d) {
              if (d.velocity.pixelsPerSecond.dy < -800) {
                widget.onModeChanged(VoiceOverlayMode.expanded);
              }
            },
            child: Container(
              margin: const EdgeInsets.all(12),
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.15),
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Icon(Icons.mic, color: Color(0xFF3C4F76)),
                  SizedBox(width: 12),
                  Expanded(child: Text(
                    "음성 가이드",
                    style: TextStyle(fontSize: 15, color: Colors.grey,),
                    )),
                  Icon(Icons.keyboard_arrow_up),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }




  void _onMicTap() {
    final state = widget.controller.uiState.value;

    if (state == VoiceUiState.idle) {
      widget.controller.startListening();
    } else if (state == VoiceUiState.listening) {
      widget.controller.stopListening();
    }
  }


  String _stateText(VoiceUiState state) {
    switch (state) {
      case VoiceUiState.idle:
        return "말씀해 주세요";
      case VoiceUiState.listening:
        return "듣고 있어요";
      case VoiceUiState.thinking:
        return "…";
      case VoiceUiState.speaking:
        return "안내 중";
    }
  }


}