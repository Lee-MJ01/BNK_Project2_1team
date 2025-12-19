import 'package:flutter/material.dart';
import '../../models/chatbot_msg.dart';
import '../../services/chatbot_service.dart';
import '../app_colors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {


  final TextEditingController _controller = TextEditingController();
  final ChatbotService _chatbotService =
  ChatbotService();
  final ScrollController _scrollController = ScrollController();


  final List<ChatMessage> _messages = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
        ChatMessage.bot("안녕하세요! 무엇을 도와드릴까요?")
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_controller.text.trim().isEmpty) return;

    final q = _controller.text;
    _controller.clear();

    setState(() {
      _messages.add(ChatMessage.user(q));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final res = await _chatbotService.ask(q);

      setState(() {
        _messages.add(ChatMessage.bot(res.answer));
      });

      _scrollToBottom();

    } catch (e) {
      setState(() {
        _messages.add(ChatMessage.bot("잠시 후 다시 시도해주세요."));
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,

      // --------------------------
      // 상단 AppBar
      // --------------------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: true,
        centerTitle: true,

        title: const Text(
          "AI 상담 도우미",
          style: TextStyle(
            color: AppColors.pointDustyNavy,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),

        iconTheme: const IconThemeData(
          color: AppColors.pointDustyNavy,
        ),
      ),

      // --------------------------
      // 본문
      // --------------------------
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _chatConsole(),
      ),
    );
  }

  // ============================
  // 채팅 콘솔 UI (유일한 카드)
  // ============================

  String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }



  Widget _chatConsole() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 6),
            color: Colors.black.withOpacity(0.12),
          )
        ],
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

          // --------------------------
          // 메시지들
          // --------------------------
          SizedBox(
            height: 420,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, i) {
                if (i < _messages.length) {
                  final msg = _messages[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ChatBubble(
                      isUser: msg.isUser,
                      name: msg.isUser ? "나" : "AI 도우미",
                      time: _formatTime(msg.createdAt),
                      message: msg.message,
                    ),
                  );
                }

                // 마지막: 로딩 말풍선
                return const Padding(
                  padding: EdgeInsets.only(bottom: 14),
                  child: _ChatBubble(
                    isUser: false,
                    name: "AI 도우미",
                    time: "",
                    message: "입력 중...",
                  ),
                );
              },
            ),
          ),



          const SizedBox(height: 20),

          // --------------------------
          // 입력창 UI
          // --------------------------
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _send(),
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
              GestureDetector(
                onTap: _isLoading ? null : _send,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.pointDustyNavy,
                    shape: BoxShape.circle,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.send, color: Colors.white),
                ),
              )

            ],
          )
        ],
      ),
    );
  }
}

// =========================================
// 채팅 버블 UI
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

        // 🔹 상담원 아바타 (이미지)
        if (!isUser) _botAvatar(),
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
                    fontSize: 14,
                    color: AppColors.pointDustyNavy,
                  ),
                ),
              ),

              if (suggestions != null) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: suggestions!
                      .map(
                        (txt) => OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.pointDustyNavy.withOpacity(0.8),
                        ),
                      ),
                      child: Text(
                        txt,
                        style: const TextStyle(color: AppColors.pointDustyNavy),
                      ),
                    ),
                  )
                      .toList(),
                ),
              ],
            ],
          ),
        ),

        if (isUser) const SizedBox(width: 10),

        // 사용자 아바타
        if (isUser) _userAvatar(),
      ],
    );
  }

  // 상담원 아바타
  Widget _botAvatar() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.pointDustyNavy),
        image: const DecorationImage(
          image: AssetImage("images/chatboticon.png"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // 사용자 아바타
  Widget _userAvatar() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.pointDustyNavy,
      ),
      child: const Icon(Icons.person, color: Colors.white),
    );
  }
}
