import 'dart:async' show Future, Timer;

import 'package:flutter/material.dart';
import 'package:test_main/screens/app_colors.dart';
import 'package:test_main/screens/member/signup_4.dart';

import '../../models/cust_info.dart';

class SignUp3Page extends StatefulWidget {
  final CustInfo custInfo;

  const SignUp3Page({
    super.key, required this.custInfo,
  });

  @override
  State<SignUp3Page> createState() => _SignUp3PageState();
}

class _SignUp3PageState extends State<SignUp3Page> {
  String carrier = "KT";
  final TextEditingController _phoneController = TextEditingController();

  bool get isButtonEnabled => _phoneController.text.length == 11;
  TextEditingController? _nameController;


  // 약관 체크 상태 저장
  bool allAgree = false;

  Map<String, bool> agreements = {
    "고유식별정보 처리 동의": false,
    "통신사 이용약관 동의": false,
    "본인확인 개인정보 수집·이용 동의": false,
    "본인확인 서비스 이용약관 동의": false,
    "[필수] 개인(신용)정보 수집·이용 동의": false,
  };


  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.custInfo.name);
  }

  void _selectCarrier() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        final carriers = [
          "SKT",
          "KT",
          "LG U+",
          "SKT 알뜰폰",
          "KT 알뜰폰",
          "LG U+ 알뜰폰",
          "Liiv M"
        ];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Text("통신사 선택",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ...carriers.map((c) =>
                ListTile(
                  title: Text(c),
                  onTap: () {
                    setState(() => carrier = c);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text("본인확인", style: TextStyle(color: Colors.black)),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                const Text(
                  "휴대폰 번호를 확인해주세요",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 32),

                /// 통신사 + 전화번호
                /// 통신사 + 전화번호 입력 (스타일 통일)
                Row(
                  children: [

                    /// 통신사 선택 영역 - 이름/주민번호와 같은 Underline 스타일
                    GestureDetector(
                      onTap: _selectCarrier,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFF40578A), // 파란 밑줄
                              width: 2,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              carrier,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.keyboard_arrow_down, size: 20),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    /// 번호 입력칸 (회색 밑줄 + 포커스 시 파란 밑줄)
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        maxLength: 11,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          counterText: "",
                          labelText: "휴대폰 번호",
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey, // 회색 밑줄
                              width: 2,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF40578A), // 파란색 포커스 라인
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),


                SizedBox(height: 46,),

                /// 🔥 주민번호 표시 (UI 형태만 유지하고 숫자 노출 X)
                Row(
                  children: [

                    /// 앞 6자리
                    Flexible(
                      flex: 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (i) {
                          return Text(
                            widget.custInfo.rrn![i],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(width: 22),
                    const Text("-", style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 22),

                    /// 뒤 1자리 + 마스킹 6자리
                    Flexible(
                      flex: 5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          /// 뒤 첫 1자리
                          Text(
                            widget.custInfo.rrn![6],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),

                          /// 마스킹 ●●●●●●
                          ...List.generate(
                            6,
                                (_) =>
                            const Icon(
                                Icons.circle, size: 12, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),


                /// 언더라인도
                Row(
                  children: const [

                    /// ✅ 왼쪽 짧게
                    Flexible(
                      flex: 4, // 숫자 작을수록 짧아짐
                      child: Divider(
                        thickness: 2,
                        color: Color(0xFF40578A),
                      ),
                    ),

                    SizedBox(width: 40),

                    /// ✅ 오른쪽 길게
                    Flexible(
                      flex: 5, // 숫자 클수록 길어짐
                      child: Divider(
                        thickness: 2,
                        color: Color(0xFF40578A),
                      ),
                    ),
                  ],
                ),


                SizedBox(height: 20,),

                /// ✅ 이름 표시 + x 버튼
                TextField(
                  readOnly: true,
                  controller: _nameController,
                  style: const TextStyle( // ✅ 이 줄 추가
                    fontSize: 18, // ← 여기서 크기 조절
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: "이름",
                    suffixIcon: const Icon(Icons.clear),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(0xFF40578A), width: 2),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(0xFF40578A), width: 2),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: GestureDetector(
        onTap: isButtonEnabled
            ? () {
          _showAgreementSheet();
        }
            : null,
        child: Container(
          height: 60,
          alignment: Alignment.center,
          color: isButtonEnabled ? AppColors.pointDustyNavy : Colors.grey
              .shade300,
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
    );
  }

  void _showAgreementSheet() {
    setState(() {
      allAgree = false;
      agreements.updateAll((key, value) => false);
    });


    Widget _buildAgreementItem(String title, Function bottomSetState) {
      final checked = agreements[title] ?? false;

      return GestureDetector(
        onTap: () {
          bottomSetState(() {
            agreements[title] = !checked;
            allAgree = agreements.values.every((v) => v == true);
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(
                checked ? Icons.check_circle : Icons.radio_button_unchecked,
                color: checked ? AppColors.mainPaleBlue : Colors.grey,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                  Icons.arrow_forward_ios, size: 16, color: Colors.black38),
            ],
          ),
        ),
      );
    }


    Widget _buildAllAgreeItem(Function bottomSetState) {
      return GestureDetector(
        onTap: () {
          bottomSetState(() {
            allAgree = !allAgree;
            agreements.updateAll((key, value) => allAgree);
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(
                allAgree ? Icons.check_circle : Icons.radio_button_unchecked,
                color: allAgree ? AppColors.mainPaleBlue : Colors.grey,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "약관 전체동의 [필수]",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, bottomSetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              maxChildSize: 0.95,
              minChildSize: 0.40,
              builder: (_, controller) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // X 버튼
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "약관동의",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      const Text(
                        "서비스 이용을 위한 필수 약관에 동의해주세요.",
                        style: TextStyle(color: Colors.black54),
                      ),

                      const SizedBox(height: 20),

                      Expanded(
                        child: ListView(
                          controller: controller,
                          children: [
                            _buildAllAgreeItem(bottomSetState),
                            const Divider(),
                            _buildAgreementItem("고유식별정보 처리 동의", bottomSetState),
                            _buildAgreementItem("통신사 이용약관 동의", bottomSetState),
                            _buildAgreementItem(
                                "본인확인 개인정보 수집·이용 동의", bottomSetState),
                            _buildAgreementItem(
                                "본인확인 서비스 이용약관 동의", bottomSetState),
                            _buildAgreementItem(
                                "[필수] 개인(신용)정보 수집·이용 동의", bottomSetState),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.pointDustyNavy,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _showLoadingAndGoNext();
                          },
                          child: const Text(
                            "동의하고 인증번호 요청",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }



  void _showLoadingAndGoNext() async {
    showDialog(
      context: context,
      barrierDismissible: false, // 뒤로가기 막기
      builder: (_)  => const LoadingDialog(),
    );

    // 3초 대기 (로딩 연출)
    await Future.delayed(const Duration(seconds: 3));

    if (context.mounted) {
      Navigator.pop(context); // 로딩 닫기

      widget.custInfo.phone = _phoneController.text;


      // SignUp4Page로 이동
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SignUp4Page(
          custInfo : widget.custInfo
        ),),
      );
    }
  }


}



class LoadingDialog extends StatefulWidget {
  const LoadingDialog({super.key});

  @override
  State<LoadingDialog> createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> {
  int index = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() {
        index = (index + 1) % 3;   // 점 3개 순환
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget _dot(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: active ? Colors.black : Colors.grey.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            "images/flobankloadingicon.png",
            width: 80,
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dot(index == 0),
              _dot(index == 1),
              _dot(index == 2),
            ],
          ),
        ],
      ),
    );
  }
}




