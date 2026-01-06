import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:test_main/screens/auth/pin_login_screen.dart';
import 'package:test_main/screens/member/signup_1.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:test_main/services/api_service.dart';
import 'package:test_main/screens/auth/pin_setup_screen.dart';
import 'package:test_main/voice/controller/voice_session_controller.dart';
import 'package:test_main/voice/core/voice_navigation_coordinator.dart';
import 'package:test_main/voice/overlay/voice_overlay_manager.dart';
import 'package:test_main/voice/scope/voice_session_scope.dart';
import 'package:test_main/voice/service/voice_stt_service.dart';
import 'package:test_main/voice/service/voice_tts_service.dart';
import 'package:test_main/voice/ui/voice_assistant_overlay.dart';

import 'screens/app_colors.dart';
import 'screens/main/bank_homepage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:test_main/screens/auth/auth_verification_screen.dart';

import 'package:test_main/utils/device_manager.dart';
import 'package:http/http.dart' as http;
import 'package:test_main/models/deposit/application.dart';

import 'package:test_main/screens/splash_screen.dart';

import 'package:test_main/screens/deposit/view.dart';
import 'package:test_main/screens/deposit/step_1.dart';
import 'package:test_main/screens/deposit/step_2.dart';
import 'package:test_main/screens/deposit/step_3.dart';
import 'package:test_main/screens/deposit/step_4.dart';
import 'package:test_main/screens/deposit/signature.dart';
import 'package:test_main/screens/deposit/recommend.dart';
import 'package:test_main/screens/deposit/survey.dart';
import 'package:test_main/screens/main/menu/review_write.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin localNoti = FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel highChannel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'Foreground notifications',
  importance: Importance.high,
);

Future<void> initLocalNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);

  await localNoti.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (res) {
      // 알림 눌렀을 때 처리(원하면 payload로 라우팅 가능)
    },
  );

  final androidPlugin =
  localNoti.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  // Android 13+ 로컬 알림 권한(없으면 heads-up 안 뜰 수 있음)
  await androidPlugin?.requestNotificationsPermission();

  // Android 8+ 채널 생성
  await androidPlugin?.createNotificationChannel(highChannel);
}
Future<void> showForegroundNotification(RemoteMessage message) async {
  final n = message.notification;
  if (n == null) return;

  final details = AndroidNotificationDetails(
    highChannel.id,
    highChannel.name,
    channelDescription: highChannel.description,
    importance: Importance.high,
    priority: Priority.high,
  );

  await localNoti.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique id
    n.title ?? '',
    n.body ?? '',
    NotificationDetails(android: details),
    payload: jsonEncode(message.data),
  );
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // (기존 로직) 기기 ID 확보
  final deviceId = await DeviceManager.getDeviceId();
  debugPrint("[App Start] 기기 고유 ID 확보 완료: $deviceId");

  // (기존 로직) 날짜 포맷 로딩
  await initializeDateFormatting();

  // (FCM 로직) Firebase 초기화
  await Firebase.initializeApp();

  // 알림 권한 요청 (iOS 필수, Android는 보통 자동 허용)
  await FirebaseMessaging.instance.requestPermission();
  await initLocalNotifications();


  // 토픽 구독 + 토큰 확인
  await FirebaseMessaging.instance.subscribeToTopic('notice');
  debugPrint('Subscribed to topic: notice');

  final token = await FirebaseMessaging.instance.getToken();
  debugPrint('FCM token: $token');

  if (token != null && token.isNotEmpty) {
    await sendTokenToServer(
      baseUrl: "https://flobank.kro.kr/backend/api/mobile",
      token: token,
      platform: "ANDROID",
      deviceId: deviceId,
      appVersion: "1.0.0",
      locale: "ko-KR",
      // jwt: accessToken,
    );
  }

  // 토큰 갱신 리스너 (서버에 업데이트할 때 사용)
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    debugPrint('FCM token refreshed: $newToken');

    await sendTokenToServer(
      baseUrl: "https://flobank.kro.kr/backend/api/mobile",
      token: newToken,
      platform: "ANDROID",
      deviceId: deviceId,
      appVersion: "1.0.0",
      locale: "ko-KR",
      // jwt: accessToken,
    );
  });

  // 앱이 "종료 상태"에서 푸시 눌러 켜진 경우
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    final route = initialMessage.data['route'];
    if (route != null) {
      // runApp 이후에 네비게이션 가능하니, 필요하면 여기서는 저장만 해두고
      // WidgetsBinding.instance.addPostFrameCallback에서 처리하는 방식 추천
    }
  }

  // 앱이 "백그라운드"에서 푸시 눌러 열린 경우
  FirebaseMessaging.onMessageOpenedApp.listen((m) {
    final route = m.data['route'];
    if (route != null) {
      navigatorKey.currentState?.pushNamed(route);
    }
  });
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    await showForegroundNotification(message);
  });

  // 음성 머신 시작점임
  // VoiceSessionController는 여기서 한 번만 생성
  final voiceController = VoiceSessionController(
      stt: VoiceSttService(),
      tts: VoiceTtsService(),
      onSessionEnded: () {
        VoiceOverlayManager.hide();
      }
  );

  runApp(
    VoiceSessionScope(
      controller: voiceController,
      child: const MyApp(),
    ),
  );

}

Future<void> sendTokenToServer({
  required String baseUrl,
  required String token,
  required String platform,
  String? deviceId,
  String? appVersion,
  String? locale,
  String? jwt, // 로그인 붙이면 여기에 Bearer 토큰 넣기
}) async {
  final body = {
    "token": token,
    "platform": platform,
    "deviceId": deviceId,
    "appVersion": appVersion ?? "1.0.0",
    "locale": locale ?? "ko-KR",
  };

  final res = await http.post(
    Uri.parse('$baseUrl/device-tokens'),
    headers: {
      "Content-Type": "application/json",
      if (jwt != null && jwt.isNotEmpty) "Authorization": "Bearer $jwt",
    },
    body: jsonEncode(body),
  );

  debugPrint("FCM token register => ${res.statusCode} ${res.body}");
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  VoiceNavigationCoordinator? _voiceNav;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_voiceNav != null) return;

    final voiceController = VoiceSessionScope.of(context);
    _voiceNav = VoiceNavigationCoordinator(
      navigatorKey: navigatorKey,
      controller: voiceController,
    );
  }


  @override
  void initState() {
    super.initState();
    _initPushTapRouting();
  }

  @override
  void dispose() {
    _voiceNav?.dispose();
    super.dispose();
  }

  void _initPushTapRouting() async {
    // 1) 종료 상태에서 알림 눌러 켠 경우
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _routeFromData(initial.data);
      });
    }

    // 2) 백그라운드에서 알림 눌러 열린 경우
    FirebaseMessaging.onMessageOpenedApp.listen((m) {
      _routeFromData(m.data);
    });
  }

  void _routeFromData(Map<String, dynamic> data) {
    final route = data['route'] as String?;
    if (route == null) return;

    navigatorKey.currentState?.pushNamed(route, arguments: data);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'FLOBANK',
      theme: ThemeData(useMaterial3: true),

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
          final args = ModalRoute.of(context)!.settings.arguments;
          if (args is DepositStep1Args) {
            return DepositStep1Screen(
              dpstId: args.dpstId,
              product: args.product,
              prefill: args.prefill,
            );
          }

          final dpstId = args as String;

          return DepositStep1Screen(dpstId: dpstId);
        },

        // -------------------------
        // 예금 가입 Step 2 (정보입력)
        // -------------------------
        DepositStep2Screen.routeName: (context) {
          final args = ModalRoute.of(context)!.settings.arguments;

          if (args is DepositApplication) {

            return DepositStep2Screen(application: args);
          }

          if (args is String) {
            // 음성 플로우 (dpstId)
            return DepositStep2Screen(dpstId: args);
          }

          return const DepositStep2Screen();
        },

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
        '/tx/detail': (_) => const TxDetailScreen(),
        '/notice/detail': (_) => const NoticeDetailScreen(),
      },
      home: const SplashScreen(),
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
              String id = _idController.text.trim();
              String pw = _pwController.text.trim();

              if (id.isEmpty || pw.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('아이디와 비밀번호를 입력해주세요.')));
                return;
              }

              String deviceId = await DeviceManager.getDeviceId();

              // 로그인 요청
              Map<String, dynamic> result = await ApiService.login(id, pw, deviceId);

              if (!mounted) return;

              if (result['status'] == 'SUCCESS') {
                print("✅ 로그인 성공 -> PIN 검증 단계로 이동");

                // ID 저장 (필수)
                await const FlutterSecureStorage().write(key: 'saved_userid', value: id);

                // 서버에서 받은 hasPin 값 확인
                bool hasPin = result['hasPin'] ?? false;

                if (hasPin) {
                  // ★ [수정] 바로 BankHomePage로 가지 않고, PinLoginScreen으로 이동하여 검증 유도
                  // (PinLoginScreen에서 인증 성공해야 BankHomePage로 넘어가게 됨)
                  if (!mounted) return;
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PinLoginScreen(
                              userId: id,
                              autoBioAuth: true // ★ (선택) ID/PW 쳤으니 지문은 생략할지, 띄울지 선택 (보통 true 추천)
                          )
                      )
                  );
                } else {
                  // PIN이 없으면 설정 화면으로 이동
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('보안을 위해 간편 비밀번호 설정이 필요합니다.'))
                  );

                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => PinSetupScreen(userId: id))
                  );
                }
              }
              else if (result['status'] == 'NEW_DEVICE') {
                // ★ 새로운 기기 감지 -> 인증 화면 이동
                bool hasPin = result['hasPin'] ?? false;

                if (!mounted) return;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AuthVerificationScreen(
                          userId: id,
                          userPassword: pw,
                          hasPin: hasPin, // ★ 생성자로 전달
                        )
                    )
                );
              }
              else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? '로그인 실패')));
              }
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
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 1. 지문 로그인 버튼
            _ShortcutButton(
              icon: Icons.fingerprint,
              label: '지문 로그인',
              onTap: () async {
                // TODO: 지문 인식 로직 호출 (아래 3단계에서 설명)
                print("지문 인증 시작");
              },
            ),
            // 2. 간편 비밀번호 로그인 버튼
            _ShortcutButton(
              icon: Icons.smartphone,
              label: '간편 비밀번호',
              onTap: () async {
                // 로컬에 저장된 ID가 있는지 확인
                String? savedId = await const FlutterSecureStorage().read(key: 'saved_userid');

                if (savedId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('등록된 정보가 없습니다. 일반 로그인을 먼저 진행해주세요.'))
                  );
                  return;
                }

                // PIN 입력 화면으로 이동 (로그인 용도)
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PinLoginScreen(userId: savedId))
                );
              },
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
///////////////////////////
class TxDetailScreen extends StatelessWidget {
  const TxDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    return Scaffold(
      appBar: AppBar(title: const Text('거래 상세')),
      body: Center(child: Text('args: $args')),
    );
  }
}

class NoticeDetailScreen extends StatelessWidget {
  const NoticeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    return Scaffold(
      appBar: AppBar(title: const Text('공지 상세')),
      body: Center(child: Text('args: $args')),
    );
  }
}

