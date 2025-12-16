import 'package:flutter/material.dart';
import 'package:test_main/screens/app_colors.dart';
import 'step_3.dart';
import 'package:test_main/models/deposit/application.dart';
import 'package:intl/intl.dart';
import 'package:test_main/models/deposit/view.dart';
import 'package:test_main/services/deposit_service.dart';


class DepositStep2Screen extends StatefulWidget {
  static const routeName = "/deposit-step2";

  final DepositApplication application;

  const DepositStep2Screen({
    super.key,
    required this.application,
  });


  @override
  State<DepositStep2Screen> createState() => _DepositStep2ScreenState();
}

class _DepositStep2ScreenState extends State<DepositStep2Screen> {

  final DepositService _service = DepositService();
  late Future<DepositProduct> _productFuture;
  final NumberFormat _amountFormat = NumberFormat.decimalPattern();

  String withdrawType = "krw";
  String autoRenew = "no";
  String receiveMethod = "email";

  int? autoRenewCycle;       // 선택된 연장주기 (1,2,3,6)


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

  List<String> _currencyOptions = [];
  List<int> _periodOptions = [];


  String depositPw = "";
  String depositPwCheck = "";

  bool _periodExpanded = false;


  @override
  void initState() {
    super.initState();
    _productFuture = _loadProductDetail();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DepositProduct>(
      future: _productFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.backgroundOffWhite,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            backgroundColor: AppColors.backgroundOffWhite,
            appBar: AppBar(
              title: const Text("정보입력", style: TextStyle(color: Colors.white)),
              backgroundColor: AppColors.pointDustyNavy,
            ),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('상품 정보를 불러오지 못했습니다.'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('다시 시도'),
                    onPressed: () {
                      setState(() {
                        _productFuture = _loadProductDetail();
                      });
                    },
                  )
                ],
              ),
            ),
          );
        }

        return _buildScaffold(snapshot.data!);
      },
    );
  }

  Widget _buildScaffold(DepositProduct product) {


    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        title: Text(product.name, style: const TextStyle(color: Colors.white)),        backgroundColor: AppColors.pointDustyNavy,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildSteps(),
            const SizedBox(height: 25),

            _productSummary(product),
            const SizedBox(height: 20),

            _blockTitle("출금계좌정보입력"),
            _withdrawAccount(product),
            const SizedBox(height: 25),

            _blockTitle("신규상품가입정보입력"),
            _newDepositInfo(product),
            const SizedBox(height: 25),

            _blockTitle("만기자동연장신청"),
            _autoRenewSection(),
            const SizedBox(height: 40),

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
  // 상품 요약
  // -------------------------------
  Widget _productSummary(DepositProduct product) {
    final limit = _findLimitFor(newCurrency.isNotEmpty ? newCurrency : null, product);
    final periodLabel = _periodLabel(product, newPeriod);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mainPaleBlue.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.pointDustyNavy,
            ),
          ),
          const SizedBox(height: 10),
          _summaryRow("가입 가능 통화", _currencyOptions.join(', ')),
          _summaryRow(
            "가입 금액",
            limit != null
                ? "${limit.currency} ${_amountFormat.format(limit.min)} 이상"
                : "상품 한도 확인 필요",
          ),
          _summaryRow("가입 기간", periodLabel),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.pointDustyNavy.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.pointDustyNavy,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }


  // -------------------------------
  // ① 출금계좌 입력
  // -------------------------------
  Widget _withdrawAccount(DepositProduct product) {
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
        if (withdrawType == "fx") _fxAccountFields(product),
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
        const SizedBox(height: 16),

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
  Widget _fxAccountFields(DepositProduct product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
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
          items: _currencyOptions
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),

          onChanged: (v) => setState(() => fxWithdrawCurrency = v),
        ),
      ],
    );
  }

  // -------------------------------
  // ② 신규 예금 정보 입력
  // -------------------------------
  Widget _newDepositInfo(DepositProduct product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        const Text("신규 통화 종류",
            style: TextStyle(color: AppColors.pointDustyNavy)),
        DropdownButton(
          dropdownColor: Colors.white,
          hint: const Text("통화 선택"),
          value: newCurrency.isEmpty ? null : newCurrency,
          items: _currencyOptions
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) {
            setState(() {
              newCurrency = v!;
              final limit = _findLimitFor(newCurrency, product);
              if (limit != null && (newAmount.isEmpty || int.tryParse(newAmount) == null)) {
                newAmount = limit.min.toString();
              }
              if (withdrawType == 'krw' && newCurrency != 'KRW') {
                withdrawType = 'fx';
              }
            });
          },

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
        if (_findLimitFor(newCurrency, product) != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _limitText(_findLimitFor(newCurrency, product)!),
              style: TextStyle(
                color: AppColors.pointDustyNavy.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ),

        const SizedBox(height: 20),

        const Text(
          "가입 월수",
          style: TextStyle(
            color: AppColors.pointDustyNavy,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 10),

// =======================
// 선택 박스 (항상 보임)
// =======================
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              _periodExpanded = !_periodExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.mainPaleBlue),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  newPeriod != null ? "$newPeriod개월" : "가입 기간 선택",
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: newPeriod != null
                        ? AppColors.pointDustyNavy
                        : AppColors.pointDustyNavy.withOpacity(0.6),
                  ),
                ),
                Icon(
                  _periodExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.pointDustyNavy,
                ),
              ],
            ),
          ),
        ),

// =======================
// 펼쳐지는 리스트
// =======================
        if (_periodExpanded)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.mainPaleBlue),
            ),
            child: Column(
              children: _periodOptions.map((m) {
                final bool selected = newPeriod == m.toString();

                return InkWell(
                  onTap: () {
                    setState(() {
                      newPeriod = m.toString();
                      _periodExpanded = false; // 선택 후 닫힘
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.pointDustyNavy.withOpacity(0.05)
                          : Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: m == _periodOptions.last
                              ? Colors.transparent
                              : AppColors.mainPaleBlue,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$m개월",
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? AppColors.pointDustyNavy
                                : Colors.black87,
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons.check,
                            color: AppColors.pointDustyNavy,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),



      ],
    );
  }


  // ----------------------------------------
  // ③ 자동 연장 선택
  // ----------------------------------------

  Widget _autoRenewSection() {
    final List<int> cycleOptions = [1, 2, 3, 6];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [


        // --------------------- 라디오 ---------------------
        Row(
          children: [
            Radio(
              value: "apply",
              groupValue: autoRenew,
              activeColor: AppColors.pointDustyNavy,
              onChanged: (value) => setState(() => autoRenew = value!),
            ),
            const Text("신청 (월 단위)"),
            const SizedBox(width: 16),
            Radio(
              value: "no",
              groupValue: autoRenew,
              activeColor: AppColors.pointDustyNavy,
              onChanged: (value) => setState(() => autoRenew = value!),
            ),
            const Text("미신청"),
          ],
        ),

        const SizedBox(height: 16),

        // --------------------- 연장 주기 ---------------------
        if (autoRenew == "apply") ...[
          const Text(
            "연장 주기",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.pointDustyNavy,
            ),
          ),
          const SizedBox(height: 12),

          // ============= 전체를 감싸는 하나의 네모 =============
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.pointDustyNavy,
                width: 1,
              ),
            ),
            child: Row(
              children: cycleOptions.map((month) {
                bool isSelected = (autoRenewCycle == month);
                int index = cycleOptions.indexOf(month);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => autoRenewCycle = month),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.pointDustyNavy
                            : Colors.white,
                        borderRadius: BorderRadius.horizontal(
                          left: index == 0 ? const Radius.circular(8) : Radius.zero,
                          right: index == cycleOptions.length - 1
                              ? const Radius.circular(8)
                              : Radius.zero,
                        ),
                        border: Border(
                          right: index != cycleOptions.length - 1
                              ? BorderSide(color: AppColors.pointDustyNavy, width: 1)
                              : BorderSide.none,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "$month개월",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.pointDustyNavy,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
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
        const SizedBox(height: 16),

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

        const SizedBox(height: 20),
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

        const SizedBox(height: 30),

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

    final selectedProduct = widget.application.product;
    final limit = selectedProduct != null
        ? _findLimitFor(newCurrency, selectedProduct)
        : null;

    final parsedAmount = int.tryParse(newAmount) ?? 0;
    if (limit != null) {
      if (parsedAmount < limit.min) {
        return _err('최소 가입 금액은 ${_amountFormat.format(limit.min)} 입니다.');
      }
      if (limit.max > 0 && parsedAmount > limit.max) {
        return _err('최대 가입 금액은 ${_amountFormat.format(limit.max)} 입니다.');
      }
    }

    if (parsedAmount <= 0) return _err('유효한 금액을 입력해주세요.');



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
          onPressed: () => Navigator.pop(context),

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
              _saveToApplication();
              Navigator.pushNamed(
                context,
                DepositStep3Screen.routeName,
                arguments: widget.application,              );
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

  Future<DepositProduct> _loadProductDetail() async {
    final product = await _service.fetchProductDetail(widget.application.dpstId);
    widget.application.product = product;

    _currencyOptions = _parseCurrencies(product);
    _periodOptions = _buildPeriodOptions(product);

    _loadFromApplication(product);

    if (newCurrency.isEmpty && _currencyOptions.isNotEmpty) {
      newCurrency = _currencyOptions.first;
    }

    if (withdrawType == 'krw' && newCurrency != 'KRW') {
      withdrawType = 'fx';
    }

    if (newPeriod == null && _periodOptions.isNotEmpty) {
      newPeriod = _periodOptions.first.toString();
    }

    if (fxWithdrawCurrency == null && withdrawType == 'fx' && _currencyOptions.isNotEmpty) {
      fxWithdrawCurrency = _currencyOptions.first;
    }

    if (newAmount.isEmpty) {
      final limit = _findLimitFor(newCurrency, product);
      if (limit != null) newAmount = limit.min.toString();
    }

    return product;
  }

  void _loadFromApplication(DepositProduct product) {
    withdrawType = widget.application.withdrawType;
    autoRenew = widget.application.autoRenew;
    autoRenewCycle = widget.application.autoRenewCycle;
    receiveMethod = widget.application.receiveMethod;

    selectedKrwAccount = widget.application.selectedKrwAccount;
    selectedFxAccount = widget.application.selectedFxAccount;
    fxWithdrawCurrency = widget.application.fxWithdrawCurrency;

    krwPassword = widget.application.withdrawType == 'krw'
        ? (widget.application.withdrawPassword ?? '')
        : '';
    fxPassword = widget.application.withdrawType == 'fx'
        ? (widget.application.withdrawPassword ?? '')
        : '';

    newCurrency = widget.application.newCurrency;
    newAmount = widget.application.newAmount?.toString() ?? '';
    newPeriod = widget.application.newPeriodMonths?.toString();
    depositPw = widget.application.depositPassword;
    depositPwCheck = widget.application.depositPassword;

    if (newPeriod == null && product.fixedPeriodMonth != null) {
      newPeriod = product.fixedPeriodMonth.toString();
    }
  }

  List<String> _parseCurrencies(DepositProduct product) {
    return product.dpstCurrency
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  List<int> _buildPeriodOptions(DepositProduct product) {
    if (product.fixedPeriodMonth != null) {
      return [product.fixedPeriodMonth!];
    }

    if (product.minPeriodMonth != null && product.maxPeriodMonth != null) {
      final List<int> options = [];
      for (int m = product.minPeriodMonth!; m <= product.maxPeriodMonth!; m++) {
        options.add(m);
      }
      return options;
    }

    return [1, 3, 6, 12];
  }

  DepositLimit? _findLimitFor(String? currency, DepositProduct product) {
    if (currency == null || currency.isEmpty) return null;
    try {
      return product.limits.firstWhere(
            (l) => l.currency.toUpperCase() == currency.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  String _limitText(DepositLimit limit) {
    final buffer = StringBuffer('${limit.currency} ${_amountFormat.format(limit.min)} 이상');
    if (limit.max > 0) {
      buffer.write(' ~ ${_amountFormat.format(limit.max)} 이하');
    }
    return buffer.toString();
  }

  String _periodLabel(DepositProduct product, String? selected) {
    if (selected != null) {
      return '$selected개월';
    }
    if (product.fixedPeriodMonth != null) return '${product.fixedPeriodMonth}개월';
    if (product.minPeriodMonth != null && product.maxPeriodMonth != null) {
      return '${product.minPeriodMonth}-${product.maxPeriodMonth}개월';
    }
    return '기간 정보 없음';


  }

  void _saveToApplication() {
    widget.application
      ..product = widget.application.product
      ..withdrawType = withdrawType
      ..selectedKrwAccount = selectedKrwAccount
      ..selectedFxAccount = selectedFxAccount
      ..fxWithdrawCurrency = fxWithdrawCurrency
      ..withdrawPassword =
      withdrawType == 'krw' ? krwPassword : fxPassword
      ..newCurrency = newCurrency
      ..newAmount = int.tryParse(newAmount)
      ..newPeriodMonths = int.tryParse(newPeriod ?? '')
      ..autoRenew = autoRenew
      ..autoRenewCycle = autoRenew == 'apply' ? autoRenewCycle : null
      ..depositPassword = depositPw
      ..receiveMethod = receiveMethod;
  }

}

