import 'package:flutter/material.dart';
import 'package:test_main/screens/app_colors.dart';
import 'package:test_main/screens/deposit/step_1.dart';
import 'package:test_main/models/deposit/view.dart' as model;
import 'package:test_main/services/deposit_service.dart';
import 'package:test_main/models/terms.dart';
import 'package:test_main/services/terms_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DepositViewArgs {
  final String dpstId;

  const DepositViewArgs({required this.dpstId});
}

/// 외화적금 상세 화면
class DepositViewScreen extends StatefulWidget {
  static const routeName = "/deposit-view";

  final String dpstId;

  const DepositViewScreen({
    super.key,
    required this.dpstId,
  });


  @override
  State<DepositViewScreen> createState() => _DepositViewScreenState();
}

class _DepositViewScreenState extends State<DepositViewScreen> {
  /// 0: 상품안내, 1: 금리안내, 2: 상품약관
  int _currentTab = 0;

  final DepositService _service =  DepositService();
  late Future<model.DepositProduct> _futureProduct;
  final TermsService _termsService = TermsService();
  late Future<List<TermsDocument>> _futureTerms;

  @override
  void initState() {
    super.initState();
    _futureProduct = _service.fetchProductDetail(widget.dpstId);
    _futureTerms = _termsService.fetchTerms(status: 4);
  }


  void _reload() {
    setState(() {
      _futureProduct = _service.fetchProductDetail(widget.dpstId);
      _futureTerms = _termsService.fetchTerms(status: 4);
    });
  }


  Future<void> _refreshProduct() async {
    _reload();
    await Future.wait([
      _futureProduct,
      _futureTerms,
    ]);
  }



  @override
  Widget build(BuildContext context) {
    return FutureBuilder<model.DepositProduct>(
      future: _futureProduct,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('외화예금 상세'),
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(
                color: AppColors.pointDustyNavy,
              ),
            ),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '상품 정보를 불러오지 못했습니다.',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh),
                    label: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          );
        }

        final product = snapshot.data!;

        return Scaffold(
          backgroundColor: AppColors.backgroundOffWhite,

          appBar: AppBar(
            title: Text(
              product.name,
              style: const TextStyle(
                color: AppColors.pointDustyNavy,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0.5,
            iconTheme: const IconThemeData(
              color: AppColors.pointDustyNavy,
            ),
          ),

          // 스크롤 영역
          body: RefreshIndicator(
            onRefresh: _refreshProduct,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(product),
                  const SizedBox(height: 20),
                  _buildTabs(),
                  const SizedBox(height: 16),
                  _buildTabContent(product),
                ],
              ),
            ),
          ),

          //하단 고정 버튼
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: _buildBottomButtons(context, product),
            ),
          ),
        );
      },
    );
  }


  // ------------------------------------------------------------
  // 상단 헤더 : 캐릭터 이미지 + 상품명 + 요약 + 요약 정보
  // ------------------------------------------------------------
  Widget _buildHeader(model.DepositProduct product) {
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
      child: Column( // ✅ Row → Column
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // =========================
          // 1️⃣ 상단: 이미지 + 텍스트
          // =========================
          Row(
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

              // 텍스트 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.pointDustyNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description.isNotEmpty
                          ? product.description
                          : product.info,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // =========================
          // 2️⃣ 하단: 요약 정보 3개
          // =========================
          Row(
            children: [
              Expanded(
                child: _summaryInfoBox("가입대상", "제한 없음"),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryInfoBox(
                  "가입기간",
                  product.fixedPeriodMonth != null
                      ? "${product.fixedPeriodMonth}개월"
                      : _buildPeriodLabel(product),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryInfoBox(
                  "가입금액",
                  _buildLimitLabel(product),
                ),
              ),
            ],
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
      constraints: const BoxConstraints(
        minHeight: 74, // ⭐ 핵심: 최소 높이 고정
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.subIvoryBeige,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.mainPaleBlue.withOpacity(0.7),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // ⭐ 세로 가운데
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: AppColors.pointDustyNavy,
            ),
          ),
        ],
      ),
    );
  }






  String _buildPeriodLabel(model.DepositProduct product) {
    if (product.fixedPeriodMonth != null) {
      return "${product.fixedPeriodMonth}개월";
    }
    if (product.minPeriodMonth != null && product.maxPeriodMonth != null) {
      return "${product.minPeriodMonth}~${product.maxPeriodMonth}개월";
    }
    return "제한 없음";
  }

  String _buildLimitLabel(model.DepositProduct product) {
    if (product.limits.isEmpty) {
      return "제한 없음";
    }

    final first = product.limits.first;
    return "${first.currency}\n${_fmt(first.min)} 이상";
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
  Widget _buildTabContent(model.DepositProduct product)
  {
    switch (_currentTab) {
      case 0:
        return _buildProductInfoTab(product);

        case 1:
          return _buildRateInfoTab(product);
      case 2:
        return _buildTermsTab(product);
      default:
        return const SizedBox.shrink();
    }
  }

  // ============================================================
  // [탭 1] 상품안내
  // ============================================================

  Widget _buildProductInfoTab(model.DepositProduct product) {
    // =========================
    // 1. 표시용 데이터 정리
    // =========================

    final String dpstDescript =
    product.description.isNotEmpty ? product.description : "상품 설명이 없습니다.";

    final String dpstTarget = "제한 없음";

    final String dpstType = "거치식 예금";

    final String dpstCurrency =
    product.dpstCurrency.isNotEmpty
        ? product.dpstCurrency.split(',').join(', ')
        : "통화 정보 없음";


    final String periodLabel =
    product.fixedPeriodMonth != null
        ? "${product.fixedPeriodMonth}개월"
        : (product.minPeriodMonth != null && product.maxPeriodMonth != null)
        ? "${product.minPeriodMonth}~${product.maxPeriodMonth}개월"
        : "기간 정보 없음";

    final String limitLabel =
    product.limits.isNotEmpty
        ? product.limits
        .map((e) => "${e.currency} ${_fmt(e.min)} 이상")
        .join("\n")
        : "한도 정보 없음";

    final String partialWithdraw =
    product.dpstPartWdrwYn == 'Y'
        ? "출금 가능"
        : "불가능";

    final String addPayLabel =
    product.dpstAddPayYn == 'Y'
        ? (product.addPayMaxCnt != null
        ? "가능 (최대 ${product.addPayMaxCnt}회)"
        : "가능")
        : "불가능";


    // =========================
    // 2. 공시 정보
    // =========================

    final String delibNo =
    product.deliberationNumber.isNotEmpty
        ? product.deliberationNumber
        : "-";

    final String delibDate =
    product.deliberationDate.isNotEmpty
        ? product.deliberationDate
        : "-";

    String validFrom = "-";
    String validTo = "";

    if (product.deliberationStartDate.isNotEmpty) {
      final start = DateTime.parse(product.deliberationStartDate);
      final end = DateTime(start.year + 1, start.month, start.day)
          .subtract(const Duration(days: 1));

      validFrom =
      "${start.year}.${start.month.toString().padLeft(2, '0')}.${start.day.toString().padLeft(2, '0')}";
      validTo =
      "${end.year}.${end.month.toString().padLeft(2, '0')}.${end.day.toString().padLeft(2, '0')}";
    }

    // =========================
    // 3. UI
    // =========================

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
          _detailRow("특징", dpstDescript),
          _detailRow("가입 대상", dpstTarget),
          _detailRow("예금 유형", dpstType),
          _detailRow("가입 가능 통화", dpstCurrency),
          _detailRow("예금액", limitLabel),
          _detailRow("예금 가입 기간", periodLabel),
          _detailRow("일부 출금", partialWithdraw),
          _detailRow("추가입금", addPayLabel),
          _detailRow("가입할 수 있는 곳", "FLOBANK 웹사이트 및 모바일 앱"),
          _detailRow("이자 받는 방법", "만기일시지급식"),
          _detailRow("세제 혜택", "없음"),

          const SizedBox(height: 24),


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
              // 아이콘 / 이미지
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Image.asset(
                  "images/deposit.png",
                  width: 90,
                  height: 90,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.info_outline,
                    size: 22,
                    color: AppColors.pointDustyNavy,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              //  텍스트
              const Expanded(
                child: Text(
                  "이 예금은 예금자보호법에 따라 원금과 소정의 이자를 합하여 "
                      "1인당 1억원까지 보호됩니다.",
                  style: TextStyle(fontSize: 13.5, height: 1.6),
                ),
              ),
            ],
          ),
        ),


        const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "공시승인번호",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  "이 내용은 법령 및 내부통제기준에 따른 광고관련 절차를 준수하였습니다.",
                  style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                ),
                const SizedBox(height: 12),
                Text(
                  "준법감시인 심의필 $delibNo (심의일자: $delibDate)",
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text(
                  validTo.isNotEmpty
                      ? "유효기일 $validFrom ~ $validTo"
                      : "유효기일 $validFrom",
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }




//////////////////////////////////////////////////////////////
// 금액 포맷터
//////////////////////////////////////////////////////////////
  String _fmt(int value) {
    return value.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ",");
  }

//////////////////////////////////////////////////////////////
// 디테일 Row 재사용 위젯
//////////////////////////////////////////////////////////////
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

  Widget _buildRateInfoTab(model.DepositProduct product) {
    final String delibNo =
    product.deliberationNumber.isNotEmpty
        ? product.deliberationNumber
        : "-";

    final String delibDate =
    product.deliberationDate.isNotEmpty
        ? product.deliberationDate
        : "-";

    final String validFrom =
    product.deliberationStartDate.isNotEmpty
        ? product.deliberationStartDate
        : "-";

    final String validTo = ""; // 종료일 없으면 빈 값

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

          const SizedBox(height: 30),

          // ------------------------------------------------------
          // 공시승인번호 영역
          // ------------------------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(

                  "공시승인번호",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(

                  "이 내용은 법령 및 내부통제기준에 따른 광고관련 절차를 준수하였습니다.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "준법감시인 심의필 $delibNo (심의일자: $delibDate)",
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  validTo.isNotEmpty
                      ? "유효기일 $validFrom ~ $validTo"
                      : "유효기일 $validFrom",
                  style: const TextStyle(

                    fontSize: 15,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

  }





  // ============================================================
  //  금리 상세 모달
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
  // [탭 3] 상품약관
  // ============================================================
  Widget _buildTermsTab(model.DepositProduct product) {



    final String delibNo =
    product.deliberationNumber.isNotEmpty
        ? product.deliberationNumber
        : "-";

    final String delibDate =
    product.deliberationDate.isNotEmpty
        ? product.deliberationDate
        : "-";

    String validFrom = "-";
    String validTo = "";

    if (product.deliberationStartDate.isNotEmpty) {
      final start = DateTime.parse(product.deliberationStartDate);
      final end = DateTime(start.year + 1, start.month, start.day)
          .subtract(const Duration(days: 1));

      validFrom =
      "${start.year}.${start.month.toString().padLeft(2, '0')}.${start.day.toString().padLeft(2, '0')}";
      validTo =
      "${end.year}.${end.month.toString().padLeft(2, '0')}.${end.day.toString().padLeft(2, '0')}";
    }

    return FutureBuilder<List<TermsDocument>>(
        future: _futureTerms,
        builder: (context, snapshot) {


          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }


          if (snapshot.hasError) {
            return Column(
              children: [
                const Text(
                  '약관 정보를 불러오지 못했습니다.',
                  style: TextStyle(color: Colors.redAccent),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 시도'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainPaleBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          }

          final terms = snapshot.data ?? [];
          final displayTerms = _buildTermsForProduct(product, terms);




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
              const Text(
              '상품설명서 및 약관',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.pointDustyNavy,
              ),





                ),

            const SizedBox(height: 8),
            Text(
              ' 최신 버전의 상품별 설명서와 약관을 제공합니다.',
              style: TextStyle(
                color: Colors.black87.withOpacity(0.7),
                height: 1.5,
              ),






                ),


                const SizedBox(height: 16),
                ...displayTerms.map((t) => _termsRow(t)).toList(),
                if (displayTerms.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.subIvoryBeige,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.mainPaleBlue.withOpacity(0.6),
                      ),
                    ),
                    child: const Text(
                      '조회된 약관이 없습니다. 잠시 후 다시 시도해주세요.',
                      style: TextStyle(color: Colors.black54),







                     ),

                  ),


                const SizedBox(height: 28),

                // ------------------------------------------------------
                // 공시승인번호 영역
                // ------------------------------------------------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                    ),



                  ),



                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "공시승인번호",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "이 내용은 법령 및 내부통제기준에 따른 광고관련 절차를 준수하였습니다.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "준법감시인 심의필 $delibNo (심의일자: $delibDate)",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        validTo.isNotEmpty
                            ? "유효기일 $validFrom ~ $validTo"
                            : "유효기일 $validFrom",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],




                  ),
                ),
              ],
            ),



          );
        },
    );
  }

  List<TermsDocument> _buildTermsForProduct(
      model.DepositProduct product, List<TermsDocument> terms) {



    final List<TermsDocument> result = [];

    final String productPdfUrl = _resolveProductPdfPath(product).trim();

    if (productPdfUrl.isNotEmpty) {
      result.add(
        TermsDocument(
          id: null,
          cate: null,
          order: null,
          title: '${product.name} 상품설명서',
          version: 1,
          regDate: null,
          filePath: productPdfUrl,
          content: '',
          downloadUrl: productPdfUrl,
        ),
      );
    }
    const specialTitle = 'flobank 외화예금 통합 특약';



    result.addAll(
      terms.where(
            (t) => t.title.trim().toLowerCase() == specialTitle.toLowerCase(),
      ),
    );

    return result;
  }

  String _resolveProductPdfPath(model.DepositProduct product) {
    final candidates = [product.infoPdfUrl.trim(), product.infoPdf.trim()];
    for (final path in candidates) {
      if (path.isNotEmpty) return path;
    }

    return '';
  }






  Widget _termsRow(TermsDocument terms) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.mainPaleBlue.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(10),
        color: AppColors.subIvoryBeige,
      ),


      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        title: Text(
          terms.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.pointDustyNavy,
          ),
        ),
        subtitle: Text(
          'v${terms.version} · ${terms.regDate ?? "등록일 미상"}',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            IconButton(
              onPressed: () => _openTerms(terms),
              icon:
              const Icon(Icons.description_outlined, color: AppColors.pointDustyNavy),
              tooltip: '보기',
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: () => _downloadTerms(terms),
              icon:
              const Icon(Icons.download_outlined, color: AppColors.pointDustyNavy),
              tooltip: '다운로드',
            ),







          ],
        ),
        onTap: () => _openTerms(terms),


      ),

    );
  }


  Future<void> _openTerms(TermsDocument terms) async {


    await _launchTerms(terms, LaunchMode.externalApplication);
  }

  Future<void> _downloadTerms(TermsDocument terms) async {
    await _launchTerms(terms, LaunchMode.externalApplication);
  }

  Uri? _buildTermsUri(TermsDocument terms) {
    final raw = terms.downloadUrl.trim().isNotEmpty
        ? terms.downloadUrl.trim()
        : terms.filePath.trim();

    if (raw.isEmpty) return null;

    final Uri? parsed = Uri.tryParse(raw);
    if (parsed == null) return null;
    if (parsed.hasScheme) return parsed;

    final Uri base = Uri.parse(TermsService.baseUrl);
    final String relativePath = raw.startsWith('/') ? raw.substring(1) : raw;
    return base.resolve(relativePath);
  }

  Future<void> _launchTerms(TermsDocument terms, LaunchMode mode) async {
    final uri = _buildTermsUri(terms);



    if (uri == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('유효한 약관 경로가 없습니다: ${terms.title}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    final ok = await launchUrl(uri, mode: mode);


    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('파일을 열 수 없습니다: ${terms.title}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // 하단 버튼 : 가입하기 / 목록
  // ------------------------------------------------------------
  Widget _buildBottomButtons(
      BuildContext context,
      model.DepositProduct product,
      ) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                DepositStep1Screen.routeName,
                arguments: DepositStep1Args(
                  dpstId: widget.dpstId,
                  product: product,
                ),
              );
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
