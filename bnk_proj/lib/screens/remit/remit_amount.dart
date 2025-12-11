import 'package:flutter/material.dart';
import 'remit_done.dart';

class RemitAmountPage extends StatefulWidget {
  final String name;       // 받는 사람 이름
  final String account;    // 받는 사람 계좌/전화번호

  const RemitAmountPage({
    super.key,
    required this.name,
    required this.account,
  });

  @override
  State<RemitAmountPage> createState() => _RemitAmountPageState();
}

class _RemitAmountPageState extends State<RemitAmountPage> {
  String _inputAmount = ""; // 입력된 금액 문자열

  // 숫자에 3자리마다 콤마 찍어주는 함수
  String _formatNumber(String s) {
    if (s.isEmpty) return "";
    int val = int.tryParse(s) ?? 0;
    return val.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  // 키패드 숫자 입력 처리
  void _onKeyTap(String val) {
    if (_inputAmount.length >= 12) return;
    setState(() {
      if (_inputAmount.isEmpty && (val == "0" || val == "00")) return;
      _inputAmount += val;
    });
  }

  // 백스페이스 처리
  void _onBackspace() {
    if (_inputAmount.isNotEmpty) {
      setState(() {
        _inputAmount = _inputAmount.substring(0, _inputAmount.length - 1);
      });
    }
  }

  // 금액 추가 버튼 처리
  void _addAmount(int amount) {
    setState(() {
      int current = int.tryParse(_inputAmount) ?? 0;
      _inputAmount = (current + amount).toString();
    });
  }


  void _showConfirmationModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 아이콘 이미지
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.asset(
                    "images/icon1.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),


              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "${widget.name}님에게 ",
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: "${_formatNumber(_inputAmount)}원",
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: "\n이체하시겠습니까?",
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // 3. 받는 계좌 정보
              Text(
                "받는계좌: ${widget.account}",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 40),

              // 4. 하단 버튼
              Row(
                children: [
                  // 취소 버튼
                  Expanded(
                    child: SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("취소", style: TextStyle(fontSize: 16,
                            fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // [수정] 이체하기 버튼 (남색 배경 + 흰색 글씨)
                  Expanded(
                    child: SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          // 1. 모달 닫기
                          Navigator.pop(context);

                          // 2. 완료 화면으로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RemitDonePage(
                                    name: widget.name,
                                    amount: "${_formatNumber(_inputAmount)}원",
                                  ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3E5D9C),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("이체하기", style: TextStyle(fontSize: 16,
                            fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasAmount = _inputAmount.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.black),
              ],
            ),
            Text(
              widget.account,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소", style: TextStyle(color: Colors.black, fontSize: 16)),
          )
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                hasAmount ? "${_formatNumber(_inputAmount)}원" : "보낼금액",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: hasAmount ? Colors.black : Colors.grey[300],
                ),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("계좌이름: 100,000원", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _chipButton("+1만", () => _addAmount(10000)),
                    _chipButton("+5만", () => _addAmount(50000)),
                    _chipButton("+10만", () => _addAmount(100000)),
                    _chipButton("전액", () {}),
                  ],
                ),
                const SizedBox(height: 20),

                _buildNumberRow(["1", "2", "3"]),
                _buildNumberRow(["4", "5", "6"]),
                _buildNumberRow(["7", "8", "9"]),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _numberButton("00", onTap: () => _onKeyTap("00")),
                      _numberButton("0", onTap: () => _onKeyTap("0")),
                      InkWell(
                        onTap: _onBackspace,
                        borderRadius: BorderRadius.circular(40),
                        child: Container(
                          width: 80,
                          height: 60,
                          alignment: Alignment.center,
                          child: const Icon(Icons.backspace_outlined, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      // 금액이 있을 때만 버튼 활성화 -> 누르면 모달 띄우기
                      onPressed: hasAmount ? _showConfirmationModal : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEBEBEB),
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: const Color(0xFFF3F3F3),
                        disabledForegroundColor: Colors.grey,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("다음", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _numberButton(String text, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 60,
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  Widget _buildNumberRow(List<String> keys) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map((k) => _numberButton(k, onTap: () => _onKeyTap(k))).toList(),
      ),
    );
  }

  Widget _chipButton(String text, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
        side: BorderSide(color: Colors.grey[300]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }
}