class CustAcct {
  String? purpose;        // ACCT_PURPOSE
  String? source;         // ACCT_FUND_SOURCE
  bool isOwner;          // 거래자금 본인 여부
  bool salaryExist;      // 급여계좌 여부
  bool manageBranch;     // 관리희망점
  String? contractMethod; // 계약서 수신방법
  String? acctName;       // ACCT_NAME


  CustAcct({
    this.purpose,
    this.source,
    required this.isOwner,
    required this.salaryExist,
    required this.manageBranch,
    this.contractMethod,
    this.acctName,
  });
}
