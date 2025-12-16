import 'dart:convert';
import 'dart:typed_data';
import 'view.dart';

/// 예금 가입 플로우에서 사용하는 신청 정보 모델
class DepositApplication {
  DepositApplication({required this.dpstId});

  final String dpstId;

  // Step1 agreements
  bool agree1 = false;
  bool agree2 = false;
  bool agree3 = false;
  bool info1 = false;
  bool info2 = false;
  bool info3 = false;
  bool important1 = false;
  bool important2 = false;
  bool important3 = false;
  bool finalAgree = false;

  // Step2 input
  String withdrawType = 'krw';
  String? selectedKrwAccount;
  String? selectedFxAccount;
  String? fxWithdrawCurrency;
  String? withdrawPassword;

  String newCurrency = '';
  int? newAmount;
  int? newPeriodMonths;

  String autoRenew = 'no';
  int? autoRenewCycle;

  String depositPassword = '';
  String receiveMethod = 'email';

  // Product meta for UI/flow
  DepositProduct? product;

  // Signature
  Uint8List? signatureImage;
  String? signatureMethod;
  DateTime? signedAt;

  Map<String, dynamic> toJson() {
    return {
      'dpstId': dpstId,
      'agreements': {
        'agree1': agree1,
        'agree2': agree2,
        'agree3': agree3,
        'info1': info1,
        'info2': info2,
        'info3': info3,
        'important1': important1,
        'important2': important2,
        'important3': important3,
        'finalAgree': finalAgree,
      },
      'withdrawType': withdrawType,
      'selectedKrwAccount': selectedKrwAccount,
      'selectedFxAccount': selectedFxAccount,
      'fxWithdrawCurrency': fxWithdrawCurrency,
      'withdrawPassword': withdrawPassword,
      'newCurrency': newCurrency,
      'newAmount': newAmount,
      'newPeriodMonths': newPeriodMonths,
      'autoRenew': autoRenew,
      'autoRenewCycle': autoRenewCycle,
      'depositPassword': depositPassword,
      'receiveMethod': receiveMethod,
      'signature': signatureImage != null
          ? base64Encode(signatureImage!)
          : null,
      'signatureMethod': signatureMethod,
      'signedAt': signedAt?.toIso8601String(),

    };
  }
}

class DepositSubmissionResult {
  final String customerName;
  final String productName;
  final String newAccountNo;
  final String currency;
  final String amount;
  final String? rate;
  final String? maturityDate;
  final String? periodLabel;
  final String? withdrawalAccount;
  final String? withdrawCurrency;
  final String? withdrawAmount;
  final String? autoRenewLabel;
  final String? contractDateTime;

  const DepositSubmissionResult({
    required this.customerName,
    required this.productName,
    required this.newAccountNo,
    required this.currency,
    required this.amount,
    this.rate,
    this.maturityDate,
    this.periodLabel,
    this.withdrawalAccount,
    this.withdrawCurrency,
    this.withdrawAmount,
    this.autoRenewLabel,
    this.contractDateTime,
  });

  factory DepositSubmissionResult.fromJson(Map<String, dynamic> json) {
    return DepositSubmissionResult(
      customerName: json['customerName']?.toString() ?? '고객',
      productName: json['productName']?.toString() ?? '외화정기예금',
      newAccountNo: json['newAccountNo']?.toString() ?? '',
      currency: json['currency']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '',
      rate: json['rate']?.toString(),
      maturityDate: json['maturityDate']?.toString(),
      periodLabel: json['periodLabel']?.toString(),
      withdrawalAccount: json['withdrawalAccount']?.toString(),
      withdrawCurrency: json['withdrawCurrency']?.toString(),
      withdrawAmount: json['withdrawAmount']?.toString(),
      autoRenewLabel: json['autoRenewLabel']?.toString(),
      contractDateTime: json['contractDateTime']?.toString(),
    );
  }
}

class DepositCompletionArgs {
  final DepositApplication application;
  final DepositSubmissionResult result;

  const DepositCompletionArgs({
    required this.application,
    required this.result,
  });
}