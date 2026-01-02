

import 'package:flutter/material.dart';
import 'package:test_main/models/cust_info.dart';
import 'package:test_main/screens/member/signup_8.dart';

import '../app_colors.dart';



class AgreementPage extends StatefulWidget {
  const AgreementPage({super.key, required this.custInfo, });
  final CustInfo custInfo;

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {

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
        AgreementItem(title: "전자금융거래기본약관"),
        AgreementItem(title: "전자금융서비스이용약관"),
        AgreementItem(title: "FB뱅킹서비스이용신청필수동의"),
      ],
    ),
    AgreementGroup(
      title: "상품 약관 동의",
      required: true,
      items: [
        AgreementItem(title: "입출금상품 이용약관"),
        AgreementItem(title: "상품설명서"),
      ],
    ),
    AgreementGroup(
      title: "금융상품의 중요사항 안내",
      required: true,
      items: const [], // 기존 약관 아님
      noticeItems: [
        ImportantNoticeItem(
          title: "우선설명 사항 [필수]",
          descriptions: [
            "이자율(중도해지이율, 만기해지이율 등) 및 산출근거",
          ],
        ),
        ImportantNoticeItem(
          title: "부담정보 및 금융소비자의 권리 사항 [필수]",
          descriptions: [
            "중도해지에 따른 불이익",
            "금리변동형 상품 안내",
            "휴면예금 및 출연(계좌의 거래중지)",
          ],
        ),
        ImportantNoticeItem(
          title: "예금성 상품 및 연계·제휴 서비스 [필수]",
          descriptions: [
            "예금상품의 내용, 계약의 해지·해지사유",
            "연계·제휴 서비스 제공 조건",
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("약관 동의"),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 20),
                ...agreements.map(_buildGroup),
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
                Navigator.push(context, MaterialPageRoute(builder: (_) => SignUp8Page(custInfo: widget.custInfo,)));
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
              // ✅ 전체동의 체크 아이콘 영역
              if (group.noticeItems == null)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      final newValue = !group.allChecked;
                      for (var item in group.items) {
                        item.checked = newValue;
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 13, 12),
                    child: Icon(
                      group.allChecked
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: group.allChecked
                          ? AppColors.mainPaleBlue
                          : Colors.grey,
                    ),
                  ),
                ),


              // ✅ 나머지 영역 = 펼침/접힘
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      group.expanded = !group.expanded;
                    });
                  },
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 5),
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
