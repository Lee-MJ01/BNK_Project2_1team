



import 'package:flutter/material.dart';
import 'package:test_main/screens/member/signup_3.dart';

import '../../models/cust_info.dart';
import '../app_colors.dart';

class SignUp2Page extends StatefulWidget {
  final CustInfo custInfo;

  const SignUp2Page({
    super.key,
    required this.custInfo,
  });

  @override
  State<SignUp2Page> createState() => _SignUp2PageState();
}

class _SignUp2PageState extends State<SignUp2Page> {
  final TextEditingController _rrnFront = TextEditingController(); // 앞 6
  final TextEditingController _rrnBackFirst = TextEditingController(); // 뒤 1
  final FocusNode _frontFocus = FocusNode();
  final FocusNode _backFocus = FocusNode();
  bool isButtonEnabled = false;
  TextEditingController? _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.custInfo.name);
    _rrnBackFirst.addListener(_checkInput);
    Future.delayed(Duration(milliseconds: 300), () {
      _frontFocus.requestFocus();
    });
  }

  void _checkInput() {
    setState(() {
      isButtonEnabled = _rrnBackFirst.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _rrnFront.dispose();
    _rrnBackFirst.dispose();
    _frontFocus.dispose();
    _backFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text("본인확인", style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                const Text(
                  "주민등록번호를 입력해주세요",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 32),


                GestureDetector(
                  onTap: () {
                    // ✅ 앞 6자리가 아직 다 안 찼으면 앞자리로 포커스
                    if (_rrnFront.text.length < 6) {
                      _frontFocus.requestFocus();
                    }
                    // ✅ 앞 6자리 다 찼으면 뒤 1자리로 포커스
                    else {
                      _backFocus.requestFocus();
                    }
                  },

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 5),

                          /// 앞 6자리
                          Flexible(
                            flex: 4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (i) {
                                return Container(
                                  width: 14,
                                  alignment: Alignment.center,
                                  child: Text(
                                    i < _rrnFront.text.length ? _rrnFront.text[i] : "",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),

                          const SizedBox(width: 22),
                          const Text("-", style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 22),

                          /// 뒤 1자리 + 나머지 6자리는 ●●●●●●
                          Flexible(
                            flex: 5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(7, (i) {
                                if (i == 0) {
                                  // 첫 1자리만 숫자 그대로 표시
                                  return Container(
                                    width: 14,
                                    alignment: Alignment.center,
                                    child: Text(
                                      _rrnBackFirst.text.isNotEmpty ? _rrnBackFirst.text : "",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }

                                // 나머지 6자리 ●●●●●●
                                return const Icon(
                                  Icons.circle,
                                  size: 12,
                                  color: Colors.black,
                                );
                              }),
                            ),
                          ),

                          const SizedBox(width: 5),
                        ],
                      ),




                      const SizedBox(height: 10),

                      /// 언더라인도
                      Row(
                        children: const [
                          /// ✅ 왼쪽 짧게
                          Flexible(
                            flex: 4,   // 숫자 작을수록 짧아짐
                            child: Divider(
                              thickness: 2,
                              color: Color(0xFF40578A),
                            ),
                          ),

                          SizedBox(width: 40),

                          /// ✅ 오른쪽 길게
                          Flexible(
                            flex: 5,   // 숫자 클수록 길어짐
                            child: Divider(
                              thickness: 2,
                              color: Color(0xFF40578A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20,),


                /// ✅ 실제 입력은 이 TextField가 담당 (보이지 않게)
                Offstage(
                  offstage: true,
                  child: TextField(
                    focusNode: _frontFocus,
                    controller: _rrnFront,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    onChanged: (v) {
                      if (v.length == 6) {
                        _backFocus.requestFocus(); // ✅ 자동으로 뒤 첫 자리로 이동
                      }
                      setState(() {});
                    },
                  ),
                ),
                Offstage(
                  offstage: true,
                  child: TextField(
                    focusNode: _backFocus,
                    controller: _rrnBackFirst,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    onChanged: (v) {

                      // ✅ 정상 입력 (0 → 1)
                      if (v.length == 1) {
                        setState(() {});
                        return;
                      }

                      // ✅ 정상적인 백스페이스 삭제 (1 → 0)
                      if (v.isEmpty && _rrnFront.text.isNotEmpty) {
                        _frontFocus.requestFocus();

                        final text = _rrnFront.text;
                        _rrnFront.text = text.substring(0, text.length - 1);

                        _rrnFront.selection = TextSelection.fromPosition(
                          TextPosition(offset: _rrnFront.text.length),
                        );
                      }

                      setState(() {});
                    },
                  ),
                ),






                /// ✅ 이름 표시 + x 버튼
                TextField(
                  readOnly: true,
                  controller: _nameController,
                  style: const TextStyle(        // ✅ 이 줄 추가
                    fontSize: 18,                // ← 여기서 크기 조절
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: "이름",
                    suffixIcon: const Icon(Icons.clear),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF40578A), width: 2),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF40578A), width: 2),
                    ),
                  ),
                ),




              ],
            ),
          ),

          /// ✅ 하단 고정 버튼 + 입력 시 활성화
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: isButtonEnabled
                  ? () {
                // 🔹 주민번호 합치기
                final rrn = _rrnFront.text + _rrnBackFirst.text;

                // 🔹 이름 가져오기
                final name = _nameController!.text;

                widget.custInfo.rrn = rrn;

                // 🔹 SignUp3Page 로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SignUp3Page(
                      custInfo: widget.custInfo,
                    ),
                  ),
                );
              }
                  : null,
              child: Container(
                color: isButtonEnabled
                    ? AppColors.pointDustyNavy  // ✅ 활성화 시 파란색
                    : const Color(0xFFE9ECEF), // 비활성화 회색
                padding: const EdgeInsets.symmetric(vertical: 18),
                alignment: Alignment.center,
                child: Text(
                  "다음",
                  style: TextStyle(
                    color: isButtonEnabled ? Colors.white : Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ]
      ),
    );
  }
}
