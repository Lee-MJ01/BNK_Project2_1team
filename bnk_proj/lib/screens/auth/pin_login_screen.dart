import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../main/bank_homepage.dart';
import '../app_colors.dart';

class PinLoginScreen extends StatefulWidget {
  final String userId;
  const PinLoginScreen({super.key, required this.userId});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  String _pin = "";
  bool _isLoading = false;

  // 번호 입력 (이름을 _onKeyTap으로 통일)
  void _onKeyTap(String value) {
    if (_pin.length < 6) {
      setState(() => _pin += value);
    }
    if (_pin.length == 6) {
      _verifyPin(); // 6자리 입력 시 즉시 검증
    }
  }

  // 삭제 로직 추가
  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  // 최종 검증 및 로그인
  void _verifyPin() async {
    setState(() => _isLoading = true);

    // ★ 백엔드 API 호출: PIN 전용 로그인
    Map<String, dynamic> result = await ApiService.loginWithPin(widget.userId, _pin);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['status'] == 'SUCCESS') {
      // 로그인 성공 시 메인으로 이동 (이전 기록 삭제)
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const BankHomePage()),
              (route) => false
      );
    } else {
      // 실패 시 알림 및 초기화
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? '인증번호가 일치하지 않습니다.'))
      );
      setState(() => _pin = ""); // 입력창 초기화
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("간편로그인")),
      body: Column(
        children: [
          const SizedBox(height: 60),
          // 아이디 표시 (어떤 아이디로 로그인하는지 알려주기 위함)
          Text("${widget.userId}님,", style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          const Text("간편비밀번호 6자리를 입력하세요", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),

          // PIN 도트 UI
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: 16, height: 16,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _pin.length ? AppColors.pointDustyNavy : Colors.grey[300]
              ),
            )),
          ),

          if (_isLoading) ...[
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],

          const Spacer(),
          _buildKeypad(),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    List<String> keys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "", "0", "back"];
    return Container(
      padding: const EdgeInsets.only(bottom: 20, top: 20),
      color: Colors.grey[50],
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: keys.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.6,
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
              child: Text(key, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }
}