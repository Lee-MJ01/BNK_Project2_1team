import 'package:flutter/material.dart';
import 'package:test_main/screens/member/signup_1.dart';
import 'package:test_main/services/api_service.dart';

import 'screens/app_colors.dart';
import 'screens/main/bank_homepage.dart';
import 'package:intl/date_symbol_data_local.dart';


import 'package:test_main/screens/deposit/view.dart';
import 'package:test_main/screens/deposit/step_1.dart';
import 'package:test_main/screens/deposit/step_2.dart';
import 'package:test_main/screens/deposit/step_3.dart';
import 'package:test_main/screens/deposit/step_4.dart';
import 'package:test_main/screens/deposit/signature.dart';
import 'package:test_main/screens/deposit/recommend.dart';
import 'package:test_main/screens/deposit/survey.dart';
import 'package:test_main/screens/main/menu/review_write.dart';

import 'package:test_main/utils/device_manager.dart';
import 'package:http/http.dart' as http;
import 'package:test_main/models/deposit/application.dart';


void main() async{
  // 1. 플러터 엔진 초기화 (비동기 작업 전 필수)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. 앱 실행 시점에 UUID 생성/확인
  // 저장소에 기기 ID가 없으면 새로 만들고, 있으면 가져옴
  String deviceId = await DeviceManager.getDeviceId();
  debugPrint("[App Start] 기기 고유 ID 확보 완료: $deviceId");

  await initializeDateFormatting();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FLOBANK',
      theme: ThemeData(useMaterial3: true),


      //예금 가입하기 관련 페이지 이동
      routes: {
        // -------------------------
        // 예금 상품 상세
        // -------------------------
        DepositViewScreen.routeName: (context) {
          final args =
          ModalRoute.of(context)!.settings.arguments as DepositViewArgs;

          return DepositViewScreen(
            dpstId: args.dpstId,
          );
        },

        // -------------------------
        // 예금 가입 Step 1 (약관동의)
        // -------------------------
        DepositStep1Screen.routeName: (context) {
          final dpstId =
          ModalRoute.of(context)!.settings.arguments as String;

          return DepositStep1Screen(dpstId: dpstId);
        },

        // -------------------------
        // 예금 가입 Step 2 (정보입력)
        // -------------------------
        DepositStep2Screen.routeName: (context) {
          final application =
          ModalRoute.of(context)!.settings.arguments as DepositApplication;

          return DepositStep2Screen(application: application);        },

        // -------------------------
        // 예금 가입 Step 3 (확인)
        // -------------------------
        DepositStep3Screen.routeName: (context) {
          final application =
          ModalRoute.of(context)!.settings.arguments as DepositApplication;

          return DepositStep3Screen(application: application);
        },

        DepositSignatureScreen.routeName: (context) {
          final application =
          ModalRoute.of(context)!.settings.arguments as DepositApplication;

          return DepositSignatureScreen(application: application);        },

        DepositStep4Screen.routeName: (context) {
          final args =
          ModalRoute.of(context)!.settings.arguments as DepositCompletionArgs;

          return DepositStep4Screen(args: args);
        },

        RecommendScreen.routeName: (_) => const RecommendScreen(),
        DepositSurveyScreen.routeName: (_) => const DepositSurveyScreen(),
        DepositReviewWriteScreen.routeName: (_) =>
        const DepositReviewWriteScreen(),
      },
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LoginHeader(theme: theme),
              const SizedBox(height: 18),
              const _HeroLoginCard(),
              const SizedBox(height: 16),
              const _LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      'FloBank에 다시 오신 것을 환영합니다',
      style: theme.textTheme.titleLarge?.copyWith(
        color: AppColors.pointDustyNavy,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _HeroLoginCard extends StatelessWidget {
  const _HeroLoginCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.mainPaleBlue, AppColors.subIvoryBeige],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        '간편 인증, 지문 로그인, 1:1 플로봇으로\n빠르게 로그인해보세요.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.pointDustyNavy.withOpacity(0.8),
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  bool rememberMe = true;
  bool showPassword = false;

  // 입력값 가져오는 컨트롤러 추가
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  @override
  void dispose() {
    // 메모리 누수 방지를 위해 화면이 꺼질 때 컨트롤러 정리
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EBF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '로그인 정보',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.pointDustyNavy,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _idController, // 컨트롤러 연결
            decoration: InputDecoration(
              labelText: '아이디 또는 이메일',
              prefixIcon: Icon(Icons.person_outline, color: AppColors.pointDustyNavy),
              hintText: 'example@flobank.com',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pwController, // 컨트롤러 연결
            obscureText: !showPassword,
            decoration: InputDecoration(
              labelText: '비밀번호',
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.pointDustyNavy),
              suffixIcon: IconButton(
                onPressed: () => setState(() => showPassword = !showPassword),
                icon: Icon(
                  showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.pointDustyNavy,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Switch(
                value: rememberMe,
                activeColor: Colors.white,
                activeTrackColor: AppColors.pointDustyNavy,
                inactiveTrackColor: AppColors.mainPaleBlue.withOpacity(0.7),
                onChanged: (value) => setState(() => rememberMe = value),
              ),
              const Text('로그인 상태 유지'),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(foregroundColor: AppColors.pointDustyNavy),
                child: const Text('비밀번호 찾기'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.pointDustyNavy,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () async {
              // 1. 입력값 확인
              // String id = _idController.text.trim();
              // String pw = _pwController.text.trim();


              // if (id.isEmpty || pw.isEmpty) {
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     const SnackBar(content: Text('아이디와 비밀번호를 입력해주세요.')),
              //   );
              //   return;
              // }

              // 2. 기기 ID 가져오기 (main에서 이미 만들어졌으므로 즉시 리턴됨)
              // String deviceId = await DeviceManager.getDeviceId();

              // 3. 로그인 요청 및 결과 처리 (Map으로 받음)
              // Map<String, dynamic> result = await ApiService.login(id, pw, deviceId);
              // String status = result['status']; // 서버에서 보낸 status 값 확인
              //
              // if (!mounted) return;
              //
              // if (status == 'SUCCESS') {
              //   // [Case A] 정상 로그인 (기기 일치)
              //   print("✅ 로그인 성공 & 기기 인증 완료");
              //   Navigator.pushReplacement(
              //       context,
              //       MaterialPageRoute(builder: (context) => const BankHomePage())
              //   );
              // } else if (status == 'NEW_DEVICE') {
              //   // [Case B] 새로운 기기 감지 -> 추가 인증 필요
              //   print("새로운 기기 감지됨. 본인 인증 필요.");
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     const SnackBar(
              //       content: Text('새로운 기기가 감지되었습니다. 본인 인증을 진행해주세요.'),
              //       duration: Duration(seconds: 3),
              //     ),
              //   );
              //
              //   // TODO: 여기서 본인인증 화면(SMS 등)으로 이동시키는 로직 추가
              //   // Navigator.push(context, MaterialPageRoute(builder: (context) => AuthCheckPage()));
              //
              // } else {
              //   // [Case C] 로그인 실패 (아이디/비번 틀림 등)
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     SnackBar(content: Text(result['message'] ?? '로그인에 실패했습니다.')),
              //   );
              // }
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const BankHomePage(),
                ),
              );
            },
            child: const Text('로그인하기'),
          ),
          const SizedBox(height: 12),
          const _LoginShortcuts(),
        ],
      ),
    );
  }
}

class _LoginShortcuts extends StatelessWidget {
  const _LoginShortcuts();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ShortcutButton(
              icon: Icons.fingerprint,
              label: '지문 로그인',
            ),
            _ShortcutButton(
              icon: Icons.smartphone,
              label: '간편 비밀번호',
            ),
            _ShortcutButton(
              icon: Icons.person_add_alt_1,
              label: '회원가입',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUp1Page()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _ShortcutButton extends StatelessWidget {
  const _ShortcutButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.subIvoryBeige,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.mainPaleBlue.withOpacity(0.7)),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.pointDustyNavy),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.pointDustyNavy,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

