import 'package:flutter/material.dart';
import 'package:test_main/screens/deposit/view.dart';
import 'package:test_main/screens/deposit/step_1.dart';
import 'package:test_main/screens/deposit/recommend.dart';
import 'package:test_main/screens/app_colors.dart';
import 'package:test_main/models/deposit/list.dart';
import 'package:test_main/services/deposit_service.dart';
import 'package:test_main/screens/deposit/step_3.dart';
import 'package:test_main/services/deposit_draft_service.dart';
import 'package:test_main/models/deposit/view.dart';
import 'package:test_main/models/terms.dart';
import 'package:test_main/services/terms_service.dart';

class DepositListPage extends StatefulWidget {
  const DepositListPage({super.key});

  @override
  State<DepositListPage> createState() => _DepositListPageState();
}

class _DepositListPageState extends State<DepositListPage> {
  final DepositService _service = DepositService();
  final DepositDraftService _draftService =  DepositDraftService();
  final TermsService _termsService = TermsService();
  late Future<List<DepositProductList>> _futureProducts;
  Uri? _depositImageUri;

  @override
  void initState() {
    super.initState();
    _futureProducts = _service.fetchProductList();
    _loadDepositImage();
  }

  void _reload() {
    setState(() {
      _futureProducts = _service.fetchProductList();
    });
    _loadDepositImage();
  }

  Future<void> _refreshProducts() async {
    _reload();
    await _futureProducts;
  }

  Future<void> _loadDepositImage() async {
    try {
      final TermsDocument? doc = await _termsService.fetchLatestDepositImage();

      if (!mounted) return;

      // 서버에 이미지가 없으면 기본 아이콘을 쓰도록 URI를 비웁니다.
      if (doc == null) {
        setState(() {
          _depositImageUri = null;
        });
        return;
      }

      final String rawPath =
      doc.downloadUrl.isNotEmpty ? doc.downloadUrl : doc.filePath;

      setState(() {
        _depositImageUri = _resolveTermsUri(rawPath);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {});
    }
  }

  Uri? _resolveTermsUri(String raw) {
    if (raw.isEmpty) return null;

    final Uri? parsed = Uri.tryParse(raw);
    if (parsed != null && parsed.hasScheme) return parsed;

    final Uri base = Uri.parse(TermsService.baseUrl);
    final String relativePath = raw.startsWith('/') ? raw.substring(1) : raw;
    return base.resolve(relativePath);
  }



  Future<void> _handleJoin(DepositProductList productList) async {
    final dpstId = productList.id;
    final draft = await _draftService.loadDraft(dpstId);

    final canResume =
        draft != null && draft.application != null && (draft.step) >= 2;

    if (canResume) {
      final resume = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('이어서 진행할까요?'),
            content: const Text('이전에 진행한 가입 내역이 있습니다. 이어서 진행하시겠어요?'),
            actions: [
              TextButton(
                onPressed: () async {
                  await _draftService.clearDraft(dpstId);
                  if (mounted) Navigator.of(context).pop(false);
                },
                child: const Text('새로 시작'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('이어하기'),
              ),
            ],
          );
        },
      );

      if (resume == true && mounted) {
        final application = draft!.application!;

        try {
          final product = await _service.fetchProductDetail(dpstId);
          application.product ??= product;
        } catch (_) {
          // 상세 정보를 불러오지 못해도 이어가기는 가능하도록 둡니다.
        }


        Navigator.pushNamed(
          context,
          DepositStep3Screen.routeName,
          arguments: application,
        );
        return;
      }
    }

    if (!mounted) return;

    DepositProduct? product;
    try {
      product = await _service.fetchProductDetail(dpstId);
    } catch (_) {
      // 상세 조회 실패 시 상품 정보 없이도 신규 가입을 진행합니다.
    }


    Navigator.pushNamed(
      context,
      DepositStep1Screen.routeName,
      arguments: DepositStep1Args(
        dpstId: dpstId,
        product: product,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        title: const Text(
          "외화예금상품",
          style: TextStyle(
            color: AppColors.pointDustyNavy,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.subIvoryBeige,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.pointDustyNavy),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI 추천 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, RecommendScreen.routeName);
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
                  "AI 외화예금 추천 받기",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            FutureBuilder<List<DepositProductList>>(
              future: _futureProducts,
              builder: (context, snapshot) {
                // 로딩
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                // 에러
                if (snapshot.hasError) {
                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '목록을 불러오는 중 오류가 발생했습니다.',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _reload,
                          icon: const Icon(Icons.refresh),
                          label: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  );
                }

                final products = snapshot.data ?? [];

                // 빈 목록
                if (products.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: AppColors.pointDustyNavy,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '조회된 외화예금 상품이 없습니다.',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.pointDustyNavy,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _reload,
                            icon: const Icon(Icons.refresh),
                            label: const Text('다시 불러오기'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // 정상 목록
                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "조회결과 [총 ${products.length}건]",
                        style:
                        const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _refreshProducts,
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: products.length,
                            separatorBuilder: (_, __) =>
                            const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final item = products[index];

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.mainPaleBlue,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.pointDustyNavy,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.info.isNotEmpty
                                          ? item.info
                                          : '상품 설명이 없습니다.',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 14),

                                    Row(
                                      children: [
                                        // 상세보기 버튼
                                        OutlinedButton(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              DepositViewScreen.routeName,
                                              arguments: DepositViewArgs(
                                                dpstId: item.id,
                                              ),
                                            );
                                          },
                                          style: OutlinedButton.styleFrom(
                                            minimumSize: const Size(90, 40),
                                            side: const BorderSide(
                                              color: AppColors.pointDustyNavy,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(6),
                                            ),
                                          ),
                                          child: const Text(
                                            "상세보기",
                                            style: TextStyle(
                                              color: AppColors.pointDustyNavy,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        // 가입하기 버튼
                                        ElevatedButton(
                                          onPressed: () => _handleJoin(item),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                            AppColors.pointDustyNavy,
                                            foregroundColor: Colors.white,
                                            minimumSize: const Size(90, 40),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(6),
                                            ),
                                          ),
                                          child: const Text(
                                            "가입하기",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),

                                        const Spacer(),

                                        SizedBox(
                                          width: 60,
                                          height: 60,
                                          child: _buildDepositImage(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepositImage() {
    if (_depositImageUri != null) {
      return Image.network(
        _depositImageUri.toString(),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _fallbackDepositIcon(),
      );
    }

    return Image.asset(
      "images/deposit.png",
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _fallbackDepositIcon(),
    );
  }

  Widget _fallbackDepositIcon() {
    return const Icon(
      Icons.savings,
      size: 50,
      color: AppColors.pointDustyNavy,
    );
  }

}
