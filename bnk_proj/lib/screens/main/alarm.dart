// 파일 위치: lib/screens/notification/alaram.dart
import 'package:flutter/material.dart';
import 'alarm_view.dart';


class AlaramScreen extends StatelessWidget {
  const AlaramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB), // 배경색 통일
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "알림함",
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("편집", style: TextStyle(color: Colors.grey)),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ---------------- [섹션 1] 오늘 알림 ----------------
          const Text(
            "오늘",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 10),

          // 1. 입출금 알림 (파란색)
          _NotificationTile(
            icon: Icons.swap_horiz,
            iconColor: const Color(0xFF3E5D9C), // FLOBANK 남색
            title: "입출금",
            message: "홍길동님에게 10,000원이 입금되었습니다.",
            time: "방금 전",
            isNew: true, onTap: () {  },
          ),

          // 2. 외화예금 가입 (상세 이동 있음)
          _NotificationTile(
            icon: Icons.savings,
            iconColor: Colors.orange,
            title: "외화예금 가입",
            message: "FLOBANK 외화정기예금 가입이 완료되었습니다.",
            time: "1시간 전",
            isNew: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AlarmViewPage( // ✅ AlarmViewPage 사용
                    title: "외화예금 가입 완료",
                    date: "2023.10.25 14:30",
                    icon: Icons.savings,
                    iconColor: Colors.orange,
                    content: "고객님께서 신청하신 'FLOBANK 외화정기예금' 가입이 정상적으로 완료되었습니다.\n\n"
                        "■ 상품명 : FLOBANK 외화정기예금\n"
                        "■ 가입금액 : USD 100.00\n"
                        "■ 적용금리 : 연 4.5%\n"
                        "■ 만기일 : 2024.10.25\n\n"
                        "자세한 내용은 마이페이지 또는 거래내역에서 확인하실 수 있습니다.",
                  ),
                ),
              );
            },
          ),


          const SizedBox(height: 24),

          // ---------------- [섹션 2] 이전 알림 ----------------
          const Text(
            "이전 알림",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 10),

          // 3. 만기 안내 (상세 이동 있음)
          _NotificationTile(
            icon: Icons.event_available,
            iconColor: Colors.green,
            title: "만기 안내",
            message: "가입하신 '외화보통예금'의 만기가 도래했습니다.",
            time: "어제",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AlarmViewPage(
                    title: "예금 만기 안내",
                    date: "2023.10.24 09:00",
                    icon: Icons.event_available,
                    iconColor: Colors.green,
                    content: "가입하신 '외화보통예금' 상품의 만기일이 도래하였습니다.\n\n"
                        "만기 해지 시 약정된 이자가 지급되며, 재예치 시 우대 금리를 적용받으실 수 있습니다.\n\n"
                        "가까운 영업점 또는 앱 내 상품 해지 메뉴를 이용해 주세요.\n\n"
                        "※ 만기 후에는 약정 금리가 아닌 만기 후 이자율이 적용됩니다.",
                  ),
                ),
              );
            },
          ),

          // 4. 이벤트 (상세 이동 있음)
          _NotificationTile(
            icon: Icons.campaign,
            iconColor: Colors.redAccent,
            title: "이벤트",
            message: "🎁 10월 출석체크 보상 포인트(50P)가 적립되었습니다.",
            time: "2023.10.20",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AlarmViewPage(
                    title: "포인트 적립 안내",
                    date: "2023.10.20 18:00",
                    icon: Icons.campaign,
                    iconColor: Colors.redAccent,
                    content: "축하합니다! 🎉\n"
                        "10월 출석체크 이벤트를 달성하여 50포인트가 적립되었습니다.\n\n"
                        "적립된 포인트는 현금처럼 사용하거나, 수수료 결제 시 사용하실 수 있습니다.\n\n"
                        "앞으로도 FLOBANK와 함께 즐거운 금융 생활 되세요!",
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ✅ 알림 리스트 아이템 디자인 (카드 형태)
class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String time;
  final bool isNew;
  final VoidCallback? onTap;

  const _NotificationTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.time,
    this.isNew = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap, // 클릭 기능 연결
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, // 위쪽 정렬
            children: [
              // 1. 아이콘
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),

              // 2. 텍스트 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        // 시간 표시 (화살표가 없을 때만 끝에 붙음, 있으면 화살표 옆으로 밀림)
                        if (onTap == null)
                          Text(
                            time,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),

                    // 날짜/시간 (화살표가 있을 때는 아래쪽에 배치하는 게 디자인상 깔끔함)
                    if (onTap != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ]
                  ],
                ),
              ),

              // 3. New 뱃지 (옵션)
              if (isNew)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

              // 4. ✅ [추가됨] 화살표 아이콘 (onTap이 있을 때만 표시)
              if (onTap != null)
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 2), // 위치 미세조정
                  child: const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
    );
  }
}