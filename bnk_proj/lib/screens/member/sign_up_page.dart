import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../../main.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  /// 1단계(약관) / 2단계(정보입력)
  int _currentStep = 1;

  bool _allAgree = false;
  bool _serviceAgree = false;   // 서비스 이용약관 (필수)
  bool _privacyAgree = false;   // 개인정보 수집 및 이용 (필수)
  bool _efinAgree = false;      // 전자금융거래 기본약관 (필수)
  bool _marketingAgree = false; // 선택

  /// 필수 약관 모두 동의했는지
  bool get _requiredAllChecked =>
      _serviceAgree && _privacyAgree && _efinAgree;

  void _updateAllAgree(bool value) {
    setState(() {
      _allAgree = value;
      _serviceAgree = value;
      _privacyAgree = value;
      _efinAgree = value;
      // 선택은 같이 묶고 싶으면 이 줄도 true로
      _marketingAgree = value;
    });
  }

  void _syncAllAgree() {
    // 필수 + 선택 모두 true면 전체동의 true로 / 아니면 false
    final all = _serviceAgree && _privacyAgree && _efinAgree && _marketingAgree;
    setState(() {
      _allAgree = all;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(theme: theme),
              const SizedBox(height: 20),
              _ProgressSteps(theme: theme, currentStep: _currentStep),
              const SizedBox(height: 18),

              // ✅ 1단계: 약관 동의
              if (_currentStep == 1) ...[
                _InfoCard(
                  title: '약관 동의',
                  description: 'FloBank 이용을 위한 필수 약관에 먼저 동의해 주세요.',
                  child: Column(
                    children: [
                      AgreementItem(
                        label: '전체 동의하기',
                        isPrimary: true,
                        value: _allAgree,
                        onChanged: (v) => _updateAllAgree(v),
                      ),
                      const SizedBox(height: 8),
                      AgreementItem(
                        label: '서비스 이용약관 (필수)',
                        value: _serviceAgree,
                        onChanged: (v) {
                          setState(() => _serviceAgree = v);
                          _syncAllAgree();
                        },
                      ),
                      AgreementItem(
                        label: '개인정보 수집 및 이용 (필수)',
                        value: _privacyAgree,
                        onChanged: (v) {
                          setState(() => _privacyAgree = v);
                          _syncAllAgree();
                        },
                      ),
                      AgreementItem(
                        label: '전자금융거래 기본약관 (필수)',
                        value: _efinAgree,
                        onChanged: (v) {
                          setState(() => _efinAgree = v);
                          _syncAllAgree();
                        },
                      ),
                      AgreementItem(
                        label: '마케팅 정보 수신 (선택)',
                        value: _marketingAgree,
                        isOptional: true,
                        onChanged: (v) {
                          setState(() => _marketingAgree = v);
                          _syncAllAgree();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // 다음 단계 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _requiredAllChecked
                          ? AppColors.pointDustyNavy
                          : AppColors.pointDustyNavy.withOpacity(0.4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _requiredAllChecked
                        ? () {
                      setState(() => _currentStep = 2);
                    }
                        : null,
                    child: const Text(
                      '모두 동의하고 다음',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],

              // ✅ 2단계: 정보 입력 + 가입
              if (_currentStep == 2) ...[
                _InfoCard(
                  title: '기본 정보',
                  description: 'FloBank에서 사용할 연락처와 비밀번호를 등록하세요.',
                  child: Column(
                    children: const [
                      _LabeledField(label: '이름', hint: '이름을 입력하세요'),
                      SizedBox(height: 12),
                      _LabeledField(
                        label: '이메일',
                        hint: 'name@example.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 12),
                      _LabeledField(
                        label: '휴대폰 번호',
                        hint: "010-0000-0000",
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 12),
                      _LabeledField(
                        label: '비밀번호',
                        hint: '8자 이상 영문, 숫자 조합',
                        obscure: true,
                      ),
                      SizedBox(height: 12),
                      _LabeledField(
                        label: '비밀번호 확인',
                        hint: '비밀번호를 다시 입력',
                        obscure: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _ActionButtons(theme: theme),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------- 공통 UI ----------------

class _Header extends StatelessWidget {
  const _Header({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      '회원가입',
      style: theme.textTheme.headlineSmall?.copyWith(
        color: AppColors.pointDustyNavy,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ProgressSteps extends StatelessWidget {
  const _ProgressSteps({
    required this.theme,
    required this.currentStep,
  });

  final ThemeData theme;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final steps = ['약관 동의', '정보 입력', '계좌 설정'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.subIvoryBeige,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.mainPaleBlue.withOpacity(0.7)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: steps.map((step) {
          final index = steps.indexOf(step) + 1;
          final isActive = index <= currentStep;
          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                    isActive ? AppColors.pointDustyNavy : AppColors.mainPaleBlue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  step,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isActive
                        ? AppColors.pointDustyNavy
                        : AppColors.pointDustyNavy.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.mainPaleBlue.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.pointDustyNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.pointDustyNavy.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.hint,
    this.keyboardType,
    this.obscure = false,
  });

  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppColors.pointDustyNavy,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          keyboardType: keyboardType,
          obscureText: obscure,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

/// ✅ 체크 가능한 약관 아이템
class AgreementItem extends StatelessWidget {
  const AgreementItem({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.isPrimary = false,
    this.isOptional = false,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isPrimary;
  final bool isOptional;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final displayLabel = label + (isOptional ? ' (선택)' : '');

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.mainPaleBlue.withOpacity(0.25)
              : AppColors.subIvoryBeige,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPrimary
                ? AppColors.pointDustyNavy
                : AppColors.mainPaleBlue.withOpacity(0.8),
          ),
        ),
        child: Row(
          children: [
            Icon(
              value ? Icons.check_circle : Icons.radio_button_unchecked,
              color: value
                  ? AppColors.pointDustyNavy
                  : AppColors.pointDustyNavy.withOpacity(0.55),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                displayLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.pointDustyNavy,
                  fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: AppColors.pointDustyNavy),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.pointDustyNavy,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () {
            debugPrint('계정 만들기 클릭');
            // TODO: 여기 실제 회원가입 로직 연결
          },
          child: const Text(
            '계정 만들기',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.pointDustyNavy,
            side: const BorderSide(color: AppColors.pointDustyNavy),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
          child: const Text('이미 계정이 있나요? 로그인'),
        ),
        const SizedBox(height: 10),
        Text(
          '본인 인증 완료 후 안전하게 계좌를 연결할 수 있어요.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.pointDustyNavy.withOpacity(0.65),
          ),
        ),
      ],
    );
  }
}
