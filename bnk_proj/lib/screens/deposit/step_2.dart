import 'package:flutter/material.dart';
import 'package:test_main/screens/app_colors.dart';
import 'step_3.dart';
import 'package:test_main/models/deposit/application.dart';
import 'package:intl/intl.dart';
import 'package:test_main/models/deposit/context.dart';
import 'package:test_main/models/deposit/view.dart';
import 'package:test_main/services/deposit_service.dart';
import 'package:test_main/services/deposit_draft_service.dart';
import 'package:test_main/services/exchange_api.dart';


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
  final DepositDraftService _draftService = const DepositDraftService();
  late Future<_Step2Data> _initFuture;
  final NumberFormat _amountFormat = NumberFormat.decimalPattern();
  final DateFormat _ymd = DateFormat('yyyyMMdd');
  _Step2Data? _cachedData;

  DepositContext? _context;

  String withdrawType = "krw";
  String autoRenew = "no";
  int? autoRenewCycle;       // 선택된 연장주기 (1,2,3,6)
  int? autoRenewCount;       // 선택된 자동연장 횟수
  bool autoTerminateAtMaturity = false;

  double? appliedRate;
  double? appliedFxRate;

  bool addPaymentEnabled = false;
  int? addPaymentCount;

  bool partialWithdrawEnabled = false;
  int? partialWithdrawCount;

  Map<String, double> _latestFxRates = {};

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

  final TextEditingController _appliedRateController = TextEditingController();
  final TextEditingController _appliedFxRateController = TextEditingController();
  final TextEditingController _autoRenewCountController = TextEditingController();
  final TextEditingController _addPayCountController = TextEditingController();
  final TextEditingController _partialWithdrawCountController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _initFuture = _loadData();
  }

  @override
  void dispose() {
    _appliedRateController.dispose();
    _appliedFxRateController.dispose();
    _autoRenewCountController.dispose();
    _addPayCountController.dispose();
    _partialWithdrawCountController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Step2Data>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            _cachedData != null) {
          return _buildScaffold(_cachedData!.product);
        }
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
                          _initFuture = _loadData();
                        });
                      },
                    )
                  ],
              ),
            ),
          );
        }

        _cachedData = snapshot.data!;
        _context ??= _cachedData!.context;

        return _buildScaffold(_cachedData!.product);
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSteps(),
            const SizedBox(height: 25),

            //최상단의 요약 카드
            //_productSummary(product),
            //const SizedBox(height: 20),

            _blockTitle("출금계좌정보입력"),
            _withdrawAccount(product),
            const SizedBox(height: 25),

            _blockTitle("신규상품가입정보입력"),
            _newDepositInfo(product),
            const SizedBox(height: 25),

            _blockTitle("만기자동연장신청"),
            _autoRenewSection(product),
            const SizedBox(height: 25),

            const SizedBox(height: 15),

            _blockTitle("정기예금 비밀번호"),
            _passwordSection(),
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
    final accounts = _context?.krwAccounts ?? [];
    final balance = _selectedKrwBalance();

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
          items: accounts
              .map(
                (acct) => DropdownMenuItem(
                  value: acct.accountNo,
                  child: Text(acct.accountNo),
                ),
              )
              .toList(),
          onChanged: accounts.isEmpty
              ? null
              : (v) => setState(() => selectedKrwAccount = v as String?),
        ),
        const SizedBox(height: 5),

        if (accounts.isEmpty)
          const Text(
            '등록된 원화출금계좌가 없습니다.',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),

        if (balance != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              "출금가능금액 ${_amountFormat.format(balance)} KRW",
              style: TextStyle(
                  color: AppColors.pointDustyNavy.withOpacity(0.6), fontSize: 12),
            ),
          ),

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
    final accounts = _context?.fxAccounts ?? [];
    final availableCurrencies = _availableFxCurrencies(product);
    final fxBalance = _selectedFxBalance();

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
          items: accounts
              .map(
                (acct) => DropdownMenuItem(
                  value: acct.accountNo,
                  child: Text(acct.accountNo),
                ),
              )
              .toList(),
          onChanged: accounts.isEmpty
              ? null
              : (v) {
            setState(() {
              selectedFxAccount = v as String?;
              fxWithdrawCurrency = null;
            });
          },
        ),
        const SizedBox(height: 5),

        if (accounts.isEmpty)
          const Text(
            '등록된 외화출금계좌가 없습니다.',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),

        if (fxBalance != null && fxWithdrawCurrency != null)
          Text(
              "출금가능금액 ${_amountFormat.format(fxBalance)} $fxWithdrawCurrency",
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
          items: availableCurrencies
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),

          onChanged: (v) => setState(() => fxWithdrawCurrency = v),
        ),
      ],
    );
  }

  KrwAccount? _currentKrwAccount() {
    if (_context == null || selectedKrwAccount == null) return null;
    try {
      return _context!.krwAccounts
          .firstWhere((acct) => acct.accountNo == selectedKrwAccount);
    } catch (_) {
      return null;
    }
  }

  int? _selectedKrwBalance() => _currentKrwAccount()?.balance;

  FxAccount? _currentFxAccount() {
    if (_context == null || selectedFxAccount == null) return null;
    try {
      return _context!.fxAccounts
          .firstWhere((acct) => acct.accountNo == selectedFxAccount);
    } catch (_) {
      return null;
    }
  }

  double? _selectedFxBalance() {
    if (fxWithdrawCurrency == null) return null;
    final balances = _currentFxAccount()?.balances ?? [];
    try {
      return balances
          .firstWhere((bal) =>
              bal.currency.toUpperCase() == fxWithdrawCurrency!.toUpperCase())
          .balance;
    } catch (_) {
      return null;
    }
  }

  List<String> _availableFxCurrencies(DepositProduct product) {
    final balances = _currentFxAccount()?.balances ?? [];
    if (balances.isEmpty) return _currencyOptions;

    final available = balances.map((b) => b.currency).toSet();
    return _currencyOptions.where((c) => available.contains(c)).toList();
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
              _syncAppliedFxRate();
            });
          },

        ),
        if (newCurrency.isNotEmpty && newCurrency.toUpperCase() != 'KRW')
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Text(
                  "적용 환율",
                  style: TextStyle(color: AppColors.pointDustyNavy),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    appliedFxRate != null
                        ? '1 $newCurrency = ${appliedFxRate!.toStringAsFixed(4)} KRW'
                        : (_latestFxRates.isEmpty
                        ? '환율 정보를 불러오지 못했습니다.'
                        : '환율 정보를 불러오는 중입니다.'),
                    style: TextStyle(
                      color: appliedFxRate != null
                          ? AppColors.pointDustyNavy
                          : AppColors.pointDustyNavy.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
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

        if (newAmount.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _krwEstimateText(),
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
  Widget _autoRenewSection(DepositProduct product) {
    final bool autoRenewAllowed =
        product.dpstAutoRenewYn.toUpperCase() == 'Y';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SwitchListTile(

          title: const Text('만기 자동연장'),
          subtitle: Text(autoRenewAllowed
              ? '만기 시 동일 조건으로 자동연장합니다.'
              : '이 상품은 자동연장을 지원하지 않습니다.'),
          value: autoRenew == 'apply' && autoRenewAllowed,




          activeColor: AppColors.pointDustyNavy,
          onChanged: autoRenewAllowed
              ? (v) {
            setState(() {
                    autoRenew = v ? 'apply' : 'no';
                    if (!v) {
                      autoRenewCycle = null;
                      autoRenewCount = null;
                      _autoRenewCountController.clear();


                    }
                  });
                }
              : null,
        ),



        SwitchListTile(
          title: const Text('만기 시 자동 해지'),
          subtitle: const Text('만기 시 자동으로 해지합니다.'),
          value: autoTerminateAtMaturity,

          activeColor: AppColors.pointDustyNavy,
          onChanged: (v) => setState(() => autoTerminateAtMaturity = v),

        ),


      ],
    );
  }


  // ----------------------------------------
  // ④ 비밀번호
  // ----------------------------------------
  Widget _passwordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          "정기예금 비밀번호",
          style: TextStyle(
            color: AppColors.pointDustyNavy,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 14),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 200,
              child: TextField(
                obscureText: true,
                maxLength: 4,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "비밀번호",
                  counterText: "",
                  border: UnderlineInputBorder(),
                ),
                onChanged: (v) {
                  setState(() {
                    depositPw = v;
                    isPwMatched = (depositPw == depositPwCheck);
                  });
                },
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: 200,
              child: TextField(
                obscureText: true,
                maxLength: 4,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "비밀번호 확인",
                  counterText: "",
                  border: UnderlineInputBorder(),
                ),
                onChanged: (v) {
                  setState(() {
                    depositPwCheck = v;
                    isPwMatched = (depositPw == depositPwCheck);
                  });
                },
              ),
            ),
          ],
        ),


        if (!isPwMatched)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              "비밀번호가 일치하지 않습니다.",
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }



  Widget _schemaHint(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.pointDustyNavy.withOpacity(0.7),
        ),
      ),
    );
  }


  void _syncAppliedFxRate({Map<String, double>? rates}) {
    final Map<String, double> rateSource = rates ?? _latestFxRates;
    final upperCurrency = newCurrency.toUpperCase();

    if (rateSource.isEmpty) {
      _appliedFxRateController.text =
      appliedFxRate != null ? appliedFxRate.toString() : '';
      return;
    }

    appliedFxRate = upperCurrency.isEmpty || upperCurrency == 'KRW'
        ? null
        : (rateSource[upperCurrency] ?? appliedFxRate);

    _appliedFxRateController.text =
    appliedFxRate != null ? appliedFxRate.toString() : '';
  }


  double? _effectiveFxRate() {

    return appliedFxRate;
  }


  double? _krwEquivalentAmount() {
    if (newAmount.isEmpty) return null;

    final parsedAmount = double.tryParse(newAmount);
    if (parsedAmount == null) return null;

    if (newCurrency.toUpperCase() == 'KRW') return parsedAmount.toDouble();

    final rate = _effectiveFxRate();
    if (rate == null) return null;

    return parsedAmount * rate;
  }

  Widget _krwEstimateText() {
    final upperCurrency = newCurrency.toUpperCase();
    if (upperCurrency.isEmpty) return const SizedBox.shrink();

    final krwAmount = _krwEquivalentAmount();

    if (krwAmount == null) {
      if (upperCurrency != 'KRW') {
        return Text(
          '환율 정보를 불러오는 중입니다.',
          style: TextStyle(color: AppColors.pointDustyNavy.withOpacity(0.7)),
        );
      }
      return const SizedBox.shrink();
    }

    final label = upperCurrency == 'KRW' ? '입력 금액' : '환율 적용 금액';

    return Text(
      '원화 환산 금액($label): ${_amountFormat.format(krwAmount)} KRW',
      style: const TextStyle(
        color: AppColors.pointDustyNavy,
        fontWeight: FontWeight.w600,
      ),
    );
  }


  double _withdrawAmountForValidation(double baseAmount) {
    if (withdrawType == 'krw' && newCurrency.toUpperCase() != 'KRW') {
      final fxRate = _effectiveFxRate() ?? 1.0;
      return baseAmount * fxRate;
    }
    return baseAmount;
  }

  // ----------------------------------------
  // 다음 버튼 활성 조건
  // ----------------------------------------
  bool _isAllFieldsFilled() {
    if (withdrawType == "krw") {
      if (_context?.krwAccounts.isEmpty ?? true) return false;
      if (selectedKrwAccount == null) return false;
      if (krwPassword.length != 4) return false;
    } else {
      if (_context?.fxAccounts.isEmpty ?? true) return false;
      if (selectedFxAccount == null) return false;
      if (fxPassword.length != 4) return false;
      if (fxWithdrawCurrency == null) return false;
    }

    if (newCurrency.isEmpty) return false;
    if (newAmount.isEmpty) return false;
    if (newPeriod == null) return false;




    final product = widget.application.product;
    if (autoRenew == 'apply' &&
        product != null && product.dpstAutoRenewYn.toUpperCase() == 'N') {
      return false;
    }


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

    final parsedAmount = double.tryParse(newAmount) ?? 0;
    if (limit != null) {
      if (parsedAmount < limit.min) {
        return _err('최소 가입 금액은 ${_amountFormat.format(limit.min)} 입니다.');
      }
      if (limit.max > 0 && parsedAmount > limit.max) {
        return _err('최대 가입 금액은 ${_amountFormat.format(limit.max)} 입니다.');
      }
    }

    if (parsedAmount <= 0) return _err('유효한 금액을 입력해주세요.');

    final fxRate = _effectiveFxRate();
    if (withdrawType == 'krw' && newCurrency.toUpperCase() != 'KRW' &&
        fxRate == null) {
      return _err('환율 정보를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.');
    }

    final availableBalance = withdrawType == 'krw'
        ? _selectedKrwBalance()?.toDouble()
        : _selectedFxBalance();

    final double convertedWithdrawAmount = _withdrawAmountForValidation(parsedAmount);

    if (availableBalance != null && convertedWithdrawAmount > availableBalance) {

      return _err('출금가능금액을 초과했습니다.');
    }


    if (autoRenew == 'apply') {
      if (selectedProduct != null &&
          selectedProduct.dpstAutoRenewYn.toUpperCase() == 'N') {
        return _err('이 상품은 자동연장을 지원하지 않습니다.');
      }


    }

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
              ? () async {
                  if (_validateInputs()) {
                    _saveToApplication();
                    await _draftService.saveDraft(
                      widget.application,
                      step: 2,
                      customerCode: _context?.customerCode,
                    );

                    if (!mounted) return;
                    Navigator.pushNamed(
                      context,
                      DepositStep3Screen.routeName,
                      arguments: widget.application,
                    );
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

  Future<_Step2Data> _loadData() async {
    debugPrint('[DepositStep2] _loadData start (dpstId: ${widget.application.dpstId})');
    DepositProduct? product = widget.application.product;

    if (product != null) {
      debugPrint('[DepositStep2] 기존 상품 정보 사용 가능: ${product.name}');
    }

    try {
      final fetched = await _service.fetchProductDetail(widget.application.dpstId);
      product = fetched;
      debugPrint('[DepositStep2] 상품 상세 조회 성공: ${product.name}');
    } catch (e, stack) {
      debugPrint('[DepositStep2] 상품 상세 조회 실패: $e');
      debugPrintStack(stackTrace: stack);

      if (product == null) {
        debugPrint('[DepositStep2] 사용할 기존 상품 정보가 없어 예외를 발생시킵니다.');
        throw Exception('상품 정보를 불러오지 못했습니다.');
      }

      debugPrint('[DepositStep2] 네트워크 오류로 기존 상품 정보를 그대로 사용합니다.');
    }

    DepositContext context;
    try {
      context = await _service.fetchContext();
      debugPrint('[DepositStep2] 사용자 컨텍스트 조회 성공: ${context.customerName}');
    } catch (e, stack) {
      debugPrint('[DepositStep2] 사용자 컨텍스트 조회 실패: $e');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }

    Map<String, double> fetchedFxRates = {};
    try {
      final rates = await ExchangeApi.fetchRates();
      fetchedFxRates = {
        for (final rate in rates) rate.code.toUpperCase(): rate.rate,
      };
      debugPrint('[DepositStep2] 환율 조회 성공: ${fetchedFxRates.length}개 통화');
    } catch (e, stack) {
      debugPrint('[DepositStep2] 환율 조회 실패: $e');
      debugPrintStack(stackTrace: stack);
    }



    widget.application.product = product;
    widget.application.customerName ??= context.customerName;
    widget.application.customerCode ??= context.customerCode;
    _context = context;
    _latestFxRates = fetchedFxRates;

    _currencyOptions = _parseCurrencies(product);
    _periodOptions = _buildPeriodOptions(product);

    _loadFromApplication(product);
    _applyProductRules(product);

    if (selectedKrwAccount == null && context.krwAccounts.isNotEmpty) {
      selectedKrwAccount = context.krwAccounts.first.accountNo;
    }

    if (selectedFxAccount == null && context.fxAccounts.isNotEmpty) {
      selectedFxAccount = context.fxAccounts.first.accountNo;
    }

    if (newCurrency.isEmpty && _currencyOptions.isNotEmpty) {
      newCurrency = _currencyOptions.first;
    }

    if (withdrawType == 'krw' && newCurrency != 'KRW') {
      withdrawType = 'fx';
    }

    if (newPeriod == null && _periodOptions.isNotEmpty) {
      newPeriod = _periodOptions.first.toString();
    }

    if (fxWithdrawCurrency == null && withdrawType == 'fx') {
      final fxOptions = _availableFxCurrencies(product);
      if (fxOptions.isNotEmpty) {
        fxWithdrawCurrency = fxOptions.first;
      }
    }

    if (newAmount.isEmpty) {
      final limit = _findLimitFor(newCurrency, product);
      if (limit != null) newAmount = limit.min.toString();
    }

    _syncAppliedFxRate();

    return _Step2Data(product: product, context: context);
  }

  void _loadFromApplication(DepositProduct product) {
    withdrawType = widget.application.withdrawType;
    autoRenew = widget.application.autoRenew;
    autoRenewCycle = widget.application.autoRenewCycle;
    autoRenewCount = widget.application.autoRenewCount;
    autoTerminateAtMaturity = widget.application.autoTerminateAtMaturity;
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
    appliedRate = widget.application.appliedRate;
    appliedFxRate = widget.application.appliedFxRate;

    depositPw = widget.application.depositPassword;
    depositPwCheck = widget.application.depositPassword;

    _appliedRateController.text =
        appliedRate != null ? appliedRate.toString() : '';
    _appliedFxRateController.text =
        appliedFxRate != null ? appliedFxRate.toString() : '';



    if (newPeriod == null && product.fixedPeriodMonth != null) {
      newPeriod = product.fixedPeriodMonth.toString();
    }
  }

  void _applyProductRules(DepositProduct product) {
    if (product.dpstAutoRenewYn.toUpperCase() != 'Y') {
      autoRenew = 'no';
      autoRenewCycle = null;
      autoRenewCount = null;
      _autoRenewCountController.clear();
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
    appliedFxRate = _effectiveFxRate();

    final startDate = _deriveStartDate();
    final maturityDate = _deriveMaturityDate(startDate);
    final linkedAccount =
    withdrawType == 'fx' ? selectedFxAccount : selectedKrwAccount;

    widget.application
      ..product = widget.application.product
      ..customerCode = _context?.customerCode ?? widget.application.customerCode
      ..withdrawType = withdrawType
      ..selectedKrwAccount = selectedKrwAccount
      ..selectedFxAccount = selectedFxAccount
      ..fxWithdrawCurrency = fxWithdrawCurrency
      ..withdrawPassword = withdrawType == 'krw' ? krwPassword : fxPassword
      ..newCurrency = newCurrency
      ..newAmount = int.tryParse(newAmount)
      ..newPeriodMonths = int.tryParse(newPeriod ?? '')
      ..autoRenew = autoRenew
      ..autoRenewCycle = null
      ..autoRenewCount = null

      ..autoTerminateAtMaturity = autoTerminateAtMaturity

      ..appliedRate = appliedRate
      ..appliedFxRate = appliedFxRate

      ..addPaymentEnabled = false
      ..addPaymentCount = null
      ..partialWithdrawEnabled = false
      ..partialWithdrawCount = null
      ..dpstHdrCurrencyExp = newCurrency
      ..dpstHdrLinkedAcctBal = _withdrawAmountForValidation(
        double.tryParse(newAmount) ?? 0,
      )

      ..depositPassword = depositPw;


  }

  DateTime _deriveStartDate() {
    return DateTime.now();
  }

  DateTime _deriveMaturityDate(DateTime startDate) {
    final months = int.tryParse(newPeriod ?? '0') ?? 0;
    return DateTime(startDate.year, startDate.month + months, startDate.day);
  }
}

class _Step2Data {
  final DepositProduct product;
  final DepositContext context;

  const _Step2Data({required this.product, required this.context});
}

