import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// ---------------------------------------------------------------------------
// 1. 데이터 모델 (Spring Boot의 DTO와 1:1 매칭)
// ---------------------------------------------------------------------------
class ExchangeRiskModel {
  final String volStdDy;        // 기준일자
  final String volCurrency;     // 통화
  final double volCurrentVal;   // 현재 위험도
  final double volForecastVal;  // 예측 위험도
  final String weatherIcon;     // ☀️, ☁️, ⛈️ (백엔드에서 줌)
  final String riskStatus;      // 안전, 주의, 위험 (백엔드에서 줌)
  final String predictionComment; // "내일은..." (백엔드에서 줌)

  ExchangeRiskModel({
    required this.volStdDy,
    required this.volCurrency,
    required this.volCurrentVal,
    required this.volForecastVal,
    required this.weatherIcon,
    required this.riskStatus,
    required this.predictionComment,
  });

  // JSON -> Dart 객체 변환
  factory ExchangeRiskModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRiskModel(
      volStdDy: json['volStdDy'] ?? '',
      volCurrency: json['volCurrency'] ?? '',
      volCurrentVal: (json['volCurrentVal'] ?? 0.0).toDouble(),
      volForecastVal: (json['volForecastVal'] ?? 0.0).toDouble(),
      weatherIcon: json['weatherIcon'] ?? '❓',
      riskStatus: json['riskStatus'] ?? '-',
      predictionComment: json['predictionComment'] ?? '',
    );
  }
}

// ---------------------------------------------------------------------------
// 2. 메인 화면 위젯
// ---------------------------------------------------------------------------
class ExchangeRiskScreen extends StatefulWidget {
  const ExchangeRiskScreen({Key? key}) : super(key: key);

  @override
  State<ExchangeRiskScreen> createState() => _ExchangeRiskScreenState();
}

class _ExchangeRiskScreenState extends State<ExchangeRiskScreen> {
  DateTime _selectedDate = DateTime.now(); // 기본값: 오늘
  List<ExchangeRiskModel> _riskList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 화면 시작 시 데이터 로드
    _fetchRiskData(_selectedDate);
  }

  // -------------------------------------------------------------------------
  // [통신] 백엔드(Spring Boot) API 호출
  // -------------------------------------------------------------------------
  Future<void> _fetchRiskData(DateTime date) async {
    setState(() => _isLoading = true);

    String dateStr = DateFormat('yyyyMMdd').format(date);

    // ⚠️ 주의: 에뮬레이터는 10.0.2.2, 실제 기기는 PC IP주소 사용

    final String baseUrl = "http://34.64.124.33:8080/backend/api/risk";
    // final String baseUrl = "http://34.64.124.33:8080/api/risk";

    try {
      final response = await http.get(Uri.parse('$baseUrl?date=$dateStr'));

      if (response.statusCode == 200) {
        // 한글 깨짐 방지: utf8.decode 사용
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));

        setState(() {
          _riskList = body.map((item) => ExchangeRiskModel.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        _riskList = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("데이터를 불러오지 못했습니다. (서버 연결 확인)")),
      );
    }
  }

  // -------------------------------------------------------------------------
  // [UI 헬퍼] 백엔드 데이터(텍스트)를 Flutter 색상/아이콘으로 매핑
  // -------------------------------------------------------------------------
  Color _getCardColor(String status) {
    if (status == "안전") return Colors.green.shade50;
    if (status == "주의") return Colors.orange.shade50;
    if (status == "위험") return Colors.red.shade50;
    return Colors.grey.shade50;
  }

  Color _getTextColor(String status) {
    if (status == "안전") return Colors.green.shade800;
    if (status == "주의") return Colors.orange.shade800;
    if (status == "위험") return Colors.red.shade800;
    return Colors.black;
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
            colorScheme: ColorScheme.light(primary: Colors.blueAccent),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
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
        title: const Text("☁️ 환율 기상청", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. 상단 날짜 선택 영역
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

          // 2. 리스트 영역
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
                  const Text("데이터가 없습니다.", style: TextStyle(color: Colors.grey)),
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
    Color cardColor = _getCardColor(item.riskStatus);
    Color textColor = _getTextColor(item.riskStatus);

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
            Row(
              children: [
                // 1. 날씨 아이콘 (텍스트로 옴: ☀️, ☁️ 등)
                Text(
                  item.weatherIcon,
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(width: 15),

                // 2. 통화 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.volCurrency,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: textColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.riskStatus,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. 수치 정보
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${item.volCurrentVal}",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textColor),
                    ),
                    Text(
                      "예측: ${item.volForecastVal}",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 30),

            // 4. 하단 코멘트 (백엔드에서 받은 문장)
            Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.predictionComment,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}