import 'package:flutter/material.dart' hide Intent;
import 'package:test_main/screens/app_colors.dart';
import 'package:test_main/screens/deposit/step_2.dart';
import 'package:test_main/models/deposit/application.dart';

import 'package:test_main/models/terms.dart';
import 'package:test_main/services/terms_service.dart';
import 'package:test_main/services/deposit_draft_service.dart';
import 'package:test_main/voice/controller/voice_session_controller.dart';
import 'package:test_main/voice/scope/voice_session_scope.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:test_main/models/deposit/view.dart';

import 'package:test_main/voice/core/voice_intent.dart';

class DepositStep1Args {
  final String dpstId;
  final DepositProduct? product;
  final DepositApplication? prefill;

  const DepositStep1Args({
    required this.dpstId,
    this.product,
    this.prefill,
  });
}

class DepositStep1Screen extends StatefulWidget {
  static const routeName = "/deposit-step1";

  final String dpstId;
  final DepositProduct? product;
  final DepositApplication? prefill;

  const DepositStep1Screen({
    super.key,
    required this.dpstId,
    this.product,
    this.prefill,
  });


  @override
  State<DepositStep1Screen> createState() => _DepositStep1ScreenState();
}

class _DepositStep1ScreenState extends State<DepositStep1Screen> {
  bool allAgree = false;

  bool agree1 = false;
  bool agree2 = false;
  bool agree3 = false;

  final TermsService _termsService = TermsService();
  late Future<void> _termsFuture;
  List<TermsDocument> _terms = [];
  List<bool> _termChecks = [];

  bool info1 = false;
  bool info2 = false;
  bool info3 = false;

  bool important1 = false;
  bool important2 = false;
  bool important3 = false;

  bool finalAgree = false;

  final DepositDraftService _draftService =  DepositDraftService();

  @override
  void initState() {
    super.initState();
    _termsFuture = _loadTerms();
  }


  late VoiceSessionController _voiceController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _voiceController = VoiceSessionScope.of(context);
  }


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
              child: _termsAgreementSection(),
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
                    "[필수] 불법·차명거래 금지에 대한 설명 확인",
                    "「금융실명거래 및 비밀보장에 관한 법률」에 따라 타인의 명의를 이용하거나 명의를 대여하여 금융거래를 하는 행위는 금지되어 있으며, 이를 위반할 경우 관련 법령에 따라 제재 또는 처벌을 받을 수 있음을 확인합니다.",

                    info1,
                        (v) {
                      info1 = v;
                      _updateAllAgreeState();
                    },
                  ),
                  _paragraphCheck(
                    "[필수] 예금자보호제도 설명 확인",
                    "본 상품은 「예금자보호법」에 따라 보호되며, 보호 한도는 본인 명의 금융상품의 합산 원리금 기준 1인당 최대 5천만 원임을 확인합니다.",

                    info2,
                        (v) {
                      info2 = v;
                      _updateAllAgreeState();
                    },
                  ),
                  _paragraphCheck(
                    "[필수] 외화현찰 입·출금 수수료 안내 확인",
                    "외화현찰의 입금 또는 출금 시 환전 수수료 및 기타 부대비용이 발생할 수 있으며, 수수료율은 통화 종류 및 거래 조건에 따라 달라질 수 있음을 확인합니다.",

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
                    "[필수] 주요 상품내용 설명 확인",
                    "이자율, 이자지급 방식, 중도해지 시 적용되는 이율 및 만기 후 적용 이율 등 본 상품의 주요 내용을 충분히 설명받고 이해하였음을 확인합니다.",

                    important1,
                        (v) {
                      important1 = v;
                      _updateAllAgreeState();
                    },
                  ),
                  _paragraphCheck(
                    "[필수] 금융소비자의 권리 및 유의사항 확인",
                    "금융소비자는 「금융소비자 보호에 관한 법률」에 따라 자료열람 요구권, 청약철회권, 위법계약해지권 등의 권리를 보유하고 있으며, 이에 대한 설명을 받고 확인합니다.",

                    important2,
                        (v) {
                      important2 = v;
                      _updateAllAgreeState();
                    },
                  ),
                  _paragraphCheck(
                    "[필수] 예금성 상품 및 부가서비스 안내 확인",
                    "본 상품의 가입기간, 이자지급 조건, 자동연장 여부, 계약해지 방법 및 관련 부가서비스에 대한 안내를 확인합니다.",

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
  Widget _termsAgreementSection() {
    return FutureBuilder<void>(
      future: _termsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("약관 및 상품설명서"),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                ),
                child: const Text(
                  "약관 정보를 불러오지 못했습니다. 다시 시도해 주세요.",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() {
                    _termsFuture = _loadTerms();
                  }),
                  icon: const Icon(Icons.refresh, color: AppColors.pointDustyNavy),
                  label: const Text(
                    "새로고침",
                    style: TextStyle(color: AppColors.pointDustyNavy),
                  ),
                ),
              )
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("약관 및 상품설명서"),
            ..._terms.asMap().entries.map((entry) {
              return _termTile(entry.key, entry.value);
            }),
            if (_terms.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  "표시할 약관이 없습니다. 관리자에게 문의해 주세요.",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _termTile(int index, TermsDocument term) {
    final checked = index < _termChecks.length ? _termChecks[index] : false;

    return ListTile(
      contentPadding: EdgeInsets.zero,

      leading: Checkbox(
        value: checked,
        activeColor: AppColors.pointDustyNavy,

        // 약관 체크박스 직접 체크 방지 + 중앙 팝업 안내
        onChanged: (_) {
          if (!mounted) return;

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("안내"),
              content: const Text(
                "약관은 체크로 동의할 수 없습니다.\n"
                    "약관을 열어 내용을 확인한 후 동의해 주세요.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("확인"),
                ),
              ],
            ),
          );
        },
      ),




      title: Text(
        term.title,
        style: const TextStyle(
          color: AppColors.pointDustyNavy,
          fontWeight: FontWeight.w600,
        ),
      ),

      subtitle: Text(
        'v${term.version} · ${term.regDate ?? "등록일 미상"}',
        style: TextStyle(color: Colors.black54),
      ),

      //  여기서 팝업 뜸
      onTap: () => _showTermDialog(index, term),
    );
  }

  /// 약관 상세 팝업
  /// - 스크롤을 끝까지 내려야 '동의하기' 버튼 활성화
  /// - 팝업 내부에서만 상태 관리 (StatefulBuilder)
  /// - ScrollController 리스너는 다이얼로그 당 1번만 등록
  Future<void> _showTermDialog(int index, TermsDocument term) async {

    // 약관 본문이 있는지 여부 체크
    final hasContent = term.content.trim().isNotEmpty;

    // 다이얼로그 전용 스크롤 컨트롤러
    final scrollController = ScrollController();

    // 동의 가능 여부
    bool canAgree = false;

    // 리스너 중복 등록 방지
    bool listenerAttached = false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {

            /// ================================
            /// ⚠️ 스크롤 리스너는 단 1번만 등록
            /// ================================
            if (!listenerAttached) {
              scrollController.addListener(() {
                // 스크롤이 맨 아래 도달했을 때만 활성화
                if (!canAgree &&
                    scrollController.position.pixels >=
                        scrollController.position.maxScrollExtent) {
                  setState(() {
                    canAgree = true;
                  });
                }
              });

              listenerAttached = true;
            }

            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 20,
              ),

              title: Text(term.title),

              /// ================================
              /// 약관 본문 영역
              /// ================================
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.65,
                child: Scrollbar(
                  controller: scrollController,
                  thumbVisibility: true,   // 항상 스크롤바 표시

                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'v${term.version} · ${term.regDate ?? "등록일 미상"}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 12),

                        SelectableText(
                          hasContent
                              ? term.content
                              : "약관 본문을 불러오지 못했습니다.",
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// ================================
              /// 버튼 영역
              /// ================================
              actions: [
                /// 동의 버튼 — 스크롤 끝까지 내려야 활성화
                TextButton(
                  onPressed: canAgree
                      ? () {
                    setState(() {
                      _termChecks[index] = true;
                      _syncLegacyAgreement(index, true);
                      _updateAllAgreeState();
                    });

                    Navigator.pop(context);
                  }
                      : null,
                  child: Text(
                    "동의하기",
                    style: TextStyle(
                      color: canAgree ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),

                /// 닫기 버튼
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("닫기"),
                ),
              ],
            );
          },
        );
      },
    );

    /// ================================
    /// 다이얼로그가 닫히면 메모리 정리
    /// ================================
    scrollController.dispose();
  }






  Future<void> _openTermFile(TermsDocument term) async {
    final uri = Uri.tryParse(term.downloadUrl);
    if (uri == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('유효한 약관 경로가 없습니다: ${term.title}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('파일을 열 수 없습니다: ${term.title}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _loadTerms() async {
    final terms = await _termsService.fetchTerms(status: 4);
    setState(() {
      _terms = terms;
      _termChecks = List<bool>.filled(terms.length, false);
      agree1 = false;
      agree2 = false;
      agree3 = false;
    });
  }

  void _syncLegacyAgreement(int index, bool value) {
    if (index == 0) agree1 = value;
    if (index == 1) agree2 = value;
    if (index == 2) agree3 = value;
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
          "본인은 본 예금상품의 약관, 상품설명서 및 주요 내용을 충분히 이해하였으며, 이에 동의하고 가입을 신청합니다.",
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
      scale: 0.92,
      child: CheckboxListTile(
        value: allAgree,
        dense: true,
        contentPadding: EdgeInsets.zero,
        visualDensity: const VisualDensity(
          horizontal: -4,
          vertical: -4,
        ),
        title: const Text(
          "모든 필수 항목에 동의합니다",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppColors.pointDustyNavy,
          ),
        ),
        activeColor: AppColors.pointDustyNavy,

        onChanged: (v) {
          setState(() {
            allAgree = v!;

            // ❌ 약관 자동동의 금지
            // _termChecks / agree1~3 건드리지 않음

            // ⭕ 확인 및 안내사항 자동 체크
            info1 = v;
            info2 = v;
            info3 = v;

            // ⭕ 중요사항 자동 체크
            important1 = v;
            important2 = v;
            important3 = v;

            // ⭕ 최종 동의 자동 체크
            finalAgree = v;
          });

          // 팝업 안내 메시지
          if (v == true && context.mounted && !_termsAgreementComplete) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("안내"),
                content: const Text(
                  "약관은 전체동의로 체크되지 않습니다.\n"
                      "각 약관을 열어 내용을 확인 후 동의해 주세요.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("확인"),
                  ),
                ],
              ),
            );
          }

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
              ? () async {
                  final application =
                      (widget.prefill ?? DepositApplication(dpstId: widget.dpstId))
                        ..product = widget.product
                        ..agree1 = _getTermAgree(0)
                    ..agree2 = _getTermAgree(1)
                    ..agree3 = _getTermAgree(2)
                    ..info1 = info1
                    ..info2 = info2
                    ..info3 = info3
                    ..important1 = important1
                    ..important2 = important2
                    ..important3 = important3
                    ..finalAgree = finalAgree;

                  await _draftService.saveDraft(application, step: 1);

                  if (!mounted) return;
                  if (_voiceController.isSessionActive) {
                    await _voiceController.sendClientIntent(
                      intent: Intent.confirm,
                      productCode: widget.dpstId,
                    );
                  } else {
                  Navigator.pushNamed(
                    context,
                    DepositStep2Screen.routeName,
                    arguments: application,
                  );
}
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
      _termsAgreementComplete &&
          info1 &&
          info2 &&
          info3 &&
          important1 &&
          important2 &&
          important3 &&
          finalAgree;

  bool get _termsAgreementComplete {
    if (_termChecks.isNotEmpty) {
      return _termChecks.every((v) => v);
    }
    return agree1 && agree2 && agree3;
  }

  // =============================
  // 전체 동의 상태 업데이트
  // =============================
  void _updateAllAgreeState() {
    setState(() {
      allAgree = _allChecked();
    });
  }

  bool _getTermAgree(int index) {
    if (_termChecks.isNotEmpty) {
      if (index < _termChecks.length) return _termChecks[index];
      return false;
    }

    if (index == 0) return agree1;
    if (index == 1) return agree2;
    if (index == 2) return agree3;
    return false;
  }
}
