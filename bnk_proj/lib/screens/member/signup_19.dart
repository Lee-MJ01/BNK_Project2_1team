
import 'package:flutter/material.dart';
import 'package:test_main/models/cust_acct.dart';
import 'package:test_main/models/cust_info.dart';
import 'package:test_main/screens/app_colors.dart';
import 'package:test_main/screens/member/signup_20.dart';

class ExtraInfoPage extends StatefulWidget {
  

  final CustInfo custInfo;


  const ExtraInfoPage({super.key,required this.custInfo});

  @override
  State<ExtraInfoPage> createState() => _ExtraInfoPageState();
}

class _ExtraInfoPageState extends State<ExtraInfoPage> {
  String jobType = "직장인";
  String purpose = "급여 및 생활비";
  String source = "근로 및 연금소득";
  bool isOwner = true;          // 거래자금 본인 소유
  bool isForeignTax = false;   // 해외 납세 의무자
  bool showForeignInfo = false;
  bool showNotice = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text("회원가입", style: TextStyle(color: Colors.black)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text("취소", style: TextStyle(color: Colors.black54)),
            ),
          ),
        ],
      ),

      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const SizedBox(height: 24),

                const Text(
                  "추가정보 등록",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                // 안내 박스
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.mainPaleBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "※ 은행 거래의 주요 목적이 ‘가상자산투자거래’인 경우, 거래목적을 ‘가상자산투자거래’로 선택해 주세요.",
                    style: TextStyle(
                      color: Color(0xFF2B4795),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                _selectField(
                  label: "직업 구분",
                  value: jobType,
                  onTap: _openJobSheet,// 시트 연결
                ),

                const SizedBox(height: 32),

                _selectField(
                  label: "거래목적",
                  value: purpose,
                  onTap: _openPurposeSheet, // 시트 연결
                ),

                const SizedBox(height: 32),

                _selectField(
                  label: "거래자금의 원천",
                  value: source,
                  onTap: _openSourceSheet,// 시트 연결
                ),
                const SizedBox(height: 40),

                _yesNoSelector(
                  title: "거래자금의 본인 소유인가요?",
                  value: isOwner,
                  onChanged: (v) => setState(() => isOwner = v),
                ),

                const SizedBox(height: 8),

                const Text(
                  "실소유자가 아닌 경우 온라인으로 무방문 입출금통장 신규가 불가합니다.",
                  style: TextStyle(fontSize: 13, color: Colors.black45),
                ),

                const SizedBox(height: 32),

                _yesNoSelector(
                  title: "해외 납세 의무자인가요?",
                  value: isForeignTax,
                  onChanged: (v) => setState(() => isForeignTax = v),
                ),

                const SizedBox(height: 20),

                Container(
                  margin: const EdgeInsets.only(top: 28),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목
                      Text(
                        "해외납세의무자 판단기준",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      SizedBox(height: 10),

                      // 내용
                      Text(
                        "• 해외납세의무가 있는지에 따른 판단은 각 국가의 세법에 따릅니다.\n\n"
                            "• 각 국가의 세법에 따라 조세목적상 거주자로 판단될 경우, "
                            "납세자번호 등 정보를 제출해야 합니다.\n\n"
                            "• (국제조세조정에 관한 법률 제36조, 제37조, 제61조 및 동법 시행령 제75조)\n\n"
                            "* (참고) 미국 해외납세의무자\n"
                            " - 미국 시민권자\n"
                            " - 미국 영주권자(green card 소지자)\n"
                            " - 일정기간 이상 미국 체류 요건을 충족하는 경우 "
                            "(최근 3년을 합하여 183일 이상인 경우 등)\n\n"
                            "• 각 국가의 해외납세의무자에 대한 판단은 OECD 자동 정보교환관련 안내 "
                            "(www.oecd.org/tax/automatic-exchange)를 참고해주시기 바랍니다.",
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),


                const SizedBox(height: 24),

                GestureDetector(
                  onTap: () => setState(() => showNotice = !showNotice),
                  child: Row(
                    children: [
                      const Icon(Icons.info, size: 18, color: Colors.black54),
                      const SizedBox(width: 6),
                      const Text("알려드립니다",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Icon(showNotice
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down),
                    ],
                  ),
                ),

                if (showNotice)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(14),
                    color: Colors.grey.shade100,
                    child: const Text(
                      "• 「특정 금융거래정보의 보고 및 이용 등에 관한 법률」 제5조의2 "
                          "(금융회사 등의 고객확인의무)에 따라 고객확인의무 관련 정보·자료를 수집합니다.\n\n"
                          "• 고객확인을 위한 정보·자료를 제공하지 않거나 검증할 수 없는 경우에는 "
                          "금융거래가 거절 또는 종료됩니다.\n\n"
                          "• 실소유자란 고객을 최종적으로 지배하거나 통제하는 자연인으로, "
                          "해당 금융거래의 궁극적 혜택을 보는 개인을 말합니다.\n\n"
                          "• 개설하려는 계좌가 타인을 위한 거래이거나, 실소유자가 따로 존재하는 경우 "
                          "영업점을 방문하여 개설하셔야 합니다.\n\n"
                          "• 거주지국이 [한국]이 아닌 경우에는 해당 국가의 [납세의무자]입니다.\n\n"
                          "• 해외납세의무자란 납세의무가 있는 거주지국가 혹은 국적국가를 의미합니다.\n\n"
                          "• 납세자번호 : 해당 국가 정부기관에서 발급한 신분증의 실명확인번호\n"
                          "  * (예시) 미국 SSN, 일본 My Number, 중국 거민신분증 등\n\n"
                          "* 납세자번호를 모르시는 경우\n"
                          " - TIN 미기재사유 : 미기재사유 선택\n"
                          " - 구체적 사유 : 납세번호 모름",
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),

                SizedBox(height: 40,)

              ],
            ),
          ),

          // 하단 버튼
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: jobType.isNotEmpty &&
                  purpose.isNotEmpty &&
                  source.isNotEmpty
                  ? () {
                CustAcct custAcct = CustAcct(purpose: purpose, source: source, isOwner: isOwner, salaryExist: false, manageBranch: false,);
                widget.custInfo.jobType = jobType;
                Navigator.push(
                    context,
                  MaterialPageRoute(
                      builder: (_) => DemandAccountOpenPage(custAcct: custAcct, custInfo: widget.custInfo)
                  )
                );
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointDustyNavy,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: const Text(
                "다음",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 공통 선택 필드
  Widget _selectField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 6),

        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.pointDustyNavy,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
      ],
    );
  }


  void _openJobSheet() {
    _openSelectSheet(
      title: "직업 선택",
      options: ["직장인", "개인사업자", "무직", "학생", "주부"],
      selected: jobType,
      onSelected: (v) => setState(() => jobType = v),
    );
  }

  void _openPurposeSheet() {
    _openSelectSheet(
      title: "거래목적 선택",
      options: [
        "급여 및 생활비",
        "저축 및 투자",
        "사업상 거래",
        "보험료 납부",
        "공과금 납부",
        "가상자산투자거래",
      ],
      selected: purpose,
      onSelected: (v) => setState(() => purpose = v),
    );
  }

  void _openSourceSheet() {
    _openSelectSheet(
      title: "거래자금의 원천 선택",
      options: [
        "근로 및 연금소득",
        "사업소득",
        "부동산 임대소득",
        "금융소득(이자 및 배당)",
        "상속/증여",
        "일시 재산양도로 인한 소득",
      ],
      selected: source,
      onSelected: (v) => setState(() => source = v),
    );
  }



  Future<void> _openSelectSheet({
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) async {
    String temp = selected;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.65
                  ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 헤더
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 옵션
                      Expanded(
                        child: ListView(
                          children: options.map((o) => ListTile(
                            title: Center(
                              child: Text(
                                o,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                  o == temp ? FontWeight.bold : FontWeight.normal,
                                  color: o == temp ? Colors.black : Colors.black54,
                                ),
                              ),
                            ),
                            onTap: () {
                              setModalState(() {
                                temp = o;
                              });
                            },
                          )).toList(),
                        ),
                      ),


                      const SizedBox(height: 20),

                      // 확인 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.pointDustyNavy,
                          ),
                          onPressed: () {
                            onSelected(temp);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "확인",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            );
          },
        );
      },

    );
  }

  Widget _yesNoSelector({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 10),

        Row(
          children: [
            _yesNoButton("아니오", !value, () => onChanged(false)),
            const SizedBox(width: 12),
            _yesNoButton("예", value, () => onChanged(true)),
          ],
        ),
      ],
    );
  }

  Widget _yesNoButton(String text, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: selected
                  ? AppColors.pointDustyNavy
                  : Colors.grey.shade300,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.pointDustyNavy : Colors.black,
            ),
          ),
        ),
      ),
    );
  }


}




