import 'package:flutter/material.dart';
import '../app_colors.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: Column(
        children: [
          _header(),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _mainChatArea()),
                  const SizedBox(width: 20),
                  Expanded(flex: 1, child: _rightPanel()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ====================
  // 상단 네비영역
  // ====================
  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            offset: Offset(0, 2),
            color: Colors.black12,
          )
        ],
      ),
      child: Row(
        children: [
          const Text(
            "FLO BANK",
            style: TextStyle(
              color: AppColors.pointDustyNavy,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const Spacer(),
          _navItem("외화예금"),
          _navItem("환전"),
          _navItem("외화송금"),
          _navItem("고객센터"),
        ],
      ),
    );
  }

  Widget _navItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.pointDustyNavy,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================
  // 메인 상담 패널
  // ============================
  Widget _mainChatArea() {
    return Column(
      children: [
        _heroBanner(),
        const SizedBox(height: 20),
        Expanded(child: _chatConsole()),
      ],
    );
  }

  // ============================
  // Hero 배너
  // ============================
  Widget _heroBanner() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.mainPaleBlue.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mainPaleBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "AI 외환 도우미",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.pointDustyNavy,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "무엇을 도와드릴까요?",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.pointDustyNavy,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "실시간 상담, 환전 절차 안내, 맞춤형 외환 전략까지\n하나의 화면에서 손쉽게 이용해보세요.",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.pointDustyNavy,
            ),
          ),
        ],
      ),
    );
  }

  // ============================
  // 채팅 콘솔 UI
  // ============================
  Widget _chatConsole() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.mainPaleBlue),
      ),
      child: Column(
        children: [
          const Text(
            "AI 상담 채팅",
            style: TextStyle(
              color: AppColors.pointDustyNavy,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),

          // 메시지 리스트
          Expanded(
            child: ListView(
              children: const [
                _ChatBubble(
                  isUser: false,
                  name: "AI 도우미",
                  time: "09:32",
                  message: "안녕하세요! 무엇을 도와드릴까요?",
                ),
                _ChatBubble(
                  isUser: true,
                  name: "나",
                  time: "09:33",
                  message: "해외 송금 우대 정보 알려줘!",
                ),
                _ChatBubble(
                  isUser: false,
                  name: "AI 도우미",
                  time: "09:33",
                  message: "해외송금 우대는 최대 90%까지 제공됩니다!",
                  suggestions: ["우대 신청", "자세히 보기"],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 입력창
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "질문을 입력하세요...",
                    filled: true,
                    fillColor: AppColors.mainPaleBlue.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.pointDustyNavy,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white),
              )
            ],
          )
        ],
      ),
    );
  }

  // ============================
  // 오른쪽 정보 패널
  // ============================
  Widget _rightPanel() {
    return Column(
      children: [
        _sideBox(
          title: "바로가기",
          children: [
            _sideButton(Icons.trending_up, "실시간 환율"),
            _sideButton(Icons.currency_exchange, "환전하기"),
          ],
        ),
        const SizedBox(height: 20),
        _sideBox(
          title: "자주 찾는 질문",
          children: [
            _faq("환전 신청 후 수령까지 걸리는 시간은?"),
            _faq("외화예금 자동이체는 어떻게 설정하나요?"),
            _faq("해외송금 한도 상향은 어디서 하나요?"),
          ],
        ),
        const SizedBox(height: 20),
        _sideBox(
          title: "상담 유의사항",
          children: const [
            Text(
              "AI 상담은 24시간 이용 가능하며 필요 시 상담원 연결됩니다.",
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            SizedBox(height: 8),
            Text(
              "개인정보 및 금융 비밀번호는 입력하지 마세요.",
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sideBox({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.mainPaleBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.pointDustyNavy,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _sideButton(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.mainPaleBlue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mainPaleBlue.withOpacity(0.8)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.pointDustyNavy),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.pointDustyNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _faq(String text) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.pointDustyNavy,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.pointDustyNavy),
          ],
        ),
        const Divider(),
      ],
    );
  }
}

// =========================================
// 채팅 버블 위젯
// =========================================
class _ChatBubble extends StatelessWidget {
  final bool isUser;
  final String name;
  final String time;
  final String message;
  final List<String>? suggestions;

  const _ChatBubble({
    required this.isUser,
    required this.name,
    required this.time,
    required this.message,
    this.suggestions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
      isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser)
          _avatar(Icons.smart_toy_outlined, Colors.white, AppColors.pointDustyNavy),

        if (!isUser) const SizedBox(width: 10),

        Flexible(
          child: Column(
            crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                "$name · $time",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isUser
                      ? AppColors.mainPaleBlue.withOpacity(0.25)
                      : AppColors.mainPaleBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.pointDustyNavy,
                    fontSize: 14,
                  ),
                ),
              ),
              if (suggestions != null) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: suggestions!
                      .map((s) => OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: AppColors.pointDustyNavy.withOpacity(0.7)),
                    ),
                    child: Text(
                      s,
                      style: const TextStyle(
                          color: AppColors.pointDustyNavy),
                    ),
                  ))
                      .toList(),
                )
              ],
            ],
          ),
        ),

        if (isUser) const SizedBox(width: 10),

        if (isUser)
          _avatar(Icons.person, AppColors.pointDustyNavy, Colors.white),
      ],
    );
  }

  Widget _avatar(IconData icon, Color bg, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border: Border.all(color: AppColors.pointDustyNavy),
      ),
      child: Icon(icon, color: iconColor),
    );
  }
}
