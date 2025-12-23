import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/deposit/application.dart';
import '../models/deposit/draft.dart';
import 'deposit_service.dart';

/// 외화예금 가입 진행 상황을 임시 저장/조회하는 로컬+원격 서비스
class DepositDraftService {
  const DepositDraftService();

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _draftEndpoint = '${DepositService.mobileBaseUrl}/drafts';

  final http.Client _client = http.Client();

  String _key(String dpstId) => 'deposit_draft_$dpstId';

  Future<DepositDraft?> loadDraft(String dpstId) async {
    final localDraft = await _loadLocalDraft(dpstId);
    final token = await _storage.read(key: _tokenKey);

    if (token != null) {
      final remoteDraft = await _loadRemoteDraft(dpstId, token);

      if (remoteDraft != null) {
        final mergedApplication = remoteDraft.application ??
            _hydrateApplication(remoteDraft, fallback: localDraft?.application);

        final merged = remoteDraft.copyWith(application: mergedApplication);

        if (localDraft?.updatedAt != null &&
            merged.updatedAt != null &&
            localDraft!.updatedAt!.isAfter(merged.updatedAt!)) {
          return localDraft;
        }

        await _persistLocalDraft(merged);
        return merged;
      }
    }

    return localDraft;
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
      withdrawPassword: application.withdrawPassword,
      depositPassword:
          application.depositPassword.isNotEmpty ? application.depositPassword : null,
      amount: application.newAmount,
      autoRenewYn: application.autoRenew == 'apply',
      autoRenewTerm:
          application.autoRenew == 'apply' ? application.autoRenewCycle : null,
      autoTerminationYn: application.autoRenew == 'apply'
          ? application.autoTerminateAtMaturity
          : false,
      updatedAt: DateTime.now(),
      application: application,
    );

    await _persistLocalDraft(draft);
    await _persistRemoteDraft(draft);

    return draft;
  }

  Future<void> clearDraft(String dpstId) async {
    // 전자서명까지 완료된 시점에서는 로컬/원격 모두 임시 저장을 지운다.
    // DB 연결이 끊겨도 가입 흐름을 막지 않도록, 서버 삭제는 best-effort 로 처리한다.
    await _storage.delete(key: _key(dpstId));

    final token = await _storage.read(key: _tokenKey);
    if (token == null) return;

    try {
      await _client.delete(
        Uri.parse('$_draftEndpoint/$dpstId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
    } catch (_) {
      // 네트워크/DB 오류 시 로컬 삭제만 진행하고 무시합니다.
    }
  }

  Future<DepositDraft?> _loadLocalDraft(String dpstId) async {
    final raw = await _storage.read(key: _key(dpstId));
    if (raw == null) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return DepositDraft.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> _persistLocalDraft(DepositDraft draft) async {
    await _storage.write(
      key: _key(draft.dpstId),
      value: jsonEncode(draft.toJson()),
    );
  }

  Future<DepositDraft?> _loadRemoteDraft(String dpstId, String token) async {
    try {
      final response = await _client.get(
        Uri.parse('$_draftEndpoint/$dpstId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final map = jsonDecode(utf8.decode(response.bodyBytes))
            as Map<String, dynamic>;

        var draft = DepositDraft.fromJson(map);

        if (draft.application == null) {
          draft = draft.copyWith(application: _hydrateApplication(draft));
        }

        return draft;
      }
    } catch (_) {
      // DB 연결 또는 네트워크 오류는 이어가기 기능을 막지 않습니다.
    }

    return null;
  }

  Future<void> _persistRemoteDraft(DepositDraft draft) async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) return;

    try {
      await _client.put(
        Uri.parse('$_draftEndpoint/${draft.dpstId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'customerCode': draft.customerCode,
          'currency': draft.currency,
          'month': draft.month,
          'step': draft.step,
          'linkedAccountNo': draft.linkedAccountNo,
          'withdrawPassword': draft.withdrawPassword,
          'depositPassword': draft.depositPassword,
          'amount': draft.amount,
          'autoRenewYn': draft.autoRenewYn,
          'autoRenewTerm': draft.autoRenewTerm,
          'autoTerminationYn': draft.autoTerminationYn,
        }),
      );
    } catch (_) {
      // 서버 저장 실패 시 로컬 저장된 초안만 유지합니다.
    }
  }

  DepositApplication _hydrateApplication(
    DepositDraft draft, {
    DepositApplication? fallback,
  }) {
    if (fallback != null) return fallback;

    final inferredWithdrawType = draft.currency != null &&
            draft.currency!.toUpperCase() != 'KRW' &&
            draft.linkedAccountNo != null
        ? 'fx'
        : 'krw';

    final application = DepositApplication(dpstId: draft.dpstId)
      ..customerCode = draft.customerCode
      ..withdrawType = inferredWithdrawType
      ..selectedKrwAccount =
          inferredWithdrawType == 'krw' ? draft.linkedAccountNo : null
      ..selectedFxAccount =
          inferredWithdrawType == 'fx' ? draft.linkedAccountNo : null
      ..withdrawPassword = draft.withdrawPassword
      ..depositPassword = draft.depositPassword ?? ''
      ..newCurrency = draft.currency ?? ''
      ..newAmount = draft.amount
      ..newPeriodMonths = draft.month
      ..autoRenew = draft.autoRenewYn ? 'apply' : 'no'
      ..autoRenewCycle = draft.autoRenewTerm
      ..autoTerminateAtMaturity = draft.autoTerminationYn
      ..agree1 = true
      ..agree2 = true
      ..agree3 = true
      ..info1 = true
      ..info2 = true
      ..info3 = true
      ..important1 = true
      ..important2 = true
      ..important3 = true
      ..finalAgree = true;

    return application;
  }
}
