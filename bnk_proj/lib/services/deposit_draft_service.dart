import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/deposit/application.dart';
import '../models/deposit/draft.dart';

/// 외화예금 가입 진행 상황을 임시 저장/조회하는 로컬 서비스
class DepositDraftService {
  const DepositDraftService();

  static const _storage = FlutterSecureStorage();

  String _key(String dpstId) => 'deposit_draft_$dpstId';

  Future<DepositDraft?> loadDraft(String dpstId) async {
    final raw = await _storage.read(key: _key(dpstId));
    if (raw == null) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return DepositDraft.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<DepositDraft> saveDraft(
    DepositApplication application, {
    required int step,
    String? customerCode,
  }) async {
    final draft = DepositDraft(
      dpstId: application.dpstId,
      customerCode: customerCode ?? application.customerCode,
      currency: application.newCurrency.isNotEmpty
          ? application.newCurrency
          : null,
      month: application.newPeriodMonths,
      step: step,
      linkedAccountNo: application.withdrawType == 'fx'
          ? application.selectedFxAccount
          : application.selectedKrwAccount,
      autoRenewYn: application.autoRenew == 'apply',
      autoRenewTerm:
          application.autoRenew == 'apply' ? application.autoRenewCycle : null,
      updatedAt: DateTime.now(),
      application: application,
    );

    await _storage.write(
      key: _key(application.dpstId),
      value: jsonEncode(draft.toJson()),
    );

    return draft;
  }

  Future<void> clearDraft(String dpstId) async {
    await _storage.delete(key: _key(dpstId));
  }
}
