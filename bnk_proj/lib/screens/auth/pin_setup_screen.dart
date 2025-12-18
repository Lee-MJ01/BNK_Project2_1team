import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../app_colors.dart';

class PinSetupScreen extends StatefulWidget {
  final String userId;
  const PinSetupScreen({super.key, required this.userId});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _firstPin = "";  // 첫 번째 입력한 비번
  String _secondPin = ""; // 확인용 입력 비번
  bool _isConfirmStage = false; // 확인 단계 여부

  // 번호 입력 처리
  void _onKeyTap(String key) {
    setState(() {
      if (!_isConfirmStage) {
        if (_firstPin.length < 6) _firstPin += key;
        if (_firstPin.length == 6) _isConfirmStage = true; // 6자리 다 치면 확인 단계로
      } else {
        if (_secondPin.length < 6) _secondPin += key;
        if (_secondPin.length == 6) _verifyAndRegister(); // 6자리 다 치면 검증 및 등록
      }
    });
  }

  // 지우기 처리
  void _onBackspace() {
    setState(() {
      if (!_isConfirmStage) {
        if (_firstPin.isNotEmpty) _firstPin = _firstPin.substring(0, _firstPin.length - 1);
      } else {
        if (_secondPin.isNotEmpty) {
          _secondPin = _secondPin.substring(0, _secondPin.length - 1);
        } else {
          _isConfirmStage = false; // 확인 단계에서 다 지우면 이전 단계로
        }
      }
    });
  }

  // 최종 검증 및 서버 등록
  void _verifyAndRegister() async {
    if (_firstPin == _secondPin) {
      final result = await ApiService.registerPin(widget.userId, _firstPin);
      if (!mounted) return;

      if (result['status'] == 'SUCCESS') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('간편비밀번호 등록 완료!')));
        Navigator.pop(context); // 이전 화면(메인 등)으로 이동
      } else {
        _reset();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    } else {
      // 불일치 시 리셋
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('비밀번호가 일치하지 않습니다. 다시 입력해주세요.')));
      _reset();
    }
  }

  void _reset() {
    setState(() {
      _firstPin = "";
      _secondPin = "";
      _isConfirmStage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String displayPin = _isConfirmStage ? _secondPin : _firstPin;

    return Scaffold(
      appBar: AppBar(title: const Text('간편번호 설정')),
      body: Column(
        children: [
          const SizedBox(height: 60),
          Text(
            _isConfirmStage ? "확인을 위해 한 번 더 입력해주세요." : "사용하실 간편비밀번호\n6자리를 입력해주세요.",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          // PIN 점 표시 UI
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < displayPin.length ? AppColors.pointDustyNavy : Colors.grey[300],
                ),
              );
            }),
          ),
          const Spacer(),
          // 보안 키패드 UI
          _buildKeypad(),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    List<String> keys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "", "0", "back"];
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      color: Colors.grey[50],
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: keys.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.5,
        ),
        itemBuilder: (context, index) {
          String key = keys[index];
          if (key == "") return const SizedBox();
          if (key == "back") {
            return IconButton(onPressed: _onBackspace, icon: const Icon(Icons.backspace_outlined));
          }
          return InkWell(
            onTap: () => _onKeyTap(key),
            child: Center(
              child: Text(key, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }
}