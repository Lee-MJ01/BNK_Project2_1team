class SurveyRecommendation {
  final String dpstId;
  final String dpstName;
  final String dpstInfo;
  final String dpstDescript;
  final String dpstCurrency;
  final int rankNo;

  const SurveyRecommendation({
    required this.dpstId,
    required this.dpstName,
    required this.dpstInfo,
    required this.dpstDescript,
    required this.dpstCurrency,
    required this.rankNo,
  });

  factory SurveyRecommendation.fromJson(Map<String, dynamic> json) {
    return SurveyRecommendation(
      dpstId: json['dpstId']?.toString() ?? '',
      dpstName: json['dpstName']?.toString() ?? '',
      dpstInfo: json['dpstInfo']?.toString() ?? '',
      dpstDescript: json['dpstDescript']?.toString() ?? '',
      dpstCurrency: json['dpstCurrency']?.toString() ?? '',
      rankNo: int.tryParse(json['rankNo']?.toString() ?? '') ?? 0,
    );
  }
}

class SurveyPrefill {
  final String? preferredCurrency;
  final int? preferredPeriodMonths;
  final int? preferredAmount;
  final String? withdrawType;
  final String? preferredKrwAccountType;

  const SurveyPrefill({
    this.preferredCurrency,
    this.preferredPeriodMonths,
    this.preferredAmount,
    this.withdrawType,
    this.preferredKrwAccountType,
  });

  factory SurveyPrefill.fromJson(Map<String, dynamic> json) {
    return SurveyPrefill(
      preferredCurrency: json['preferredCurrency']?.toString(),
      preferredPeriodMonths:
          int.tryParse(json['preferredPeriodMonths']?.toString() ?? ''),
      preferredAmount: int.tryParse(json['preferredAmount']?.toString() ?? ''),
      withdrawType: json['withdrawType']?.toString(),
      preferredKrwAccountType:
          json['preferredKrwAccountType']?.toString(),
    );
  }
}
