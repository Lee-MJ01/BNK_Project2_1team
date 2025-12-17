import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// ---------------------------------------------------------------------------
// 1. 데이터 모델
// ---------------------------------------------------------------------------
class ExchangeRiskModel {
  final String currency;     // 통화 코드
  final String targetDate;   // 조회 날짜
  final String rateDate;     // 실제 환율 기준일
  final double currentRate;  // 현재 환율
  final double riskPercent;  // 변동성 (%)
  final String expectedGap;  // 예상 변동폭 (원)
  final String weatherIcon;  // SUNNY, CLOUDY, STORM
  final String weatherText;  // 맑음, 구름조금, 폭풍우
  final String message;      // 사용자 안내 메시지
  final String status;       // success / error

  ExchangeRiskModel({
    required this.currency,
    required this.targetDate,
    required this.rateDate,
    required this.currentRate,
    required this.riskPercent,
    required this.expectedGap,
    required this.weatherIcon,
    required this.weatherText,
    required this.message,
    required this.status,
  });

  factory ExchangeRiskModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRiskModel(
      currency: json['currency'] ?? '',
      targetDate: json['target_date'] ?? '',
      rateDate: json['rate_date'] ?? '',
      currentRate: (json['current_rate'] ?? 0.0).toDouble(),
      riskPercent: (json['risk_percent'] ?? 0.0).toDouble(),
      expectedGap: json['expected_gap'].toString(),
      weatherIcon: json['weather_icon'] ?? 'SUNNY',
      weatherText: json['weather_text'] ?? '-',
      message: json['message'] ?? '',
      status: json['status'] ?? 'error',
    );
  }
}

// ---------------------------------------------------------------------------
// 2. 메인 화면
// ---------------------------------------------------------------------------
class ExchangeRiskScreen extends StatefulWidget {
  const ExchangeRiskScreen({Key? key}) : super(key: key);

  @override
  State<ExchangeRiskScreen> createState() => _ExchangeRiskScreenState();
}

class _ExchangeRiskScreenState extends State<ExchangeRiskScreen> {
  DateTime _selectedDate = DateTime.now();
  List<ExchangeRiskModel> _riskList = [];
  bool _isLoading = false;

  // ✅ [수정됨] 조회할 통화 목록 (7개)
  final List<String> _targetCurrencies = [
    'USD', // 미국
    'JPY', // 일본
    'EUR', // 유럽
    'CNY', // 중국
    'GBP', // 영국
    'CHF', // 스위스
    'AUD', // 호주
  ];

  @override
  void initState() {
    super.initState();
    _fetchRiskData(_selectedDate);
  }

  // ✅ [수정됨] 통화별 한글 이름 매핑
  String _getCurrencyDisplayName(String code) {
    switch (code) {
      case 'USD': return '미국 달러 (USD)';
      case 'JPY': return '일본 엔 (JPY 100)';
      case 'EUR': return '유럽 유로 (EUR)';
      case 'CNY': return '중국 위안 (CNY)';
      case 'GBP': return '영국 파운드 (GBP)';
      case 'CHF': return '스위스 프랑 (CHF)';
      case 'AUD': return '호주 달러 (AUD)';
      default: return code;
    }
  }

  // -------------------------------------------------------------------------
  // [통신] 백엔드 API 호출 (여러 통화 반복 조회)
  // -------------------------------------------------------------------------
  Future<void> _fetchRiskData(DateTime date) async {
    setState(() {
      _isLoading = true;
      _riskList.clear();
    });

    String dateStr = DateFormat('yyyyMMdd').format(date);

    // ⚠️ 실제 백엔드 서버 주소 확인 (localhost vs IP)
    final String baseUrl = "http://34.64.124.33:8080/backend/api/risk";

    List<ExchangeRiskModel> tempResult = [];

    // 리스트에 있는 모든 통화를 하나씩 요청
    for (String currency in _targetCurrencies) {
      try {
        final url = Uri.parse('$baseUrl/$currency?date=$dateStr');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));

          if (body['status'] == 'success') {
            tempResult.add(ExchangeRiskModel.fromJson(body));
          }
        }
      } catch (e) {
        print("Error fetching $currency: $e");
        // 에러 발생 시 해당 통화는 건너뛰고 계속 진행
      }
    }

    setState(() {
      _riskList = tempResult;
      _isLoading = false;
    });
  }

  // -------------------------------------------------------------------------
  // [UI 헬퍼] 디자인 요소
  // -------------------------------------------------------------------------
  Color _getCardColor(String weatherIcon) {
    switch (weatherIcon) {
      case 'SUNNY': return Colors.green.shade50;
      case 'CLOUDY': return Colors.orange.shade50;
      case 'STORM': return Colors.red.shade50;
      default: return Colors.grey.shade50;
    }
  }

  Color _getTextColor(String weatherIcon) {
    switch (weatherIcon) {
      case 'SUNNY': return Colors.green.shade800;
      case 'CLOUDY': return Colors.deepOrange.shade800;
      case 'STORM': return Colors.red.shade900;
      default: return Colors.black87;
    }
  }

  String _getWeatherEmoji(String weatherIcon) {
    switch (weatherIcon) {
      case 'SUNNY': return "☀️";
      case 'CLOUDY': return "☁️";
      case 'STORM': return "⛈️";
      default: return "❓";
    }
  }

  // -------------------------------------------------------------------------
  // 날짜 선택기
  // -------------------------------------------------------------------------
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blueAccent),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _fetchRiskData(picked);
    }
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("☁️ 환율 기상청",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. 날짜 선택 영역
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(_selectedDate),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),

          // 2. 결과 리스트
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _riskList.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text(
                    "데이터가 없습니다.\n(주말이나 공휴일은 환율 정보가 없을 수 있어요)",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _riskList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                return _buildWeatherCard(_riskList[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // 카드 디자인
  Widget _buildWeatherCard(ExchangeRiskModel item) {
    Color cardColor = _getCardColor(item.weatherIcon);
    Color themeColor = _getTextColor(item.weatherIcon);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // [상단] 아이콘 + 나라 이름
            Row(
              children: [
                Text(
                  _getWeatherEmoji(item.weatherIcon),
                  style: const TextStyle(fontSize: 36),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getCurrencyDisplayName(item.currency),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    Text(
                      item.weatherText,
                      style: TextStyle(fontSize: 14, color: themeColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Data Std.", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text(
                      _formatDate(item.rateDate),
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                )
              ],
            ),

            const Divider(height: 30, thickness: 1),

            // [중간] 환율 & 변동폭
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("현재 기준 환율", style: TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text(
                      "${NumberFormat('#,###.0').format(item.currentRate)}원",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: themeColor),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: themeColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text("예상 변동", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      const SizedBox(height: 2),
                      Text(
                        "±${item.expectedGap}원",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: themeColor),
                      ),
                    ],
                  ),
                )
              ],
            ),

            const SizedBox(height: 20),

            // [하단] 메시지 박스
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: themeColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.message,
                      style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 날짜 포맷 (20240827 -> 24.08.27)
  String _formatDate(String yyyymmdd) {
    if (yyyymmdd.length != 8) return yyyymmdd;
    return "${yyyymmdd.substring(2, 4)}.${yyyymmdd.substring(4, 6)}.${yyyymmdd.substring(6, 8)}";
  }
}