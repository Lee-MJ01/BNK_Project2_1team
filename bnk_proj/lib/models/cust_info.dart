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
  String? engName;

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
    this.smsAgree,
    this.engName
  });

  Map<String, dynamic> toJson() => {
    "custName": name,
    "custJumin": rrn,
    "custHp": phone,
    "custEmail": email,
    "custZip": zip,
    "custAddr1": addr1,
    "custAddr2": addr2,
    // "jobType": jobType,
    // "isForeignTax": isForeignTax,
    "custDeviceId": deviceId,
    "custId": id,
    "custPw": pw,
    "custMailAgree" : mailAgree,
    "custPhoneAgree" : phoneAgree,
    "custEmailAgree" : emailAgree,
    "custSmsAgree" : smsAgree,
    "custEngName" : engName
  };
}
