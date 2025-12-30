import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/deposit/application.dart';
import '../models/deposit/draft.dart';
import 'deposit_service.dart';

/// 외화예금 가입 진행 상황을 임시 저장/조회하는 로컬+원격 서비스
class DepositDraftService {
  DepositDraftService();

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _draftEndpoint = '${DepositService.serverUrl}/drafts';

  final http.Client _client = http.Client();

  String _key(String dpstId) => 'deposit_draft_$dpstId';

  Future<DepositDraft?> loadDraft(String dpstId) async {
    _log('loadDraft: start', data: {'dpstId': dpstId});
    final localDraft = await _loadLocalDraft(dpstId);
    final token = await _storage.read(key: _tokenKey);

    if (token != null) {
      final remoteDraft = await _loadRemoteDraft(dpstId, token);

      if (remoteDraft != null) {
        _log('loadDraft: remote draft loaded', data: _draftLog(remoteDraft));

        final mergedDraft = _mergeDrafts(
          primary: _fresherOf(remoteDraft, localDraft),
          secondary: remoteDraft == localDraft ? null : localDraft,
        );

        await _persistLocalDraft(mergedDraft);
        _log('loadDraft: merged draft stored locally',
            data: _draftLog(mergedDraft));
        return mergedDraft;
      }
    }

    return localDraft;
  }

  Future<DepositDraft> saveDraft(
    DepositApplication application, {
    required int step,
    String? customerCode,
  }) async {
    final currency = application.newCurrency.trim();
    final fxWithdrawCurrency = application.fxWithdrawCurrency?.trim();

    final draft = DepositDraft(
      dpstId: application.dpstId,
      customerCode: customerCode ?? application.customerCode,
      currency: currency.isNotEmpty ? currency.toUpperCase() : null,
      month: application.newPeriodMonths,
      step: step,
      linkedAccountNo: application.withdrawType == 'fx'
          ? application.selectedFxAccount
          : application.selectedKrwAccount,
      withdrawPassword: application.withdrawPassword,
      depositPassword: application.depositPassword.isNotEmpty
          ? application.depositPassword
          : null,
      fxWithdrawCurrency:
          fxWithdrawCurrency != null && fxWithdrawCurrency.isNotEmpty
              ? fxWithdrawCurrency.toUpperCase()
              : null,
      amount: application.newAmount,
      autoRenewYn: application.autoRenew == 'apply',
      autoRenewTerm:
          application.autoRenew == 'apply' ? application.autoRenewCycle : null,
      autoTerminationYn: application.autoRenew == 'apply'
          ? application.autoTerminateAtMaturity
          : false,
      appliedRate: application.appliedRate,
      appliedFxRate: application.appliedFxRate,
      updatedAt: DateTime.now(),
      application: application,
    );

    _log('saveDraft: composed draft', data: _draftLog(draft));
    await _persistLocalDraft(draft);
    await _persistRemoteDraft(draft);

    return draft;
  }

  Future<void> clearDraft(String dpstId) async {
    // 전자서명까지 완료된 시점에서는 로컬/원격 모두 임시 저장을 지운다.
    // DB 연결이 끊겨도 가입 흐름을 막지 않도록, 서버 삭제는 best-effort 로 처리한다.
    await _storage.delete(key: _key(dpstId));

    final token = await _storage.read(key: _tokenKey);

    developer.log("==== DRAFT TOKEN ====", name: 'DepositDraftService');
    developer.log("TOKEN VALUE = $token", name: 'DepositDraftService');

    if (token == null) {
      developer.log("TOKEN IS NULL -> 서버 저장 안 보냄", name: 'DepositDraftService');
      return;
    }

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
    _log('loadLocalDraft: reading', data: {'dpstId': dpstId});
    final raw = await _storage.read(key: _key(dpstId));
    if (raw == null) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final draft = DepositDraft.fromJson(map);
      _log('loadLocalDraft: decoded', data: _draftLog(draft));
      return draft;
    } catch (error) {
      _log('loadLocalDraft: failed to decode local draft',
          data: {'dpstId': dpstId, 'error': error.toString()});
      return null;
    }
  }

  Future<void> _persistLocalDraft(DepositDraft draft) async {
    await _storage.write(
      key: _key(draft.dpstId),
      value: jsonEncode(draft.toJson()),
    );
    _log('persistLocalDraft: saved', data: _draftLog(draft));
  }

  Future<DepositDraft?> _loadRemoteDraft(String dpstId, String token) async {
    try {
      _log('loadRemoteDraft: requesting', data: {'dpstId': dpstId});
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
        _log('loadRemoteDraft: response parsed',
            data: _draftLog(draft)..addAll({'status': response.statusCode}));

        if (draft.application == null) {
          draft = draft.copyWith(application: _hydrateApplication(draft));
        }

        return draft;
      } else {
        _log(
          'loadRemoteDraft: non-200 response',
          data: {'dpstId': dpstId, 'status': response.statusCode},
        );
      }
    } catch (error) {
      _log(
        'loadRemoteDraft: request failed',
        data: {'dpstId': dpstId, 'error': error.toString()},
      );
      // DB 연결 또는 네트워크 오류는 이어가기 기능을 막지 않습니다.
    }

    return null;
  }

  Future<void> _persistRemoteDraft(DepositDraft draft) async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) return;

    try {
      final payload = {
        'customerCode': draft.customerCode,
        'currency': draft.currency,
        'month': draft.month,
        'step': draft.step,
        'linkedAccountNo': draft.linkedAccountNo,
        'amount': draft.amount,
        'autoRenewYn': draft.autoRenewYn,
        'autoRenewTerm': draft.autoRenewTerm,
        'autoTerminationYn': draft.autoTerminationYn,
        'fxWithdrawCurrency': draft.fxWithdrawCurrency,
        'appliedRate': draft.appliedRate,
        'appliedFxRate': draft.appliedFxRate,
      };

      _log('persistRemoteDraft: sending', data: {
        'url': '$_draftEndpoint/${draft.dpstId}',
        'method': 'PUT',
        'tokenExists': token != null,
        'payload': payload,
      });

      final response = await _client.put(
        Uri.parse('$_draftEndpoint/${draft.dpstId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      _log('persistRemoteDraft: response', data: {
        'status': response.statusCode,
        'body': response.body,
      });
    } catch (e) {
      _log(
        'persistRemoteDraft: failed',
        data: {'dpstId': draft.dpstId, 'error': e.toString()},
      );
      // 서버 저장 실패 시 로컬 저장된 초안만 유지합니다.
    }
  }




  DepositApplication _hydrateApplication(DepositDraft draft) {
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
      ..fxWithdrawCurrency = draft.fxWithdrawCurrency
      ..withdrawPassword = draft.withdrawPassword
      ..depositPassword = draft.depositPassword ?? ''
      ..newCurrency = draft.currency ?? ''
      ..newAmount = draft.amount
      ..newPeriodMonths = draft.month
      ..autoRenew = draft.autoRenewYn ? 'apply' : 'no'
      ..autoRenewCycle = draft.autoRenewTerm
      ..autoTerminateAtMaturity = draft.autoTerminationYn
      ..appliedRate = draft.appliedRate
      ..appliedFxRate = draft.appliedFxRate
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

  Map<String, dynamic> _draftLog(DepositDraft draft) {
    return {
      'dpstId': draft.dpstId,
      'draftNo': draft.draftNo,
      'customerCode': draft.customerCode,
      'step': draft.step,
      'currency': draft.currency,
      'linkedAccountNo': draft.linkedAccountNo,
      'amount': draft.amount,
      'autoRenewYn': draft.autoRenewYn,
      'autoRenewTerm': draft.autoRenewTerm,
      'autoTerminationYn': draft.autoTerminationYn,
      'fxWithdrawCurrency': draft.fxWithdrawCurrency,
      'appliedRate': draft.appliedRate,
      'appliedFxRate': draft.appliedFxRate,
      'updatedAt': draft.updatedAt?.toIso8601String(),
    };
  }

  void _log(String message, {Map<String, dynamic>? data}) {
    final serialized = data != null ? jsonEncode(data) : null;
    developer.log(
      serialized != null ? '$message | $serialized' : message,
      name: 'DepositDraftService',
    );
  }

  DepositDraft _mergeDrafts({
    required DepositDraft? primary,
    DepositDraft? secondary,
  }) {
    final effectivePrimary = primary ?? secondary;
    final effectiveSecondary =
        primary == null || identical(primary, secondary) ? null : secondary;

    if (effectivePrimary == null) {
      throw ArgumentError('At least one draft must be non-null');
    }

    final mergedApplication = _mergeApplications(
      effectivePrimary.application ?? _hydrateApplication(effectivePrimary),
      effectiveSecondary?.application,
    );

    final mergedDraft = effectivePrimary.copyWith(
      currency: effectivePrimary.currency ?? effectiveSecondary?.currency,
      month: effectivePrimary.month ?? effectiveSecondary?.month,
      linkedAccountNo:
          effectivePrimary.linkedAccountNo ?? effectiveSecondary?.linkedAccountNo,
      withdrawPassword: effectivePrimary.withdrawPassword ??
          effectiveSecondary?.withdrawPassword,
      depositPassword:
          effectivePrimary.depositPassword ?? effectiveSecondary?.depositPassword,
      fxWithdrawCurrency: effectivePrimary.fxWithdrawCurrency ??
          effectiveSecondary?.fxWithdrawCurrency,
      amount: effectivePrimary.amount ?? effectiveSecondary?.amount,
      autoRenewYn:
          effectivePrimary.autoRenewYn || (effectiveSecondary?.autoRenewYn ?? false),
      autoRenewTerm:
          effectivePrimary.autoRenewTerm ?? effectiveSecondary?.autoRenewTerm,
      autoTerminationYn: effectivePrimary.autoTerminationYn ||
          (effectiveSecondary?.autoTerminationYn ?? false),
      appliedRate: effectivePrimary.appliedRate ??
          effectiveSecondary?.appliedRate,
      appliedFxRate: effectivePrimary.appliedFxRate ??
          effectiveSecondary?.appliedFxRate,
      application: mergedApplication,
      updatedAt: effectivePrimary.updatedAt ?? effectiveSecondary?.updatedAt,
    );

    return mergedDraft;
  }

  DepositApplication _mergeApplications(
    DepositApplication primary,
    DepositApplication? secondary,
  ) {
    if (secondary == null) return primary;

    primary
      ..customerCode ??= secondary.customerCode
      ..customerName ??= secondary.customerName
      ..withdrawType =
          primary.withdrawType.isNotEmpty ? primary.withdrawType : secondary.withdrawType
      ..selectedKrwAccount ??= secondary.selectedKrwAccount
      ..selectedFxAccount ??= secondary.selectedFxAccount
      ..fxWithdrawCurrency ??= secondary.fxWithdrawCurrency
      ..withdrawPassword ??= secondary.withdrawPassword
      ..newCurrency =
          primary.newCurrency.isNotEmpty ? primary.newCurrency : secondary.newCurrency
      ..newAmount ??= secondary.newAmount
      ..newPeriodMonths ??= secondary.newPeriodMonths
      ..autoRenew = primary.autoRenew.isNotEmpty ? primary.autoRenew : secondary.autoRenew
      ..autoRenewCycle ??= secondary.autoRenewCycle
      ..autoRenewCount ??= secondary.autoRenewCount
      ..autoTerminateAtMaturity =
          primary.autoTerminateAtMaturity || secondary.autoTerminateAtMaturity
      ..appliedRate ??= secondary.appliedRate
      ..appliedFxRate ??= secondary.appliedFxRate
      ..addPaymentEnabled =
          primary.addPaymentEnabled || secondary.addPaymentEnabled
      ..addPaymentCount ??= secondary.addPaymentCount
      ..partialWithdrawEnabled =
          primary.partialWithdrawEnabled || secondary.partialWithdrawEnabled
      ..partialWithdrawCount ??= secondary.partialWithdrawCount
      ..depositPassword =
          primary.depositPassword.isNotEmpty ? primary.depositPassword : secondary.depositPassword
      ..dpstHdrStartDy ??= secondary.dpstHdrStartDy
      ..dpstHdrFinDy ??= secondary.dpstHdrFinDy
      ..dpstHdrCurrencyExp ??= secondary.dpstHdrCurrencyExp
      ..dpstHdrLinkedAcctNo ??= secondary.dpstHdrLinkedAcctNo
      ..dpstHdrLinkedAcctType ??= secondary.dpstHdrLinkedAcctType
      ..dpstHdrAutoRenewYn = primary.dpstHdrAutoRenewYn.isNotEmpty
          ? primary.dpstHdrAutoRenewYn
          : secondary.dpstHdrAutoRenewYn
      ..dpstHdrAutoRenewCnt =
          primary.dpstHdrAutoRenewCnt != 0 ? primary.dpstHdrAutoRenewCnt : secondary.dpstHdrAutoRenewCnt
      ..dpstHdrAutoRenewTerm ??= secondary.dpstHdrAutoRenewTerm
      ..dpstHdrInfoAgreeYn ??= secondary.dpstHdrInfoAgreeYn
      ..dpstHdrInfoAgreeDt ??= secondary.dpstHdrInfoAgreeDt
      ..dpstHdrContractDt ??= secondary.dpstHdrContractDt
      ..dpstHdrExpAcctNo ??= secondary.dpstHdrExpAcctNo
      ..dpstHdrAddPayCnt =
          primary.dpstHdrAddPayCnt != 0 ? primary.dpstHdrAddPayCnt : secondary.dpstHdrAddPayCnt
      ..dpstHdrPartWdrwCnt ??= secondary.dpstHdrPartWdrwCnt
      ..dpstHdrLinkedAcctBal ??= secondary.dpstHdrLinkedAcctBal
      ..dpstDtlType = primary.dpstDtlType != 0 ? primary.dpstDtlType : secondary.dpstDtlType
      ..dpstDtlEsignYn ??= secondary.dpstDtlEsignYn
      ..dpstDtlEsignDt ??= secondary.dpstDtlEsignDt
      ..product ??= secondary.product;

    return primary;
  }

  DepositDraft? _fresherOf(DepositDraft? a, DepositDraft? b) {
    if (a == null) return b;
    if (b == null) return a;

    if (a.updatedAt == null && b.updatedAt == null) return a;
    if (a.updatedAt == null) return b;
    if (b.updatedAt == null) return a;

    return a.updatedAt!.isAfter(b.updatedAt!) ? a : b;
  }
}
