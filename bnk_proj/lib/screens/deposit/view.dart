import 'package:flutter/material.dart';
import 'package:test_main/screens/app_colors.dart';
import 'package:test_main/screens/deposit/step_1.dart';
import 'package:test_main/screens/deposit/step_2.dart';

/// 외화적금 상세 화면
class DepositViewScreen extends StatefulWidget {
  static const routeName = "/deposit-view";

  final String title;

  const DepositViewScreen({
    super.key,
    required this.title,
  });

  @override
  State<DepositViewScreen> createState() => _DepositViewScreenState();
}

class _DepositViewScreenState extends State<DepositViewScreen> {
  /// 0: 상품안내, 1: 금리안내, 2: 상품약관
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: AppColors.pointDustyNavy,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.pointDustyNavy),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(), // 상단 캐릭터 + 요약
            const SizedBox(height: 20),
            _buildTabs(), // 탭 버튼 3개
            const SizedBox(height: 16),
            _buildTabContent(), // 탭별 내용
            const SizedBox(height: 24),
            _buildBottomButtons(context), // 가입하기 / 목록
          ],
        ),
      ),
    );
  }


  // ------------------------------------------------------------
// 상단 헤더 : 캐릭터 이미지 + 상품명 + 요약 + 요약 정보
// ------------------------------------------------------------
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.mainPaleBlue.withOpacity(0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.mainPaleBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                "images/character11.png",
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // 텍스트 박스
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "외화적금",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.pointDustyNavy,
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  "월단위 만기지정 가능한 적립식 외화예금\n"
                      "금액, 적립횟수 제한없이 정기 및 자유적립 가능",
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 14),

                // 요약 정보 3개 → 동일한 크기 유지
                Row(
                  children: [
                    Expanded(child: _summaryInfoBox("가입대상", "제한 없음")),
                    const SizedBox(width: 10),
                    Expanded(child: _summaryInfoBox("가입기간", "12개월")),
                    const SizedBox(width: 10),
                    Expanded(child: _summaryInfoBox("가입금액", "USD 1,000 이상")),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// ------------------------------------------------------------
// 요약 정보 박스
// ------------------------------------------------------------
  Widget _summaryInfoBox(String label, String value) {
    return Container(
      height: 75, // ← 2줄도 안정적으로 들어감
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.subIvoryBeige,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.mainPaleBlue.withOpacity(0.7),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.pointDustyNavy,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }





  // ------------------------------------------------------------
  // 탭 버튼 (상품안내 / 금리안내 / 상품약관)
  // ------------------------------------------------------------
  Widget _buildTabs() {
    final tabs = ["상품안내", "금리안내", "상품약관"];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.mainPaleBlue.withOpacity(0.9),
        ),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: List.generate(tabs.length, (idx) {
          final bool isActive = _currentTab == idx;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _currentTab = idx);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.pointDustyNavy
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  tabs[idx],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : AppColors.pointDustyNavy,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ------------------------------------------------------------
  // 탭 내용
  // ------------------------------------------------------------
  Widget _buildTabContent() {
    switch (_currentTab) {
      case 0:
        return _buildProductInfoTab();
      case 1:
        return _buildRateInfoTab();
      case 2:
        return _buildTermsTab();
      default:
        return const SizedBox.shrink();
    }
  }

  // ============================================================
  // [탭 1] 상품안내
  // ============================================================
  Widget _buildProductInfoTab() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.mainPaleBlue.withOpacity(0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailRow(
            "특징",
            "・ 1개월 단위로 금리가 올라가는 계단식 금리 구조\n"
                "・ 일부 출금도 가능",
          ),
          _detailRow("가입 대상", "제한 없음"),
          _detailRow("예금 유형", "외화거치식예금"),
          _detailRow(
            "가입 가능 통화",
            "USD(미국 달러), JPY(일본 엔), EUR(유럽 유로)",
          ),
          _detailRow(
            "예금액",
            "USD 1,000 / JPY 100,000 / EUR 1,000 이상",
          ),
          _detailRow("예금 가입 기간", "12개월"),
          _detailRow(
            "일부 출금",
            "・ 대상 계좌: 가입일로부터 1개월 이상 지난 계좌\n"
                "・ 가능 횟수: 최대 3회(만기 해지 포함)\n"
                "・ 최소 출금금액: USD 100, JPY 10,000, EUR 100 이상\n"
                "※ 통화별 예금액 이상의 잔액이 계좌에 남아있어야 합니다.",
          ),
          _detailRow(
            "가입할 수 있는 곳",
            "FLOBANK 웹사이트",
          ),
          _detailRow(
            "이자 받는 방법",
            "만기 시 한 번에 지급",
          ),
          _detailRow(
            "세제 혜택",
            "없음",
          ),
          const SizedBox(height: 24),

          // 예금자보호 안내
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.mainPaleBlue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.mainPaleBlue.withOpacity(0.9),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 로고 자리
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Image.asset(
                    "assets/deposit.png", // /images/deposit.png 대응(있으면)
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.shield,
                      color: AppColors.pointDustyNavy,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "이 예금은 예금자보호법에 따라 원금과 소정의 이자를 합하여 "
                        "1인당 1억원까지(본 은행의 다른 보호상품과 합산) 보호됩니다.",
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.6,
                      color: Colors.black87,
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

  Widget _detailRow(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.pointDustyNavy,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // [탭 2] 금리안내
  // ============================================================
  Widget _buildRateInfoTab() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.mainPaleBlue.withOpacity(0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 "예금금리 안내 + 조회" 영역
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "예금금리 안내",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.pointDustyNavy,
                ),
              ),
              ElevatedButton(
                onPressed: () => _showRateModal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pointDustyNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "조회",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "조회일자와 통화 선택 후 조회 버튼을 누르면 해당 기준일의 금리를 표시합니다.",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),

          // 이자지급방식
          _detailRow("이자지급방식", "만기일시지급식"),
          const SizedBox(height: 8),

          // 적용환율
          _detailRow(
            "적용환율",
            "외화예금을 원화로 입금(신규 입금 포함)하는 경우, 입금 시점의 대고객 전신환매도율(송금 보내실 때 환율)을 적용합니다.\n"
                "외화예금의 원금 및 이자를 원화로 지급할 때는 지급 시점의 대고객 전신환매입율(송금 받으실 때 환율)을 적용합니다.",
          ),

          const SizedBox(height: 24),

          // 중도해지금리
          const Text(
            "중도해지금리",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.pointDustyNavy,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "가입일 또는 최종 자동연장일 당시 고시한 이 상품의 중도해지금리 적용 (세금공제 전)",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),

          _simpleRateTable(
            rows: const [
              [
                "가입기간 10% 미만",
                "기본금리 × 10% × 경과일수/계약일수 (최저 연 0.10%)"
              ],
              [
                "가입기간 10% 이상 ~ 30% 미만",
                "기본금리 × 30% × 경과일수/계약일수 (최저 연 0.30%)"
              ],
              [
                "가입기간 30% 이상 ~ 80% 미만",
                "기본금리 × 50% × 경과일수/계약일수 (최저 연 0.50%)"
              ],
              [
                "가입기간 80% 이상",
                "기본금리 × 90% × 경과일수/계약일수 (최저 연 0.50%)"
              ],
            ],
          ),

          const SizedBox(height: 24),

          // 만기후금리
          const Text(
            "만기후금리",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.pointDustyNavy,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "가입일 또는 최종 자동연장일 당시 고시한 이 상품의 만기후금리 적용 (세금공제 전)\n"
                "※ 만기 후 경과기간 구간별로 만기후금리는 자동 적용됨",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),

          _simpleRateTable(
            rows: const [
              ["1개월 이내", "기본금리 × 50%"],
              ["1개월 초과", "기본금리 × 30% (최저 연 0.20%)"],
            ],
          ),
        ],
      ),
    );
  }

  Widget _simpleRateTable({required List<List<String>> rows}) {
    return Table(
      border: TableBorder.all(
        color: AppColors.mainPaleBlue.withOpacity(0.8),
      ),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(5),
      },
      children: [
        const TableRow(
          decoration: BoxDecoration(
            color: AppColors.subIvoryBeige,
          ),
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "예치기간 / 경과기간",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.pointDustyNavy,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "적용금리",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.pointDustyNavy,
                ),
              ),
            ),
          ],
        ),
        ...rows.map(
              (r) => TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  r[0],
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  r[1],
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 🔔 금리 상세 모달
  // ============================================================
  void _showRateModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        int modalTabIndex = 0; // 0~4

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          backgroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: StatefulBuilder(
            builder: (context, setStateModal) {
              return ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                  maxHeight: 700,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 상단 닫기 버튼 + 제목
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.mainPaleBlue.withOpacity(0.8),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "외화예금상세조회",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.pointDustyNavy,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.pointDustyNavy,
                            ),
                            splashRadius: 20,
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 조회 조건 박스
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.subIvoryBeige,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color:
                                  AppColors.mainPaleBlue.withOpacity(0.8),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "조회 조건",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.pointDustyNavy,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    "조회일자와 통화를 선택 후 조회 버튼을 누르면 해당 기준일의 금리를 표시합니다.",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                      height: 1.6,
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  // 폼
                                  Column(
                                    children: [
                                      // 조회일자
                                      Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            width: 80,
                                            child: Text(
                                              "조회일자",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.pointDustyNavy,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: TextField(
                                                    readOnly: true,
                                                    controller:
                                                    TextEditingController(
                                                      text: "2025-12-31",
                                                    ),
                                                    decoration:
                                                    const InputDecoration(
                                                      isDense: true,
                                                      border:
                                                      OutlineInputBorder(),
                                                      contentPadding:
                                                      EdgeInsets
                                                          .symmetric(
                                                        horizontal: 10,
                                                        vertical: 8,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8),
                                                    border: Border.all(
                                                      color: AppColors
                                                          .mainPaleBlue,
                                                    ),
                                                    color: Colors.white,
                                                  ),
                                                  child: IconButton(
                                                    onPressed: () {},
                                                    icon: const Icon(
                                                      Icons
                                                          .calendar_today_outlined,
                                                      size: 18,
                                                      color: AppColors
                                                          .pointDustyNavy,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // 통화
                                      Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            width: 80,
                                            child: Text(
                                              "통화",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.pointDustyNavy,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(8),
                                                border: Border.all(
                                                  color:
                                                  AppColors.mainPaleBlue,
                                                ),
                                              ),
                                              child:
                                              DropdownButtonHideUnderline(
                                                child:
                                                DropdownButton<String>(
                                                  value: "USD",
                                                  items: const [
                                                    DropdownMenuItem(
                                                      value: "USD",
                                                      child: Text(
                                                        "USD : 미국달러",
                                                      ),
                                                    ),
                                                  ],
                                                  onChanged: (_) {},
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),

                                      // 조회 버튼 (센터 정렬)
                                      Align(
                                        alignment: Alignment.center,
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                            AppColors.pointDustyNavy,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets
                                                .symmetric(
                                              horizontal: 40,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: const Text(
                                            "조회",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // 조회기준일시
                            const Text(
                              "조회기준일시 : 2025-12-31 16:13:27  |  통화 : USD(미국)",
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xff444444),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // 금리 카테고리 탭 (UI만, 데이터는 공통)
                            _buildRateCategoryTabs(
                              selectedIndex: modalTabIndex,
                              onTap: (idx) {
                                setStateModal(() {
                                  modalTabIndex = idx;
                                });
                              },
                            ),
                            const SizedBox(height: 10),

                            // 금리표
                            _buildRateModalTable(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRateCategoryTabs({
    required int selectedIndex,
    required Function(int) onTap,
  }) {
    final labels = [
      "일반외화예수금이율",
      "외화 거치식 정기예금",
      "더 와이드 외화적금",
      "외화수퍼플러스 예금",
      "외화 고단위 플러스 정기예금",
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(labels.length, (idx) {
          final bool isActive = selectedIndex == idx;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(
                labels[idx],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.pointDustyNavy,
                ),
              ),
              selected: isActive,
              onSelected: (_) => onTap(idx),
              selectedColor: AppColors.pointDustyNavy,
              backgroundColor: AppColors.subIvoryBeige,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          );
        }),
      ),
    );
  }


  Widget _buildRateModalTable() {
    return Column(
      children: [

        // ---------------------------------------------------
        // ① 테이블 헤더
        // ---------------------------------------------------
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.mainPaleBlue),
            color: AppColors.subIvoryBeige,
          ),
          child: Table(
            columnWidths: const {
              0: FixedColumnWidth(180),
              1: FixedColumnWidth(120),
              2: FixedColumnWidth(120),
            },
            children: const [
              TableRow(
                children: [
                  _RateCellHeader("구분"),
                  _RateCellHeader("거주자"),
                  _RateCellHeader("비거주자"),
                ],
              ),
            ],
          ),
        ),

        // ---------------------------------------------------
        // ② 외화보통예금 / 통지예금 섹션
        // ---------------------------------------------------
        Table(
          columnWidths: const {
            0: FixedColumnWidth(180),
            1: FixedColumnWidth(120),
            2: FixedColumnWidth(120),
          },
          border: TableBorder(
            left: BorderSide(color: AppColors.mainPaleBlue),
            right: BorderSide(color: AppColors.mainPaleBlue),
            horizontalInside: BorderSide(color: AppColors.mainPaleBlue),
          ),
          children: const [
            TableRow(
              children: [
                _RateCellBody("외화보통예금",
                    isLeftTitle: true, bold: true, shaded: true),
                _RateCellBody("3.27520"),
                _RateCellBody("3.30860"),
              ],
            ),
            TableRow(
              children: [
                _RateCellBody("외화통지예금",
                    isLeftTitle: true, bold: true, shaded: true),
                _RateCellBody("0.01000"),
                _RateCellBody("0.01000"),
              ],
            ),
          ],
        ),

        // ---------------------------------------------------
        // ③ 외화정기예금 (USD) 제목행 — 세로줄 제거용 Container
        // ---------------------------------------------------
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xffeef3ff),
            border: Border(
              left: BorderSide(color: AppColors.mainPaleBlue),
              right: BorderSide(color: AppColors.mainPaleBlue),
              bottom: BorderSide(color: AppColors.mainPaleBlue),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          child: const Text(
            "외화정기예금 (USD)",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.pointDustyNavy,
            ),
          ),
        ),

        // ---------------------------------------------------
        // ④ 외화정기예금 기간별 금리
        // ---------------------------------------------------
        Table(
          columnWidths: const {
            0: FixedColumnWidth(180),
            1: FixedColumnWidth(120),
            2: FixedColumnWidth(120),
          },
          border: TableBorder(
            left: BorderSide(color: AppColors.mainPaleBlue),
            right: BorderSide(color: AppColors.mainPaleBlue),
            horizontalInside: BorderSide(color: AppColors.mainPaleBlue),
            bottom: BorderSide(color: AppColors.mainPaleBlue),
          ),
          children: const [
            TableRow(children: [
              _RateCellBody("1개월", isLeftTitle: true),
              _RateCellBody("3.272520"),
              _RateCellBody("3.30860"),
            ]),
            TableRow(children: [
              _RateCellBody("2개월", isLeftTitle: true),
              _RateCellBody("3.28870"),
              _RateCellBody("3.32220"),
            ]),
            TableRow(children: [
              _RateCellBody("3개월", isLeftTitle: true),
              _RateCellBody("3.30220"),
              _RateCellBody("3.33590"),
            ]),
            TableRow(children: [
              _RateCellBody("4개월", isLeftTitle: true),
              _RateCellBody("3.33550"),
              _RateCellBody("3.36950"),
            ]),
            TableRow(children: [
              _RateCellBody("5개월", isLeftTitle: true),
              _RateCellBody("3.36880"),
              _RateCellBody("3.40320"),
            ]),
            TableRow(children: [
              _RateCellBody("6개월", isLeftTitle: true),
              _RateCellBody("3.40220"),
              _RateCellBody("3.43690"),
            ]),
            TableRow(children: [
              _RateCellBody("7개월", isLeftTitle: true),
              _RateCellBody("3.40510"),
              _RateCellBody("3.43980"),
            ]),
            TableRow(children: [
              _RateCellBody("8개월", isLeftTitle: true),
              _RateCellBody("3.40810"),
              _RateCellBody("3.44280"),
            ]),
            TableRow(children: [
              _RateCellBody("9개월", isLeftTitle: true),
              _RateCellBody("3.41100"),
              _RateCellBody("3.44580"),
            ]),
            TableRow(children: [
              _RateCellBody("10개월", isLeftTitle: true),
              _RateCellBody("3.41400"),
              _RateCellBody("3.44880"),
            ]),
          ],
        ),
      ],
    );
  }






  // ============================================================
  // [탭 3] 상품약관
  // ============================================================
  Widget _buildTermsTab() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.mainPaleBlue.withOpacity(0.8),
        ),
      ),
      child: Column(
        children: [
          _termsRow("예금거래기본약관"),
          Divider(
            height: 1,
            color: AppColors.mainPaleBlue.withOpacity(0.6),
          ),
          _termsRow("외화예금거래기본약관"),
          Divider(
            height: 1,
            color: AppColors.mainPaleBlue.withOpacity(0.6),
          ),
          _termsRow("BNK모아드림외화적금 상품 설명서"),
        ],
      ),
    );
  }

  Widget _termsRow(String label) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.pointDustyNavy,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.pointDustyNavy,
      ),
      onTap: () {
        // 실제 PDF/웹뷰 연결 시 여기서 처리
      },
    );
  }

  // ------------------------------------------------------------
  // 하단 버튼 : 가입하기 / 목록
  // ------------------------------------------------------------
  Widget _buildBottomButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // 가입하기 → Step1으로
              Navigator.pushNamed(context, DepositStep1Screen.routeName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointDustyNavy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "가입하기",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton(
          onPressed: () {
            // 목록 → 그냥 뒤로가기 (리스트에서 들어왔다고 가정)
            Navigator.pop(context);
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.pointDustyNavy),
            padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "목록",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.pointDustyNavy,
            ),
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------------------
// 모달 테이블 셀용 위젯
// --------------------------------------------------------------
class _RateCellHeader extends StatelessWidget {
  final String text;

  const _RateCellHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: AppColors.pointDustyNavy,
        ),
      ),
    );
  }
}

class _RateCellBody extends StatelessWidget {
  final String text;
  final bool isLeftTitle;
  final bool bold;
  final bool shaded;
  final bool center;
  final int colSpan;

  const _RateCellBody(
      this.text, {
        this.isLeftTitle = false,
        this.bold = false,
        this.shaded = false,
        this.center = false,
        this.colSpan = 1,
      });

  @override
  Widget build(BuildContext context) {
    final cell = Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      alignment: center
          ? Alignment.center
          : (isLeftTitle ? Alignment.centerLeft : Alignment.center),
      color: shaded
          ? AppColors.mainPaleBlue.withOpacity(0.12)
          : Colors.white,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          color: AppColors.pointDustyNavy,
        ),
      ),
    );

    // colSpan 처리는 Table 구조상 직접 병합이 어려움.
    // "colSpan == 3"일 때는 상위 TableRow에서 3칸 중 첫 번째에 이 위젯을 넣고
    // 나머지 2칸에는 SizedBox.shrink()를 넣는 방식으로 처리.
    return cell;
  }
}
