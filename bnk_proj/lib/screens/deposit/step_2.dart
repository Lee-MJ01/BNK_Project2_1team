import 'package:flutter/material.dart';
import 'package:test_main/screens/app_colors.dart';
import 'step_1.dart';
import 'step_3.dart';

class DepositStep2Screen extends StatefulWidget {
  static const routeName = "/deposit-step2";

  const DepositStep2Screen({super.key});

  @override
  State<DepositStep2Screen> createState() => _DepositStep2ScreenState();
}

class _DepositStep2ScreenState extends State<DepositStep2Screen> {
  String withdrawType = "krw";
  String autoRenew = "no";
  String receiveMethod = "email";

  bool isPwMatched = true;
  bool isKrwPwValid = true;
  bool isFxPwValid = true;

  String? selectedKrwAccount;
  String? selectedFxAccount;
  String? fxWithdrawCurrency;

  String krwPassword = "";
  String fxPassword = "";

  String newCurrency = "";
  String newAmount = "";
  String? newPeriod;

  String depositPw = "";
  String depositPwCheck = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        title: const Text("정보입력", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.pointDustyNavy,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildSteps(),
            const SizedBox(height: 25),

            _blockTitle("출금계좌정보입력"),
            _withdrawAccount(),
            const SizedBox(height: 25),

            _blockTitle("신규상품가입정보입력"),
            _newDepositInfo(),
            const SizedBox(height: 25),

            _blockTitle("만기자동연장신청"),
            _autoRenewSection(),
            const SizedBox(height: 25),

            _blockTitle("정기예금 비밀번호 및 상품서류 수령방법"),
            _passwordAndReceiveMethod(),
            const SizedBox(height: 40),

            _buttons(context),
          ],
        ),
      ),
    );
  }

  // -------------------------------
  // STEP Indicator UI
  // -------------------------------
  Widget _buildSteps() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepCircle("1", false),
        _divider(),
        _stepCircle("2", true),
        _divider(),
        _stepCircle("3", false),
      ],
    );
  }

  Widget _stepCircle(String num, bool active) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor:
          active ? AppColors.pointDustyNavy : AppColors.mainPaleBlue,
          child: Text(
            num,
            style: TextStyle(
              color: active ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          num == "1"
              ? "약관동의"
              : num == "2"
              ? "정보입력"
              : "입력확인",
          style: TextStyle(
            fontSize: 12,
            color: active
                ? AppColors.pointDustyNavy
                : AppColors.pointDustyNavy.withOpacity(0.6),
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        )
      ],
    );
  }

  Widget _divider() => Container(
    width: 40,
    height: 2,
    margin: const EdgeInsets.symmetric(horizontal: 10),
    color: AppColors.mainPaleBlue,
  );

  // -------------------------------
  // Section Title
  // -------------------------------
  Widget _blockTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.pointDustyNavy,
        ),
      ),
    );
  }

  // -------------------------------
  // ① 출금계좌 입력
  // -------------------------------
  Widget _withdrawAccount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Radio(
              activeColor: AppColors.pointDustyNavy,
              value: "krw",
              groupValue: withdrawType,
              onChanged: (value) => setState(() => withdrawType = value!),
            ),
            const Text("원화출금계좌",
                style: TextStyle(color: AppColors.pointDustyNavy)),

            Radio(
              activeColor: AppColors.pointDustyNavy,
              value: "fx",
              groupValue: withdrawType,
              onChanged: (value) => setState(() => withdrawType = value!),
            ),
            const Text("외화출금계좌",
                style: TextStyle(color: AppColors.pointDustyNavy)),
          ],
        ),

        if (withdrawType == "krw") _krwAccountFields(),
        if (withdrawType == "fx") _fxAccountFields(),
      ],
    );
  }

  // -------------------------------
  // 원화 계좌 입력
  // -------------------------------
  Widget _krwAccountFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("원화출금계좌번호",
            style: TextStyle(color: AppColors.pointDustyNavy)),
        DropdownButton(
          dropdownColor: Colors.white,
          hint: const Text("계좌 선택"),
          value: selectedKrwAccount,
          items: const [
            DropdownMenuItem(value: "1", child: Text("104302-04-412952")),
            DropdownMenuItem(value: "2", child: Text("104302-02-513489")),
          ],
          onChanged: (v) => setState(() => selectedKrwAccount = v),
        ),
        const SizedBox(height: 5),

        Text("출금가능금액 0원",
            style: TextStyle(
                color: AppColors.pointDustyNavy.withOpacity(0.6), fontSize: 12)),
        const SizedBox(height: 20),

        const Text("계좌 비밀번호",
            style: TextStyle(color: AppColors.pointDustyNavy)),
        SizedBox(
          width: 140,
          child: TextField(
            obscureText: true,
            maxLength: 4,
            keyboardType: TextInputType.number,
            onChanged: (v) {
              setState(() {
                krwPassword = v;
                isKrwPwValid = (v.length == 4);
              });
            },
            decoration: const InputDecoration(counterText: ""),
          ),
        ),

        if (!isKrwPwValid)
          const Text(
            "4자리 비밀번호를 입력해주세요.",
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
      ],
    );
  }

  // -------------------------------
  // 외화 계좌 입력
  // -------------------------------
  Widget _fxAccountFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("외화출금계좌번호",
            style: TextStyle(color: AppColors.pointDustyNavy)),
        DropdownButton(
          dropdownColor: Colors.white,
          hint: const Text("계좌 선택"),
          value: selectedFxAccount,
          items: const [
            DropdownMenuItem(value: "1", child: Text("202040-11-300912 (USD)")),
            DropdownMenuItem(value: "2", child: Text("202040-12-102300 (JPY)")),
            DropdownMenuItem(value: "3", child: Text("202040-12-201520 (EUR)")),
          ],
          onChanged: (v) => setState(() => selectedFxAccount = v),
        ),
        const SizedBox(height: 5),

        Text("출금가능금액 2,000 USD",
            style: TextStyle(
                color: AppColors.pointDustyNavy.withOpacity(0.6), fontSize: 12)),
        const SizedBox(height: 20),

        const Text("비밀번호",
            style: TextStyle(color: AppColors.pointDustyNavy)),
        SizedBox(
          width: 140,
          child: TextField(
            obscureText: true,
            maxLength: 4,
            keyboardType: TextInputType.number,
            onChanged: (v) {
              setState(() {
                fxPassword = v;
                isFxPwValid = (v.length == 4);
              });
            },
            decoration: const InputDecoration(counterText: ""),
          ),
        ),

        if (!isFxPwValid)
          const Text(
            "4자리 비밀번호를 입력해주세요.",
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),

        const SizedBox(height: 20),

        const Text("출금 통화 선택",
            style: TextStyle(color: AppColors.pointDustyNavy)),
        DropdownButton(
          dropdownColor: Colors.white,
          hint: const Text("통화 선택"),
          value: fxWithdrawCurrency,
          items: const [
            DropdownMenuItem(value: "USD", child: Text("USD")),
            DropdownMenuItem(value: "JPY", child: Text("JPY")),
            DropdownMenuItem(value: "EUR", child: Text("EUR")),
          ],
          onChanged: (v) => setState(() => fxWithdrawCurrency = v),
        ),
      ],
    );
  }

  // -------------------------------
  // ② 신규 예금 정보 입력
  // -------------------------------
  Widget _newDepositInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("신규 통화 종류",
            style: TextStyle(color: AppColors.pointDustyNavy)),
        DropdownButton(
          dropdownColor: Colors.white,
          hint: const Text("통화 선택"),
          value: newCurrency.isEmpty ? null : newCurrency,
          items: const [
            DropdownMenuItem(value: "USD", child: Text("USD")),
            DropdownMenuItem(value: "JPY", child: Text("JPY")),
            DropdownMenuItem(value: "EUR", child: Text("EUR")),
            DropdownMenuItem(value: "GBP", child: Text("GBP")),
            DropdownMenuItem(value: "AUD", child: Text("AUD")),
            DropdownMenuItem(value: "CNH", child: Text("CNH")),
          ],
          onChanged: (v) => setState(() => newCurrency = v!),
        ),
        const SizedBox(height: 20),

        const Text("신규 금액",
            style: TextStyle(color: AppColors.pointDustyNavy)),
        SizedBox(
          width: 200,
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "금액 입력 (예: 1000)",
            ),
            onChanged: (v) {
              String numeric = v.replaceAll(RegExp(r'[^0-9]'), '');
              setState(() => newAmount = numeric);
            },
          ),
        ),
        const SizedBox(height: 20),

        const Text("가입 월수",
            style: TextStyle(color: AppColors.pointDustyNavy)),
        Row(
          children: [
            DropdownButton(
              dropdownColor: Colors.white,
              hint: const Text("선택"),
              value: newPeriod,
              items: const [
                DropdownMenuItem(value: "1", child: Text("1")),
                DropdownMenuItem(value: "3", child: Text("3")),
                DropdownMenuItem(value: "6", child: Text("6")),
                DropdownMenuItem(value: "12", child: Text("12")),
              ],
              onChanged: (v) => setState(() => newPeriod = v),
            ),
            const Text("개월",
                style: TextStyle(color: AppColors.pointDustyNavy)),
          ],
        ),
      ],
    );
  }
  // ----------------------------------------
  // ③ 자동 연장 선택
  // ----------------------------------------
  Widget _autoRenewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Radio(
              value: "apply",
              groupValue: autoRenew,
              activeColor: AppColors.pointDustyNavy,
              onChanged: (value) => setState(() => autoRenew = value!),
            ),
            const Text("신청 (월 단위)",
                style: TextStyle(color: AppColors.pointDustyNavy)),

            Radio(
              value: "no",
              groupValue: autoRenew,
              activeColor: AppColors.pointDustyNavy,
              onChanged: (value) => setState(() => autoRenew = value!),
            ),
            const Text("미신청",
                style: TextStyle(color: AppColors.pointDustyNavy)),
          ],
        ),

        if (autoRenew == "apply")
          Row(
            children: [
              const Text("연장 주기",
                  style: TextStyle(color: AppColors.pointDustyNavy)),
              DropdownButton(
                dropdownColor: Colors.white,
                items: const [
                  DropdownMenuItem(value: "1", child: Text("1")),
                  DropdownMenuItem(value: "3", child: Text("3")),
                  DropdownMenuItem(value: "6", child: Text("6")),
                  DropdownMenuItem(value: "12", child: Text("12")),
                ],
                onChanged: (_) {},
              ),
              const Text("개월",
                  style: TextStyle(color: AppColors.pointDustyNavy)),
            ],
          ),
      ],
    );
  }

  // ----------------------------------------
  // ④ 비밀번호 및 서류 수령방법
  // ----------------------------------------
  Widget _passwordAndReceiveMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("정기예금 비밀번호",
            style: TextStyle(color: AppColors.pointDustyNavy)),
        SizedBox(
          width: 140,
          child: TextField(
            obscureText: true,
            maxLength: 4,
            keyboardType: TextInputType.number,
            onChanged: (v) {
              setState(() {
                depositPw = v;
                isPwMatched = (depositPw == depositPwCheck);
              });
            },
            decoration: const InputDecoration(counterText: ""),
          ),
        ),

        const SizedBox(height: 12),
        const Text("비밀번호 확인",
            style: TextStyle(color: AppColors.pointDustyNavy)),
        SizedBox(
          width: 140,
          child: TextField(
            obscureText: true,
            maxLength: 4,
            keyboardType: TextInputType.number,
            onChanged: (v) {
              setState(() {
                depositPwCheck = v;
                isPwMatched = (depositPw == depositPwCheck);
              });
            },
            decoration: const InputDecoration(counterText: ""),
          ),
        ),

        if (!isPwMatched)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              "비밀번호가 일치하지 않습니다.",
              style:
              TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),

        const SizedBox(height: 20),

        const Text("상품서류 수령방법",
            style: TextStyle(color: AppColors.pointDustyNavy)),
        Row(
          children: [
            Radio(
              value: "email",
              groupValue: receiveMethod,
              activeColor: AppColors.pointDustyNavy,
              onChanged: (value) => setState(() => receiveMethod = value!),
            ),
            const Text("이메일", style: TextStyle(color: AppColors.pointDustyNavy)),

            Radio(
              value: "sms",
              groupValue: receiveMethod,
              activeColor: AppColors.pointDustyNavy,
              onChanged: (value) => setState(() => receiveMethod = value!),
            ),
            const Text("문자", style: TextStyle(color: AppColors.pointDustyNavy)),
          ],
        ),

        if (receiveMethod == "email")
          Text(
            "이메일로 상품설명서가 전송됩니다.",
            style: TextStyle(
                color: AppColors.pointDustyNavy.withOpacity(0.7), fontSize: 12),
          ),

        if (receiveMethod == "sms")
          Text(
            "휴대폰 번호로 알림톡이 발송됩니다.",
            style: TextStyle(
                color: AppColors.pointDustyNavy.withOpacity(0.7), fontSize: 12),
          ),
      ],
    );
  }

  // ----------------------------------------
  // 다음 버튼 활성 조건
  // ----------------------------------------
  bool _isAllFieldsFilled() {
    if (withdrawType == "krw") {
      if (selectedKrwAccount == null) return false;
      if (krwPassword.length != 4) return false;
    } else {
      if (selectedFxAccount == null) return false;
      if (fxPassword.length != 4) return false;
      if (fxWithdrawCurrency == null) return false;
    }

    if (newCurrency.isEmpty) return false;
    if (newAmount.isEmpty) return false;
    if (newPeriod == null) return false;

    if (depositPw.length != 4) return false;
    if (depositPwCheck.length != 4) return false;

    return true;
  }

  // ----------------------------------------
  // SnackBar 포함 유효성 검사
  // ----------------------------------------
  bool _validateInputs() {
    if (withdrawType == "krw") {
      if (selectedKrwAccount == null) return _err("원화 출금계좌를 선택해주세요.");
      if (krwPassword.length != 4) return _err("원화 계좌 비밀번호 4자리를 입력해주세요.");
    }

    if (withdrawType == "fx") {
      if (selectedFxAccount == null) return _err("외화 출금계좌를 선택해주세요.");
      if (fxPassword.length != 4) return _err("외화 계좌 비밀번호 4자리를 입력해주세요.");
      if (fxWithdrawCurrency == null) return _err("출금 통화를 선택해주세요.");
    }

    if (newCurrency.isEmpty) return _err("신규 통화를 선택해주세요.");
    if (newAmount.isEmpty) return _err("신규 금액을 입력해주세요.");
    if (newPeriod == null) return _err("가입 기간을 선택해주세요.");

    if (depositPw.length != 4) return _err("정기예금 비밀번호 4자리를 입력해주세요.");
    if (depositPw != depositPwCheck) return _err("비밀번호가 일치하지 않습니다.");

    return true;
  }

  bool _err(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
      ),
    );
    return false;
  }

  // ----------------------------------------
  // 이전 / 다음 버튼
  // ----------------------------------------
  Widget _buttons(BuildContext context) {
    bool canNext = _isAllFieldsFilled();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mainPaleBlue,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          ),
          onPressed: () {
            Navigator.pushNamed(context, DepositStep1Screen.routeName);
          },
          child: const Text(
            "이전",
            style: TextStyle(color: Colors.white),
          ),
        ),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
            canNext ? AppColors.pointDustyNavy : AppColors.mainPaleBlue,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            elevation: 0,
          ),
          onPressed: canNext
              ? () {
            if (_validateInputs()) {
              Navigator.pushNamed(context, DepositStep3Screen.routeName);
            }
          }
              : null,
          child: const Text(
            "다음",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

