

import 'package:flutter/material.dart';
import 'package:test_main/models/cust_info.dart';
import 'package:test_main/screens/member/signup_18.dart';
import '../app_colors.dart';


class AcctAgreementPage extends StatefulWidget {
  const AcctAgreementPage({super.key, required this.custInfo});
  final CustInfo custInfo;

  @override
  State<AcctAgreementPage> createState() => _AcctAgreementPageState();
}

class _AcctAgreementPageState extends State<AcctAgreementPage> {

  final SingleAgreementItem confirmProductNotice =
  SingleAgreementItem(
    title:
    "본인은 위 예금상품의 약관 및 상품설명서를 제공받고 "
        "예금상품의 중요한 사항을 충분히 이해한 후 "
        "상품에 가입함을 확인합니다.",
    required: true,
  );


  final List<AgreementGroup> agreements = [
    AgreementGroup(
      title: "전자금융 약관 동의",
      required: true,
      items: [
        AgreementItem(title: "KB국민인증서 서비스설명서"),
        AgreementItem(title: "KB국민인증서 서비스 이용약관"),
        AgreementItem(title: "KB본인확인서비스 이용약관"),
        AgreementItem(title: "고유식별정보 수집·이용 동의서(FB국민인증서)"),
        AgreementItem(title: "개인(신용)정보 수집·이용 동의서(FB국민인증서)"),
        AgreementItem(title: "전자금융거래기본약관"),
        AgreementItem(title: "전자금융서비스설명서"),
        AgreementItem(title: "전자금융서비스이용약관"),
        AgreementItem(title: "스타뱅킹서비스이용신청필수동의"),
      ],
    ),

    AgreementGroup(
      title: "상품 약관 동의",
      required: true,
      items: [
        AgreementItem(title: "예금거래기본약관"),
        AgreementItem(title: "입출금이자유로운예금"),
        AgreementItem(title: "FB스타통장 특약"),
        AgreementItem(title: "FB스타통장 상품설명서"),
        AgreementItem(
          title:
          "개인(신용)정보 수집·이용·제공·조회 동의서(비대면 계좌개설 안심차단 등록 여부 조회용)",
        ),
      ],
    ),


    AgreementGroup(
      title: "확인 및 안내사항",
      required: true,
      items: [
        AgreementItem(title: "예금자보호제도 확인(FB스타뱅킹)"),
        AgreementItem(title: "통장양도금지 확인(FB스타뱅킹)"),
        AgreementItem(title: "불법 탈법 차명거래 금지 설명 확인"),
        AgreementItem(title: "가상자산 관련 대고객 안내문(20240730)"),

      ],
    ),

    AgreementGroup(
      title: "금융상품의 중요사항 안내",
      required: true,
      items: const [],
      noticeItems: [
        ImportantNoticeItem(
          title: "우선설명 사항 [필수]",
          descriptions: [
            "이자율(중도해지이율, 만기해지이율, 만기후이율) 및 산출근거",
          ],
        ),
        ImportantNoticeItem(
          title: "부담정보 및 금융소비자의 권리 사항 [필수]",
          descriptions: [
            "중도 해지에 따른 불이익",
            "금리변동형 상품 안내",
            "자료열람요구권 행사에 관한 사항",
            "위법계약해지권 행사에 관한 사항",
            "금융상품 만기 전·후 안내(상품만기 알림 서비스)",
            "휴면예금 및 출연(계좌의 거래중지)",
            "예금자보호법에 관한 사항(예금자보호 여부 및 그 내용)",
            "민원처리 및 분쟁조정 절차",
          ],
        ),
        ImportantNoticeItem(
          title: "예금성 상품 및 연계·제휴 서비스 [필수]",
          descriptions: [
            "예금상품의 내용(계약기간, 이자의 지급시기 및 지급제한 사유)",
            "계약의 해제·해지",
            "연계·제휴 서비스의 내용, 제공받을 수 있는 요건, 제공기간",
            "이행책임, 변경 시 변경내용 및 그 사유",
            "중요사항 사전·사후 안내 방법",
          ],
        ),
      ],
    ),




  ];

  bool get isRequiredAllChecked =>
      agreements
          .where((g) => g.required)
          .every((g) => g.allChecked) &&
          (!confirmProductNotice.required ||
              confirmProductNotice.checked);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("약관 동의"),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 10),
                ...agreements.map(_buildGroup),
                _buildGrayNoticeText(),
                _buildSingleAgreement(confirmProductNotice),
                _buildSingleAgreementWarning(),
              ],
            ),
          ),

          // 다음 버튼
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: isRequiredAllChecked ? () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerInfoPage(custInfo: widget.custInfo,)));
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isRequiredAllChecked
                    ? AppColors.pointDustyNavy
                    : Colors.grey.shade300,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Text(
                "다음",
                style: TextStyle(
                  color: isRequiredAllChecked
                      ? Colors.white
                      : Colors.grey,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildGroup(AgreementGroup group) {
    return Padding(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 5),
      child: Column(
        children: [
          Row(
            children: [
              // ✅ 항상 같은 영역 차지
              SizedBox(
                width: 40,
                child: group.noticeItems == null
                    ? GestureDetector(
                  onTap: () {
                    setState(() {
                      final newValue = !group.allChecked;
                      for (var item in group.items) {
                        item.checked = newValue;
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Icon(
                      group.allChecked
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: group.allChecked
                          ? AppColors.mainPaleBlue
                          : Colors.grey,
                    ),
                  ),
                )
                    : const SizedBox(height: 48), // ⭐ 높이 맞추기용
              ),

              // 제목 영역
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      group.expanded = !group.expanded;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12), // ⭐ 핵심
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            group.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(
                          group.expanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 7,),
          const Divider(
            height: 10,
            thickness: 1,
            color: Color(0xFFE0E0E0),
          ),

          // 펼쳐지는 세부 항목
          if (group.expanded)
            group.noticeItems != null
                ? _buildImportantNotice(group)
                : Column(
              children: group.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(left: 24, right: 16),
                  child: ListTile(
                    leading: Icon(
                      item.checked
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: item.checked
                          ? AppColors.mainPaleBlue
                          : Colors.grey,
                    ),
                    title: Text(item.title),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.black38,
                    ),
                    onTap: () {
                      setState(() {
                        item.checked = !item.checked;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }




  Widget _buildImportantNotice(AgreementGroup group) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 16, top: 8),
      child: Column(
        children: group.noticeItems!.map((notice) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Icon(
                  notice.checked
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: notice.checked
                      ? AppColors.mainPaleBlue
                      : Colors.grey,
                ),
                title: Text(
                  notice.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  setState(() {
                    notice.checked = !notice.checked;
                  });
                },
              ),
              ...notice.descriptions.map(
                    (d) => Padding(
                  padding: const EdgeInsets.only(left: 48, bottom: 4),
                  child: Text(
                    "- $d",
                    style: const TextStyle(color: Color(0x8AD80000)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          );
        }).toList(),
      ),
    );
  }


  Widget _buildSingleAgreement(SingleAgreementItem item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: InkWell(
        onTap: () {
          setState(() {
            item.checked = !item.checked;
          });
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              item.checked
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: item.checked
                  ? AppColors.mainPaleBlue
                  : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSingleAgreementWarning() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(48, 0, 24, 12),
      child: Text(
        "⁕ 설명내용을 제대로 이해하지 못하였음에도 설명을 이해했다는 확인을 하는 경우, "
            "추후 권리구제가 어려울 수 있습니다.",
        style: const TextStyle(
          fontSize: 15,
          height: 1.4,
          color: Color(0xFFD80000), // 은행 앱 경고 레드
        ),
      ),
    );
  }


  Widget _buildGrayNoticeText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Text(
        "＊ 금융상품의 중요사항에 대한 일반적인 안내사항으로\n"
            "   세부내용은 상품설명서를 통해 확인하실 수 있습니다.\n\n"
            "＊ 금융소비자는 해당 상품 또는 연계·제휴 서비스에 대해\n"
            "   설명을 요구할 권리가 있으며, 궁금한 사항이 있을 경우\n"
            "   챗봇/상담센터(1588-9999) 또는 지정 직원에게 문의하시기 바랍니다.",
        style: const TextStyle(
          fontSize: 13,
          height: 1.5,
          color: Colors.black45,
        ),
      ),
    );
  }


}



class AgreementGroup {
  final String title;
  final bool required;
  bool expanded;
  final List<AgreementItem> items;

  // ⭐ 추가
  final Widget? description; // 중요사항 안내용
  final List<ImportantNoticeItem>? noticeItems;


  AgreementGroup({
    required this.title,
    required this.required,
    this.expanded = false,
    required this.items,
    this.description,
    this.noticeItems,
  });

  bool get allChecked {
    if (noticeItems != null) {
      return noticeItems!.every((e) => e.checked);
    }
    if (description != null) return true;
    return items.every((e) => e.checked);
  }
}


class AgreementItem {
  final String title;
  bool checked;

  AgreementItem({required this.title, this.checked = false});
}



class ImportantNoticeItem {
  final String title;
  final List<String> descriptions;
  bool checked;

  ImportantNoticeItem({
    required this.title,
    required this.descriptions,
    this.checked = false,
  });
}


class SingleAgreementItem {
  final String title;
  final bool required;
  bool checked;

  SingleAgreementItem({
    required this.title,
    required this.required,
    this.checked = false,
  });
}
