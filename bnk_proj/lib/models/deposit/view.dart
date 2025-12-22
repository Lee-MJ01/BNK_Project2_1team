// models/deposit/view.dart

class DepositLimit {
  final String currency;
  final int min;
  final int max;

  const DepositLimit({
    required this.currency,
    required this.min,
    required this.max,
  });

  factory DepositLimit.fromJson(Map<String, dynamic> json) {
    return DepositLimit(
      currency: json['lmtCurrency']?.toString() ?? '',
      min: int.tryParse(json['lmtMinAmt']?.toString() ?? '') ?? 0,
      max: int.tryParse(json['lmtMaxAmt']?.toString() ?? '') ?? 0,
    );
  }
}

class DepositProduct {
  final String id;
  final String name;
  final String description;
  final String info;
  final String infoPdf;
  final String infoPdfUrl;
  final int infoPdfVersion;
  final String dpstCurrency;
  final String dpstPartWdrwYn; // Y / N
  final String dpstAddPayYn; // 추가납입 가능 여부
  final int? addPayMaxCnt;     // 추가입금 최대 횟수
  final String dpstAutoRenewYn;

  final List<DepositLimit> limits;
  final int? minPeriodMonth;
  final int? maxPeriodMonth;
  final int? fixedPeriodMonth;
  final String deliberationNumber;
  final String deliberationDate;
  final String deliberationStartDate;

  const DepositProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.info,
    required this.infoPdf,
    required this.infoPdfUrl,
    this.infoPdfVersion = 1,
    required this.dpstCurrency,
    required this.dpstPartWdrwYn,
    required this.limits,
    this.minPeriodMonth,
    this.maxPeriodMonth,
    this.fixedPeriodMonth,
    this.deliberationNumber = '',
    this.deliberationDate = '',
    this.deliberationStartDate = '',
    this.dpstAddPayYn = 'N',
    this.addPayMaxCnt,
    this.dpstAutoRenewYn = 'Y',

  });

  factory DepositProduct.fromJson(Map<String, dynamic> json) {
    return DepositProduct(
      id: json['dpstId']?.toString() ?? '',
      name: json['dpstName']?.toString() ?? '',
      description: json['dpstDescript']?.toString() ?? '',
      info: json['dpstInfo']?.toString() ?? '',
      infoPdf: json['dpstInfoPdf']?.toString() ?? '',
      infoPdfUrl: json['dpstInfoPdfUrl']?.toString() ?? '',

      infoPdfVersion:
      int.tryParse(json['dpstInfoPdfVersion']?.toString() ?? '') ?? 1,

      dpstCurrency: json['dpstCurrency']?.toString() ?? '',

      dpstPartWdrwYn: json['dpstPartWdrwYn']?.toString() ?? 'N',

      dpstAddPayYn: json['dpstAddPayYn']?.toString() ?? 'N',

      addPayMaxCnt: _tryParseInt(json['dpstAddPayMaxCnt']),

      dpstAutoRenewYn: json['dpstAutoRenewYn']?.toString() ?? 'Y',


      limits: (json['limits'] as List<dynamic>?)
          ?.map((e) => DepositLimit.fromJson(e))
          .toList() ??
          [],
      minPeriodMonth: _tryParseInt(json['periodMinMonth']),
      maxPeriodMonth: _tryParseInt(json['periodMaxMonth']),
      fixedPeriodMonth: _tryParseInt(json['periodFixedMonth']),
      deliberationNumber: json['dpstDelibNo']?.toString() ?? '',
      deliberationDate: json['dpstDelibDy']?.toString() ?? '',
      deliberationStartDate: json['dpstDelibStartDy']?.toString() ?? '',
    );
  }


  static int? _tryParseInt(dynamic v) {
    if (v == null) return null;
    return int.tryParse(v.toString());
  }
}
