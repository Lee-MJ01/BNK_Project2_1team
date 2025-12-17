class CustInfo {
  String name;
  String? rrn;
  String? id;
  String? pw;
  String? phone;
  String? email;
  String? zip;
  String? addr1;
  String? addr2;
  String? jobType;
  bool isForeignTax;
  String? deviceId;

  String? mailAgree;
  String? phoneAgree;
  String? emailAgree;
  String? smsAgree;

  CustInfo({
    required this.name,
    this.rrn,
    this.id,
    this.pw,
    this.phone,
    this.email,
    this.zip,
    this.addr1,
    this.addr2,
    this.jobType,
    this.isForeignTax = false,
    this.deviceId,
    this.mailAgree,
    this.phoneAgree,
    this.emailAgree,
    this.smsAgree
  });
}
