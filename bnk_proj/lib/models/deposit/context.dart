class KrwAccount {
  final String accountNo;
  final int balance;

  const KrwAccount({
    required this.accountNo,
    required this.balance,
  });

  factory KrwAccount.fromJson(Map<String, dynamic> json) {
    return KrwAccount(
      accountNo: json['acctNo']?.toString() ?? '',
      balance: int.tryParse(json['balance']?.toString() ?? '') ?? 0,
    );
  }
}

class FxBalance {
  final String balanceNo;
  final String currency;
  final double balance;

  const FxBalance({
    required this.balanceNo,
    required this.currency,
    required this.balance,
  });

  factory FxBalance.fromJson(Map<String, dynamic> json) {
    return FxBalance(
      balanceNo: json['balNo']?.toString() ?? '',
      currency: json['currency']?.toString() ?? '',
      balance: double.tryParse(json['balance']?.toString() ?? '') ?? 0,
    );
  }
}

class FxAccount {
  final String accountNo;
  final List<FxBalance> balances;

  const FxAccount({
    required this.accountNo,
    required this.balances,
  });

  factory FxAccount.fromJson(Map<String, dynamic> json) {
    final rawBalances = (json['balances'] as List<dynamic>? ?? []);
    return FxAccount(
      accountNo: json['acctNo']?.toString() ?? '',
      balances: rawBalances
          .map((e) => FxBalance.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DepositContext {
  final String customerName;
  final String? customerCode;
  final List<KrwAccount> krwAccounts;
  final List<FxAccount> fxAccounts;

  const DepositContext({
    required this.customerName,
    this.customerCode,
    required this.krwAccounts,
    required this.fxAccounts,
  });

  factory DepositContext.fromJson(Map<String, dynamic> json) {
    final krw = (json['krwAccounts'] as List<dynamic>? ?? [])
        .map((e) => KrwAccount.fromJson(e as Map<String, dynamic>))
        .toList();

    final fx = (json['fxAccounts'] as List<dynamic>? ?? [])
        .map((e) => FxAccount.fromJson(e as Map<String, dynamic>))
        .toList();

    return DepositContext(
      customerName: json['customerName']?.toString() ?? '고객',
      customerCode: json['custCode']?.toString(),
      krwAccounts: krw,
      fxAccounts: fx,
    );
  }
}
