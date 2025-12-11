import 'package:flutter/material.dart';
import 'package:test_main/screens/app_colors.dart';
import 'package:test_main/screens/deposit/step_2.dart';

class DepositStep1Screen extends StatefulWidget {
  static const routeName = "/deposit-step1";

  const DepositStep1Screen({super.key});

  @override
  State<DepositStep1Screen> createState() => _DepositStep1ScreenState();
}

class _DepositStep1ScreenState extends State<DepositStep1Screen> {
  bool allAgree = false;

  bool agree1 = false;
  bool agree2 = false;
  bool agree3 = false;

  bool info1 = false;
  bool info2 = false;
  bool info3 = false;

  bool important1 = false;
  bool important2 = false;
  bool important3 = false;

  bool finalAgree = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        title: const Text(
          "약관동의",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.pointDustyNavy,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildStepHeader(),
            const SizedBox(height: 30),

            /// ================================
            /// 카드 1 - 약관 및 상품설명서
            /// ================================
            _cardBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("약관 및 상품설명서"),
                  _check("예금거래기본약관", agree1, (v) {
                    agree1 = v;
                    _updateAllAgreeState();
                  }),
                  _check("외화예금거래기본약관", agree2, (v) {
                    agree2 = v;
                    _updateAllAgreeState();
                  }),
                  _check("상품설명서", agree3, (v) {
                    agree3 = v;
                    _updateAllAgreeState();
                  }),
                ],
              ),
            ),

            /// ================================
            /// 카드 2 - 확인 및 안내사항
            /// ================================
            _cardBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("확인 및 안내사항"),
                  _paragraphCheck(
                    "[필수] 불법탈법·차명거래 금지 설명 확인",
                    "금융실명거래법에 따라 타인의 명의로 금융거래를 하면 처벌받을 수 있습니다.",
                    info1,
                        (v) {
                      info1 = v;
                      _updateAllAgreeState();
                    },
                  ),
                  _paragraphCheck(
                    "[필수] 예금자보호법 설명확인",
                    "가입 상품의 예금자보호 여부 및 보호 한도에 대한 설명을 들었습니다.",
                    info2,
                        (v) {
                      info2 = v;
                      _updateAllAgreeState();
                    },
                  ),
                  _paragraphCheck(
                    "[필수] 외화현찰수수료확인",
                    "외화현찰 입출금 시 환전 수수료가 발생할 수 있습니다.",
                    info3,
                        (v) {
                      info3 = v;
                      _updateAllAgreeState();
                    },
                  ),
                ],
              ),
            ),

            /// ================================
            /// 카드 3 - 금융상품의 중요사항 안내
            /// ================================
            _cardBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("금융상품의 중요사항 안내"),
                  _paragraphCheck(
                    "[필수] 우선설명 사항",
                    "이자율·중도해지 조건·만기후 이율 등을 확인했습니다.",
                    important1,
                        (v) {
                      important1 = v;
                      _updateAllAgreeState();
                    },
                  ),
                  _paragraphCheck(
                    "[필수] 부담정보 및 금융소비자의 권리",
                    "소비자 권리(자료열람·위법계약해지 등)에 대해 안내받았습니다.",
                    important2,
                        (v) {
                      important2 = v;
                      _updateAllAgreeState();
                    },
                  ),
                  _paragraphCheck(
                    "[필수] 예금성 상품 및 연계·제휴 서비스",
                    "가입기간·이자지급·계약해제 방법 등을 확인했습니다.",
                    important3,
                        (v) {
                      important3 = v;
                      _updateAllAgreeState();
                    },
                  ),
                ],
              ),
            ),

            /// ================================
            /// 카드 4 - 최종 동의
            /// ================================
            _finalAgreement(),
            const SizedBox(height: 20),

            /// ================================
            /// 카드 5 - 전체 동의
            /// ================================
            _cardBox(
              mini: true,
              child: _buildAllAgreeBox(),
            ),


            const SizedBox(height: 30),
            _buttons(context),
          ],
        ),
      ),
    );
  }

  // =============================
  // 공통 카드 UI
  // =============================
  Widget _cardBox({required Widget child, bool mini = false}) {
    return Container(
      width: double.infinity,
      padding: mini ? const EdgeInsets.symmetric(horizontal: 8, vertical: 6) : const EdgeInsets.all(18),
      margin: mini ? const EdgeInsets.only(bottom: 8) : const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.mainPaleBlue.withOpacity(0.35)),
        boxShadow: mini
            ? []
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }



  // =============================
  // Step Header UI
  // =============================
  Widget _buildStepHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepCircle("1", true),
        _divider(),
        _stepCircle("2", false),
        _divider(),
        _stepCircle("3", false),
      ],
    );
  }

  Widget _stepCircle(String num, bool active) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: active ? AppColors.pointDustyNavy : AppColors.mainPaleBlue,
          child: Text(
            num,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          num == "1" ? "약관동의" : num == "2" ? "정보입력" : "확인",
          style: TextStyle(
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? AppColors.pointDustyNavy : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _divider() => Container(height: 2, width: 40, color: AppColors.mainPaleBlue);

  // =============================
  // Section Title
  // =============================
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.pointDustyNavy,
        ),
      ),
    );
  }

  // =============================
  // 체크박스 UI
  // =============================
  Widget _check(String text, bool value, Function(bool) onChange) {
    return CheckboxListTile(
      title: Text(
        text,
        style: const TextStyle(
          color: AppColors.pointDustyNavy,
          fontWeight: FontWeight.w600,
        ),
      ),
      value: value,
      onChanged: (v) => setState(() => onChange(v!)),
      activeColor: AppColors.pointDustyNavy,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _paragraphCheck(String title, String content, bool value, Function(bool) onChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.pointDustyNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
          value: value,
          onChanged: (v) => setState(() => onChange(v!)),
          activeColor: AppColors.pointDustyNavy,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 48, bottom: 12),
          child: Text(
            content,
            style: TextStyle(
              color: AppColors.pointDustyNavy.withOpacity(0.6),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // =============================
  // 최종 동의 박스
  // =============================
  Widget _finalAgreement() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.mainPaleBlue.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.pointDustyNavy,
          width: 1.2,
        ),
      ),
      child: CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        activeColor: AppColors.pointDustyNavy,
        title: const Text(
          "본인은 예금상품의 약관 및 내용을 충분히 이해하였으며 가입을 확인합니다.",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.pointDustyNavy,
          ),
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Text(
            "※ 내용을 이해하지 못했음에도 동의하는 경우 추후 권리구제가 어려울 수 있습니다.",
            style: TextStyle(fontSize: 12, color: AppColors.pointDustyNavy, height: 1.4),
          ),
        ),
        value: finalAgree,
        onChanged: (v) {
          setState(() {
            finalAgree = v!;
            _updateAllAgreeState();
          });
        },
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }


  // =============================
  // 전체 동의 박스
  // =============================
  Widget _buildAllAgreeBox() {
    return Transform.scale(
      scale: 0.92,   // 체크박스까지 작아짐
      child: CheckboxListTile(
        value: allAgree,
        dense: true,
        contentPadding: EdgeInsets.zero,
        visualDensity: const VisualDensity(
          horizontal: -4,   // 가능한 최소 간격
          vertical: -4,
        ),
        title: const Text(
          "모든 필수 항목에 동의합니다",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,            // 더 작게
            color: AppColors.pointDustyNavy,
          ),
        ),
        activeColor: AppColors.pointDustyNavy,
        onChanged: (v) {
          setState(() {
            allAgree = v!;

            agree1 = v;
            agree2 = v;
            agree3 = v;

            info1 = v;
            info2 = v;
            info3 = v;

            important1 = v;
            important2 = v;
            important3 = v;

            finalAgree = v;
          });
        },
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }





  // =============================
  // 버튼 UI
  // =============================
  Widget _buttons(BuildContext context) {
    bool canNext = _allChecked();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mainPaleBlue,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "이전",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: canNext ? AppColors.pointDustyNavy : AppColors.mainPaleBlue,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            elevation: 0,
          ),
          onPressed: canNext
              ? () {
            Navigator.pushNamed(context, DepositStep2Screen.routeName);
          }
              : null,
          child: const Text(
            "다음",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // =============================
  // 체크 여부
  // =============================
  bool _allChecked() =>
      agree1 &&
          agree2 &&
          agree3 &&
          info1 &&
          info2 &&
          info3 &&
          important1 &&
          important2 &&
          important3 &&
          finalAgree;

  // =============================
  // 전체 동의 상태 업데이트
  // =============================
  void _updateAllAgreeState() {
    setState(() {
      allAgree = _allChecked();
    });
  }
}
