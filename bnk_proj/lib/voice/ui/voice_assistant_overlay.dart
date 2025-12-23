
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:test_main/voice/ui/voice_ui_state.dart';
import 'package:test_main/voice/ui/voice_waveform.dart';

import '../controller/voice_session_controller.dart';

class VoiceAssistantOverlay extends StatefulWidget {
  final VoiceSessionController controller;

  const VoiceAssistantOverlay({
    super.key,
    required this.controller,
  });

  @override
  State<VoiceAssistantOverlay> createState() =>
      _VoiceAssistantOverlayState();
}

class _VoiceAssistantOverlayState extends State<VoiceAssistantOverlay> {

  @override
  Widget build(BuildContext context) {
    final overlayHeight = MediaQuery.of(context).size.height * 0.55;

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
          child: SizedBox(
            height: overlayHeight,
            child: Column(
              children: [
                const SizedBox(height: 13),

                // ⬆️ 드래그 핸들 (상단 고정)
                Container(
                  width: 70,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 16),

                // ⬇️ 나머지는 중앙으로
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
                                  const SizedBox(height: 8),
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