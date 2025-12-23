import 'dart:async';

import 'package:flutter/material.dart';
import '../../services/search_api.dart';
import 'package:test_main/screens/deposit/view.dart'; // DepositViewScreen 있는 파일

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  bool _isSearching = false;
  String _query = "";

  // ES 검색 결과
  Map<String, dynamic>? _searchResult;
  final Map<String, Map<String, dynamic>> _tabResults = {};
  final Map<String, bool> _tabLoading = {};

  // 최근 검색어
  List<dynamic> _recentSearches = [];

  // 자동완성
  Timer? _debounce;
  bool _isSuggesting = false;
  List<String> _suggestions = [];
  String _lastAutoQuery = "";

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 6, vsync: this);

    // ✅ 탭 클릭 시 해당 탭(type) 상세검색 호출
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      if (!_isSearching) return;

      final String? type = switch (_tabController.index) {
        1 => "product",
        2 => "faq",
        3 => "docs",
        4 => "notice",
        5 => "event",
        _ => null,
      };

      if (type == null) return;

      if (_tabLoading[type] == true) return;
      if (_tabResults.containsKey(type)) return;

      _fetchTab(type);
    });

    _loadRecentSearches();
  }

  // ---------------------------
  // 자동완성(추천 검색어)
  // ---------------------------
  void _onKeywordChanged(String value) {
    final q = value.trim();

    // 입력이 비면 자동완성/검색 모두 정리
    if (q.isEmpty) {
      _debounce?.cancel();
      setState(() {
        _isSearching = false;
        _isSuggesting = false;
        _suggestions = [];
        _lastAutoQuery = "";
        _query = "";
        _searchResult = null;
        _tabResults.clear();
        _tabLoading.clear();
      });
      return;
    }

    // 타이핑 중엔 검색결과 화면보다 자동완성을 우선 노출
    setState(() {
      _isSearching = false;
    });

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      if (_lastAutoQuery == q) return;

      setState(() {
        _isSuggesting = true;
        _lastAutoQuery = q;
      });

      try {
        // ✅ SearchApi.autoComplete(String) 이 있어야 함
        final list = await SearchApi.autoComplete(q);
        if (!mounted) return;

        setState(() {
          _suggestions = list;
          _isSuggesting = false;
        });
      } catch (e) {
        debugPrint("❌ autocomplete error = $e");
        if (!mounted) return;
        setState(() {
          _suggestions = [];
          _isSuggesting = false;
        });
      }
    });
  }

  void _selectSuggestion(String keyword) {
    _searchController.text = keyword;
    _searchController.selection =
        TextSelection.fromPosition(TextPosition(offset: keyword.length));

    setState(() {
      _suggestions = [];
      _isSuggesting = false;
    });

    _doSearch(keyword);
  }

  Widget _buildSuggestionView() {
    if (_isSuggesting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_suggestions.isEmpty) {
      return const Center(child: Text("추천 검색어가 없습니다."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final text = _suggestions[index];
        return ListTile(
          title: Text(text),
          onTap: () => _selectSuggestion(text),
        );
      },
    );
  }

  // ---------------------------
  // 기존 검색 기능
  // ---------------------------
  Future<void> _fetchTab(String type) async {
    setState(() => _tabLoading[type] = true);

    try {
      final res = await SearchApi.tabSearch(keyword: _query, type: type, page: 0);
      setState(() => _tabResults[type] = res);
    } catch (e) {
      debugPrint("❌ tab search error ($type) = $e");
      setState(() => _tabResults[type] = {});
    } finally {
      setState(() => _tabLoading[type] = false);
    }
  }

  String? _extractDpstIdFromUrl(dynamic urlValue) {
    final url = urlValue?.toString();
    if (url == null || url.isEmpty) return null;

    // 예: "/deposit/view?dpstId=DPST0001"
    final uri = Uri.tryParse("https://dummy.com$url");
    return uri?.queryParameters["dpstId"];
  }

  Future<void> _loadRecentSearches() async {
    final data = await SearchApi.recentKeywords();
    setState(() => _recentSearches = data);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _doSearch(String text) async {
    debugPrint("✅ _doSearch called: [$text]");

    final keyword = text.trim();
    if (keyword.isEmpty) return;

    setState(() {
      _query = keyword;
      _isSearching = true;

      // ✅ 검색 시작할 때 자동완성 정리
      _isSuggesting = false;
      _suggestions = [];

      _searchResult = null;
      _tabResults.clear();
      _tabLoading.clear();
    });

    _tabController.animateTo(0);

    try {
      final result = await SearchApi.integratedSearch(keyword);
      debugPrint("🔥 search result keys = ${result.keys}");
      debugPrint("🔥 search result = $result");
      if (!mounted) return;
      setState(() => _searchResult = result);
    } catch (e) {
      debugPrint("❌ search error = $e");
      if (!mounted) return;
      setState(() => _searchResult = {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasTyping = _searchController.text.trim().isNotEmpty;
    final showSuggest =
        !_isSearching && hasTyping && (_isSuggesting || _suggestions.isNotEmpty);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: showSuggest
          ? _buildSuggestionView()
          : (_isSearching ? _buildSearchResultView() : _buildRecentSearchView()),
    );
  }

  // ================= APP BAR =================
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          // 자동완성 화면이면 먼저 자동완성/입력만 정리
          if (!_isSearching && _searchController.text.trim().isNotEmpty) {
            setState(() {
              _searchController.clear();
              _isSuggesting = false;
              _suggestions = [];
              _lastAutoQuery = "";
            });
            return;
          }

          if (_isSearching) {
            setState(() {
              _isSearching = false;
              _searchController.clear();
              _isSuggesting = false;
              _suggestions = [];
              _lastAutoQuery = "";
            });
          } else {
            Navigator.pop(context);
          }
        },
      ),
      title: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: "검색어를 입력해주세요",
          border: InputBorder.none,
        ),
        onChanged: _onKeywordChanged, // ✅ 자동완성 연결
        onSubmitted: _doSearch,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Color(0xFF3E5D9C)),
          onPressed: () => _doSearch(_searchController.text),
        ),
      ],
      bottom: _isSearching
          ? TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: const Color(0xFF3E5D9C),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFF3E5D9C),
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
    );
  }

  // ================= 최근 검색 =================
  Widget _buildRecentSearchView() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _recentSearches.length,
      itemBuilder: (context, index) {
        final item = _recentSearches[index];
        return ListTile(
          title: Text(item["keyword"]),
          subtitle: Text(item["createdAt"].substring(0, 10)),
          onTap: () {
            _searchController.text = item["keyword"];
            _searchController.selection = TextSelection.fromPosition(
              TextPosition(offset: _searchController.text.length),
            );
            _doSearch(item["keyword"]);
          },
        );
      },
    );
  }

  // ================= 검색 결과 =================
  Widget _buildSearchResultView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildUnifiedSearchTab(),
        _buildListTab("product"),
        _buildListTab("faq"),
        _buildListTab("docs"),
        _buildListTab("notice"),
        _buildListTab("event"),
      ],
    );
  }

  Widget _buildUnifiedSearchTab() {
    if (_searchResult == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final total = (_searchResult?["totalCount"] as num?)?.toInt() ?? 0;
    final sections = _searchResult!["sections"] ?? {};

    final products = (sections["product"]?["results"] as List?) ?? [];
    final faqs = (sections["faq"]?["results"] as List?) ?? [];
    final docs = (sections["docs"]?["results"] as List?) ?? [];
    final notices = (sections["notice"]?["results"] as List?) ?? [];
    final events = (sections["event"]?["results"] as List?) ?? [];

    int sectionTotal(String key, List list) =>
        ((sections[key]?["totalCount"] as num?)?.toInt()) ?? list.length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 16, color: Colors.black),
            children: [
              TextSpan(
                text: "‘$_query’",
                style: const TextStyle(
                  color: Color(0xFF3E5D9C),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const TextSpan(text: "에 대한 검색결과가 총 "),
              TextSpan(
                text: "${total}건",
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const TextSpan(text: " 검색되었습니다."),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (products.isNotEmpty) ...[
          _section("상품", sectionTotal("product", products)),
          ...products.take(4).map(
                (p) => _item(
              p["title"] ?? "",
              p["summary"] ?? "",
              onTap: () {
                final dpstId = _extractDpstIdFromUrl(p["url"]);
                if (dpstId == null || dpstId.isEmpty) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DepositViewScreen(dpstId: dpstId),
                  ),
                );
              },
            ),
          ),
        ],

        if (faqs.isNotEmpty) ...[
          _section("FAQ", sectionTotal("faq", faqs)),
          ...faqs.take(4).map((f) => _item(f["title"] ?? "", f["summary"] ?? "")),
        ],

        if (docs.isNotEmpty) ...[
          _section("약관", sectionTotal("docs", docs)),
          ...docs.take(4).map((t) => _item(t["title"] ?? "", t["summary"] ?? "")),
        ],

        if (notices.isNotEmpty) ...[
          _section("공지사항", sectionTotal("notice", notices)),
          ...notices.take(4).map((n) => _item(n["title"] ?? "", n["summary"] ?? "")),
        ],

        if (events.isNotEmpty) ...[
          _section("이벤트", sectionTotal("event", events)),
          ...events.take(4).map((e) => _item(e["title"] ?? "", e["summary"] ?? "")),
        ],
      ],
    );
  }

  Widget _buildListTab(String key) {
    if (_searchResult == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_query.trim().isEmpty) {
      return const Center(child: Text("검색어를 입력해주세요."));
    }

    final bool isLoading = _tabLoading[key] == true;
    final Map<String, dynamic>? tabRes = _tabResults[key];

    if (tabRes == null && !isLoading) {
      Future.microtask(() => _fetchTab(key));
      return const Center(child: CircularProgressIndicator());
    }

    if (isLoading && tabRes == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final sections = (tabRes?["sections"] as Map?) ?? {};
    final section = (sections[key] as Map?) ?? {};
    final List list = (section["results"] as List?) ?? [];
    final int total = (section["totalCount"] as num?)?.toInt() ?? 0;

    if (list.isEmpty) {
      return const Center(child: Text("검색 결과가 없습니다."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: list.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black),
                children: [
                  TextSpan(
                    text: "‘$_query’ ",
                    style: const TextStyle(
                      color: Color(0xFF3E5D9C),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: "검색 결과 총 "),
                  TextSpan(
                    text: "$total건",
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final item = list[index - 1];
        final bool isLast = (index - 1) == list.length - 1;

        VoidCallback? onTap;

        if (key == "product") {
          final dpstId = _extractDpstIdFromUrl(item["url"]);
          if (dpstId != null && dpstId.isNotEmpty) {
            onTap = () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DepositViewScreen(dpstId: dpstId),
                ),
              );
            };
          }
        }

        return _item(
          item["title"] ?? "",
          item["summary"] ?? "",
          showDivider: !isLast,
          onTap: onTap,
        );
      },
    );
  }

  Widget _section(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        "$title ($count)",
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF3E5D9C),
        ),
      ),
    );
  }

  Widget _item(
      String title,
      String content, {
        bool showDivider = true,
        VoidCallback? onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(
            bottom: BorderSide(color: Color(0xFFE6E6E6), width: 1),
          )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E5D9C),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
