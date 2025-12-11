import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  // ✅ 검색 상태 관리 (false: 최근 검색어, true: 검색 결과)
  bool _isSearching = false;
  String _query = "";

  // 탭 컨트롤러 (통합검색, 상품, FAQ, 약관, 공지사항, 이벤트)
  late TabController _tabController;

  // 최근 검색어 데이터
  List<String> _recentSearches = ["엔화 환전", "적금 금리", "오사카 여행", "달러 환율"];

  @override
  void initState() {
    super.initState();
    // 탭 6개 초기화
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // 검색어 삭제
  void _removeSearchTerm(String term) {
    setState(() => _recentSearches.remove(term));
  }

  // 전체 삭제
  void _clearAll() {
    setState(() => _recentSearches.clear());
  }

  // 검색 실행
  void _doSearch(String text) {
    if (text.isEmpty) return;
    setState(() {
      _query = text;
      _isSearching = true; // 결과 화면으로 전환
      // 최근 검색어에 추가 (중복 제거)
      if (!_recentSearches.contains(text)) {
        _recentSearches.insert(0, text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // 검색 결과 화면이면 최근 검색어 화면으로 돌아가기
            if (_isSearching) {
              setState(() {
                _isSearching = false;
                _searchController.clear();
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search, // 키보드 엔터 아이콘 변경
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "검색어를 입력해주세요",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(color: Colors.black, fontSize: 16),
          onSubmitted: _doSearch, // 엔터 누르면 검색 실행
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF3E5D9C)),
            onPressed: () => _doSearch(_searchController.text),
          ),
        ],
        // ✅ 검색 결과 상태일 때만 탭바 표시
        bottom: _isSearching
            ? TabBar(
          controller: _tabController,
          isScrollable: true, // 탭이 많으므로 스크롤 가능하게
          labelColor: const Color(0xFF3E5D9C),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF3E5D9C),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "통합검색"),
            Tab(text: "상품"),
            Tab(text: "FAQ"),
            Tab(text: "약관"),
            Tab(text: "공지사항"),
            Tab(text: "이벤트"),
          ],
        )
            : null,
      ),

      // ✅ 상태에 따라 다른 화면 보여주기
      body: _isSearching ? _buildSearchResultView() : _buildRecentSearchView(),
    );
  }

  // ---------------- [1] 최근 검색어 화면 ----------------
  Widget _buildRecentSearchView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "최근 검색어",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              if (_recentSearches.isNotEmpty)
                GestureDetector(
                  onTap: _clearAll,
                  child: Text("전체삭제", style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ),
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
            child: _recentSearches.isEmpty
                ? Center(child: Text("최근 검색 내역이 없습니다.", style: TextStyle(color: Colors.grey[400])))
                : SingleChildScrollView(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _recentSearches.map((term) => _buildSearchChip(term)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchChip(String term) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              _searchController.text = term;
              _doSearch(term);
            },
            child: Text(term, style: const TextStyle(color: Colors.black87, fontSize: 14)),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _removeSearchTerm(term),
            child: const Icon(Icons.close, size: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ---------------- [2] 검색 결과 화면 (탭뷰) ----------------
  Widget _buildSearchResultView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildUnifiedSearchTab(), // 통합검색
        _buildSimpleListTab("상품 검색 결과"),
        _buildSimpleListTab("FAQ 검색 결과"),
        _buildSimpleListTab("약관 검색 결과"),
        _buildSimpleListTab("공지사항 검색 결과"),
        _buildSimpleListTab("이벤트 검색 결과"),
      ],
    );
  }

  // ---- 통합검색 탭 (모든 결과를 모아서 보여줌) ----
  Widget _buildUnifiedSearchTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 검색 결과 문구
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 15),
              children: [
                TextSpan(
                  text: '"$_query"',
                  style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: "에 대한 검색 결과가 총 "),
                const TextSpan(text: "29건", style: TextStyle(fontWeight: FontWeight.bold)),
                const TextSpan(text: " 검색되었습니다."),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),

          // 1. 상품 섹션 (7)
          _buildSectionHeader("상품", 7),
          _buildProductItem("FLOBANK 외화정기예금", "여유자금을 일정기간 정해 예치하는 외화 정기예금"),
          _buildProductItem("FLOBANK 외화보통예금", "단기자금 운용에 적합한 외화 자유적립식 예금"),
          _buildProductItem("FLOBANK 외화슈퍼플러스 예금", "금리·환율·외환수수료 우대를 제공하는 자유적립식 외화 적금"),
          _buildProductItem("FLOBANK 더 와이드 외화적금", "금리·환율·외환수수료 우대를 제공하는 자유적립식 외화 적금"),
          const SizedBox(height: 20),

          // 2. FAQ 섹션 (5)
          _buildSectionHeader("FAQ", 5),
          _buildFaqItem("외화예금은 어떻게 개설하나요?", "인터넷뱅킹 또는 가까운 지점 방문을 통해 외화예금을 개설하실 수 있습니다."),
          _buildFaqItem("외화예금 이자는 어떻게 지급되나요?", "이자는 예금 통화로 지급되며, 일부 상품은 월 단위, 일부는 만기 시 지급됩니다."),
          const SizedBox(height: 20),

          // 3. 약관 섹션 (12)
          _buildSectionHeader("약관", 12),
          _buildTermsItem("외화예금거래기본약관 (v3)", "이 약관은 예금주와 FLOBANK(이하 '은행'이라 한다)과의 외화예금거래에 적용됩니다."),
          _buildTermsItem("해외송금 약관 (v2)", "해외송금 서비스 이용 시 적용되는 기본 약관입니다."),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // -- 섹션 헤더 (제목 + 더보기) --
  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title ($count)", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E5D9C))),
          const Text("더보기", style: TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  // -- 상품 아이템 --
  Widget _buildProductItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF3E5D9C))),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        ],
      ),
    );
  }

  // -- FAQ 아이템 --
  Widget _buildFaqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Q. $question", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF3E5D9C))),
          const SizedBox(height: 4),
          Text(answer, style: const TextStyle(fontSize: 13, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // -- 약관 아이템 --
  Widget _buildTermsItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF3E5D9C))),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // -- 기타 탭용 임시 화면 --
  Widget _buildSimpleListTab(String title) {
    return Center(child: Text(title));
  }
}