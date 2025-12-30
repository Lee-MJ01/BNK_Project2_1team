import 'dart:convert';

import 'application.dart';

/// 예금 가입 진행 상황을 임시로 저장하는 초안 정보
class DepositDraft {
  final int? draftNo;
  final String dpstId;
  final String? customerCode;
  final String? currency;
  final int? month;
  final int step;
  final String? linkedAccountNo;
  final String? withdrawPassword;
  final String? depositPassword;
  final String? fxWithdrawCurrency;
  final int? amount;
  final bool autoRenewYn;
  final int? autoRenewTerm;
  final bool autoTerminationYn;
  final double? appliedRate;
  final double? appliedFxRate;
  final DateTime? updatedAt;
  final DepositApplication? application;

  const DepositDraft({
    this.draftNo,
    required this.dpstId,
    this.customerCode,
    this.currency,
    this.month,
    required this.step,
    this.linkedAccountNo,
    this.withdrawPassword,
    this.depositPassword,
    this.fxWithdrawCurrency,
    this.amount,
    this.autoRenewYn = false,
    this.autoRenewTerm,
    this.autoTerminationYn = false,
    this.appliedRate,
    this.appliedFxRate,
    this.updatedAt,
    this.application,
  });

  DepositDraft copyWith({
    int? draftNo,
    String? dpstId,
    String? customerCode,
    String? currency,
    int? month,
    int? step,
    String? linkedAccountNo,
    String? withdrawPassword,
    String? depositPassword,
    String? fxWithdrawCurrency,
    int? amount,
    bool? autoRenewYn,
    int? autoRenewTerm,
    bool? autoTerminationYn,
    double? appliedRate,
    double? appliedFxRate,
    DateTime? updatedAt,
    DepositApplication? application,
  }) {
    return DepositDraft(
      draftNo: draftNo ?? this.draftNo,
      dpstId: dpstId ?? this.dpstId,
      customerCode: customerCode ?? this.customerCode,
      currency: currency ?? this.currency,
      month: month ?? this.month,
      step: step ?? this.step,
      linkedAccountNo: linkedAccountNo ?? this.linkedAccountNo,
      withdrawPassword: withdrawPassword ?? this.withdrawPassword,
      depositPassword: depositPassword ?? this.depositPassword,
      fxWithdrawCurrency: fxWithdrawCurrency ?? this.fxWithdrawCurrency,
      amount: amount ?? this.amount,
      autoRenewYn: autoRenewYn ?? this.autoRenewYn,
      autoRenewTerm: autoRenewTerm ?? this.autoRenewTerm,
      autoTerminationYn: autoTerminationYn ?? this.autoTerminationYn,
      appliedRate: appliedRate ?? this.appliedRate,
      appliedFxRate: appliedFxRate ?? this.appliedFxRate,
      updatedAt: updatedAt ?? this.updatedAt,
      application: application ?? this.application,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'draftNo': draftNo,
      'dpstId': dpstId,
      'customerCode': customerCode,
      'currency': currency,
      'month': month,
      'step': step,
      'linkedAccountNo': linkedAccountNo,
      'withdrawPassword': withdrawPassword,
      'depositPassword': depositPassword,
      'fxWithdrawCurrency': fxWithdrawCurrency,
      'amount': amount,
      'autoRenewYn': autoRenewYn,
      'autoRenewTerm': autoRenewTerm,
      'autoTerminationYn': autoTerminationYn,
      'appliedRate': appliedRate,
      'appliedFxRate': appliedFxRate,
      'updatedAt': updatedAt?.toIso8601String(),
      'application': application?.toJson(),
    };
  }

  factory DepositDraft.fromJson(Map<String, dynamic> json) {
    return DepositDraft(
      draftNo: json['draftNo'] as int?,
      dpstId: json['dpstId']?.toString() ?? '',
      customerCode: json['customerCode']?.toString(),
      currency: json['currency']?.toString(),
      month: _parseInt(json['month']),
      step: _parseInt(json['step']) ?? 1,
      linkedAccountNo: json['linkedAccountNo']?.toString(),
      withdrawPassword: json['withdrawPassword']?.toString(),
      depositPassword: json['depositPassword']?.toString(),
      fxWithdrawCurrency: json['fxWithdrawCurrency']?.toString(),
      amount: _parseInt(json['amount']),
      autoRenewYn: json['autoRenewYn'] == true ||
          json['autoRenewYn']?.toString().toUpperCase() == 'Y',
      autoRenewTerm: _parseInt(json['autoRenewTerm']),
      autoTerminationYn: json['autoTerminationYn'] == true ||
          json['autoTerminationYn']?.toString().toUpperCase() == 'Y',
      appliedRate: _parseDouble(json['appliedRate']),
      appliedFxRate: _parseDouble(json['appliedFxRate']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      application: json['application'] != null
          ? DepositApplication.fromJson(
              json['application'] is String
                  ? jsonDecode(json['application'] as String)
                  : Map<String, dynamic>.from(json['application'] as Map))
          : null,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }
}
