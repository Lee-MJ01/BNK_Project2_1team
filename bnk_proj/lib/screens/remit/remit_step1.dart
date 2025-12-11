import 'package:flutter/material.dart';
import 'remit_amount.dart';

class RemitStep1Page extends StatefulWidget {
  const RemitStep1Page({super.key});

  @override
  State<RemitStep1Page> createState() => _RemitStep1PageState();
}

class _RemitStep1PageState extends State<RemitStep1Page>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }


  // 화면 이동 함수 (중복 코드를 줄이기 위해 만듦)
  void _goToAmountPage(String name, String accountInfo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RemitAmountPage(
          name: name,
          account: accountInfo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 10),
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAccountNumberTab(),
                  _buildContactTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- 상단 헤더 ----------------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("이체", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text("닫기", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          )
        ],
      ),
    );
  }

  // ---------------- 검색창 ----------------
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search, color: Colors.black54),
            const SizedBox(width: 8),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "계좌번호 또는 전화번호 입력",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  // ---------------- 탭 메뉴 ----------------
  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      labelColor: Colors.black,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Colors.black,
      labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      tabs: const [
        Tab(text: "계좌번호"),
        Tab(text: "연락처"),
      ],
    );
  }

  // ---------------- 계좌번호 탭 내용 ----------------
  Widget _buildAccountNumberTab() {
    return ListView(
      padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
      children: [
        const Text("내 계좌", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _accountTile("계좌1", "카카오뱅크 3333-01-000000"),
        _accountTile("계좌2", "카카오뱅크 7777-02-111111"),

        const SizedBox(height: 20),
        const Text("최근 이체", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _recentTile("김철수", "카카오뱅크 3333-10-123456"),
        _recentTile("이영희", "국민은행 123401-04-123456"),
        _recentTile("박민수", "신한은행 110-123-456789"),
      ],
    );
  }

  // ---------------- 연락처 탭 내용 ----------------
  Widget _buildContactTab() {
    return ListView(
      padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10, bottom: 10),
          child: Text("친구 목록", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),

        // 여기에 오류가 났던 이유는 아래 _contactTile 함수가 없어서였습니다.
        _contactTile("권지용", "010-1234-3456"),
        _contactTile("이지은", "010-9876-5432"),
        _contactTile("유재석", "010-5555-4444"),
        _contactTile("박명수", "010-1111-2222"),
        _contactTile("김태희", "010-7777-8888"),
        _contactTile("손흥민", "010-9999-0000"),
      ],
    );
  }

  // ---------------- 공통: 계좌 타일 ----------------
  Widget _accountTile(String name, String account) {
    return ListTile(
      leading: Transform.translate(
        offset: const Offset(-8, 0),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          // 내부는 정중앙 유지
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset(
              "images/icon1.png",
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      title: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      subtitle: Text(account, style: TextStyle(color: Colors.grey[600])),
      onTap: () {
        _goToAmountPage(name, account);
      },
    );
  }

  // ---------------- 공통: 최근 이체 타일 ----------------
  Widget _recentTile(String name, String account) {
    return ListTile(
      leading: Transform.translate(
        offset: const Offset(-8, 0),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset(
              "images/icon1.png",
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      title: Text(name, style: const TextStyle(fontSize: 16)),
      subtitle: Text(account),
      trailing: const Icon(Icons.star, color: Colors.amber),
      onTap: () {
        _goToAmountPage(name, account);
      },
    );
  }


  // ---------------- 연락처 타일 (보내기 버튼 클릭 시 이동) ----------------
  Widget _contactTile(String name, String phone) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        child: const Icon(Icons.person, color: Colors.white),
      ),
      title: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      subtitle: Text(phone, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
      trailing: GestureDetector(
        onTap: () {
          _goToAmountPage(name, phone);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6FB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            "보내기",
            style: TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}