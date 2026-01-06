import 'package:flutter/material.dart';
import 'package:test_main/models/deposit/application.dart';
import 'package:test_main/models/deposit/context.dart';
import 'package:test_main/models/survey_recommendation.dart';
import 'package:test_main/screens/app_colors.dart';
import 'package:test_main/screens/deposit/step_1.dart';
import 'package:test_main/services/deposit_service.dart';
import 'package:test_main/services/survey_service.dart';
import 'package:test_main/screens/deposit/survey.dart';

class RecommendScreen extends StatefulWidget {
  static const routeName = "/recommend";

  const RecommendScreen({super.key});

  @override
  State<RecommendScreen> createState() => _RecommendScreenState();
}

class _RecommendScreenState extends State<RecommendScreen> {
  static const int surveyId = 43;

  final DepositService _depositService = DepositService();
  final SurveyService _surveyService = SurveyService();

  late Future<_RecommendData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_RecommendData> _loadData() async {
    final context = await _depositService.fetchContext();
    final custCode = context.customerCode;
    if (custCode == null || custCode.isEmpty) {
      throw Exception('고객 정보를 찾을 수 없습니다.');
    }
    final recs = await _surveyService.fetchRecommendations(
      surveyId: surveyId,
      custCode: custCode,
    );
    return _RecommendData(context: context, recommendations: recs);
  }

  Future<void> _handleQuickJoin(
    SurveyRecommendation recommendation,
    DepositContext depositContext,
  ) async {
    try {
      final custCode = depositContext.customerCode;
      if (custCode == null || custCode.isEmpty) {
        throw Exception('고객 정보를 찾을 수 없습니다.');
      }

      final prefill = await _surveyService.fetchPrefill(
        surveyId: surveyId,
        custCode: custCode,
      );

      final preferredCurrency = prefill.preferredCurrency?.trim();
      final recommendedCurrency = recommendation.dpstCurrency.trim();
      final resolvedCurrency = (preferredCurrency != null &&
              preferredCurrency.isNotEmpty &&
              preferredCurrency.toUpperCase() ==
                  recommendedCurrency.toUpperCase())
          ? preferredCurrency
          : recommendedCurrency;

      final application = DepositApplication(dpstId: recommendation.dpstId)
        ..newCurrency = resolvedCurrency
        ..newAmount = prefill.preferredAmount
        ..newPeriodMonths = prefill.preferredPeriodMonths
        ..withdrawType = prefill.withdrawType ?? 'krw';

      if (application.withdrawType == 'krw' &&
          depositContext.krwAccounts.isNotEmpty) {
        if (prefill.preferredKrwAccountType == 'other' &&
            depositContext.krwAccounts.length > 1) {
          application.selectedKrwAccount =
              depositContext.krwAccounts[1].accountNo;
        } else {
          application.selectedKrwAccount =
              depositContext.krwAccounts.first.accountNo;
        }
      }

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        DepositStep1Screen.routeName,
        arguments: DepositStep1Args(
          dpstId: recommendation.dpstId,
          prefill: application,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('빠른 가입 준비 실패: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pointDustyNavy,
        title: const Text(
          "AI 외화예금 추천",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: FutureBuilder<_RecommendData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('추천 데이터를 불러오지 못했습니다: ${snapshot.error}'),
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('추천 데이터를 찾을 수 없습니다.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle("내 성향 기반 추천 Top3"),
                if (data.recommendations.isEmpty)
                  const Text('추천 결과가 없습니다. 잠시 후 다시 시도해주세요.'),
                ...data.recommendations.map(
                  (recommendation) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _productCard(
                      recommendation: recommendation,
                      onQuickJoin: () =>
                          _handleQuickJoin(recommendation, data.context),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        DepositSurveyScreen.routeName,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pointDustyNavy,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "외화예금 성향 테스트 다시하기",
                      style: TextStyle(
                        fontSize: 15,
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
      ),
    );
  }

  // -----------------------------------------------------
  // Section Title
  // -----------------------------------------------------
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.pointDustyNavy,
        ),
      ),
    );
  }

  // -----------------------------------------------------
  // Product Card UI
  // -----------------------------------------------------
  Widget _productCard({
    required SurveyRecommendation recommendation,
    required VoidCallback onQuickJoin,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.mainPaleBlue,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // 왼쪽 텍스트들
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.dpstName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pointDustyNavy,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  recommendation.dpstInfo.isNotEmpty
                      ? recommendation.dpstInfo
                      : recommendation.dpstDescript,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mainPaleBlue.withOpacity(0.30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '추천 ${recommendation.rankNo}순위',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.pointDustyNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: onQuickJoin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pointDustyNavy,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "빠른 가입",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),
          Column(
            children: [
              const Text("통화", style: TextStyle(fontSize: 13)),
              Text(
                recommendation.dpstCurrency,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointDustyNavy,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecommendData {
  final DepositContext context;
  final List<SurveyRecommendation> recommendations;

  const _RecommendData({
    required this.context,
    required this.recommendations,
  });
}
