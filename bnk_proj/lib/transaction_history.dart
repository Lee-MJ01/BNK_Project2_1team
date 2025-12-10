import 'package:flutter/material.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("거래내역조회"),
        leading: const BackButton(color: const Color(0xFF152443)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _accountCard(),
          _actionButtons(),
          _filterBar(),
          Expanded(child: _historyList()),
        ],
      ),
    );
  }


  Widget _accountCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("자유저축예금", style: TextStyle(color: Colors.grey)),
          SizedBox(height: 6),
          Text("112-2188-1931-00",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "124,236원",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF344D85),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  //borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {},
              child: const Text("이체"),
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF344D85),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  //borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {},
              child: const Text("계좌관리"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          const Text("검색", style: TextStyle(color: Colors.grey)),
          const Spacer(),
          const Text("1개월 | 최신순 | 전체",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }


  Widget _historyList() {
    final List<Map<String, dynamic>> dummy = [
      {
        "date": "12.10",
        "title": "GS25 서면역점",
        "type": "체크카드",
        "amount": -1500,
        "balance": 124236,
      },
      {
        "date": "12.09",
        "title": "카페이떼",
        "type": "체크카드",
        "amount": -3500,
        "balance": 125736,
      },
      {
        "date": "12.09",
        "title": "카페이떼",
        "type": "체크카드",
        "amount": -12000,
        "balance": 129236,
      },
    ];

    return ListView.separated(
      itemCount: dummy.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final data = dummy[index];
        final isWithdraw = data["amount"] < 0;

        return ListTile(
          leading: Text(data["date"],
              style: const TextStyle(color: Colors.grey)),
          title: Text(
            data["title"],
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(data["type"]),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${data["amount"].toString().replaceAll("-", "-")}원",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isWithdraw ? Colors.black : Colors.blue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${data["balance"]}원",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }
}