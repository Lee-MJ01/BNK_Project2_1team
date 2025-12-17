import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:test_main/models/cust_acct.dart';
import 'package:test_main/models/cust_info.dart';
import 'package:test_main/screens/app_colors.dart';
import 'package:test_main/screens/member/signup_22.dart';

import '../../utils/device_manager.dart';

class ElectronicSignaturePage extends StatefulWidget {
  const ElectronicSignaturePage({
    super.key,
    required this.contractMethod, required this.custInfo, required this.custAcct,
  });

  final CustInfo custInfo;
  final CustAcct custAcct;


  final String contractMethod;

  @override
  State<ElectronicSignaturePage> createState() =>
      _ElectronicSignaturePageState();
}

class _ElectronicSignaturePageState extends State<ElectronicSignaturePage> {



  String _deviceId = "UNKNOWN_DEVICE";


  Map<String, dynamic> _buildContractSnapshot(String personId) {
    return {
      "personId": personId,
      "jobType": widget.custInfo.jobType,
      "purpose": widget.custAcct.purpose,
      "source": widget.custAcct.source,
      "isOwner": widget.custAcct.isOwner,
      "isForeignTax": widget.custInfo.isForeignTax,
      "productCode": "CHECKING_ACCOUNT",
      "termsVersion": "v1.0",
      "contractAt": DateTime.now().toIso8601String(),
      "deviceId": _deviceId,
    };
  }


  final List<Offset?> _points = [];
  bool get _hasSignature => _points.isNotEmpty;

  late final String personId;


  String sha256Hex(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);  // convert 사용
    return digest.toString();
  }

  @override
  void initState() {
    super.initState();
    personId = sha256Hex(widget.custInfo.rrn!);   // rrn → personId
    _initDeviceId();
  }

  Future<void> _initDeviceId() async {
    _deviceId = await DeviceManager.getDeviceId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text("전자서명", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [

                const SizedBox(height: 24),

                // 🔒 계약 요약
                const Text(
                  "입출금 통장 개설 계약",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                _contractRow("상품명", "FLO 입출금통장"),
                _contractRow("계약자", _maskName(widget.custInfo.name)),
                _contractRow("개설 목적", widget.custAcct.purpose!),
                _contractRow("자금 출처", widget.custAcct.source!),
                _contractRow("본인 소유 여부", widget.custAcct.isOwner ? "예" : "아니오"),
                _contractRow(
                    "해외 납세 의무자", widget.custInfo.isForeignTax ? "예" : "아니오"),

                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () {
                    // TODO: 상품설명서 PDF 보기
                  },
                  child: const Text(
                    "상품설명서 및 약관 보기",
                    style: TextStyle(
                      color: AppColors.pointDustyNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 서명 영역
                const Text(
                  "전자서명",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const Text(
                  "아래 영역에 서명해 주세요.",
                  style: TextStyle(color: Colors.black54),
                ),

                const SizedBox(height: 12),

                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black26),
                  ),
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        RenderBox box = context.findRenderObject() as RenderBox;
                        _points.add(box.globalToLocal(details.globalPosition));
                      });
                    },
                    onPanEnd: (_) => _points.add(null),
                    child: CustomPaint(
                      painter: _SignaturePainter(_points),
                      size: Size.infinite,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      setState(() => _points.clear());
                    },
                    child: const Text("다시 쓰기"),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "본인은 위 계약 내용을 모두 확인하였으며,\n"
                      "전자서명을 통해 입출금 통장 개설에 동의합니다.",
                  style: TextStyle(fontSize: 14),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),

          // 하단 버튼
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _hasSignature ? _onSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _hasSignature
                    ? AppColors.pointDustyNavy
                    : Colors.grey.shade300,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: const Text(
                "전자서명 완료",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (_points.isEmpty) return;

    // 계약 스냅샷 생성
    final contractSnapshot = _buildContractSnapshot(personId);

    // 서명 이미지 base64
    final signatureBase64 = await _signatureToBase64();

    // 서버로 보낼 payload
    final payload = {
      "contractSnapshot": contractSnapshot,
      "signatureImage": signatureBase64,
    };

    // (지금은 서버 대신 로그)
    debugPrint("📄 Electronic Signature Payload");
    debugPrint(const JsonEncoder.withIndent('  ').convert(payload));

    // rrn 메모리 폐기 (의미적)
    // widget.rrn = null; // ← final이라 실제 제거는 scope 종료로 처리

    widget.custInfo.deviceId = _deviceId;
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => AccountCreateCompletePage(custAcct: widget.custAcct, custInfo: widget.custInfo, contractMethod: widget.contractMethod, ))
    );
  }


  Widget _contractRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(title,
                style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _maskName(String name) {
    if (name.length <= 1) return name;
    return name[0] + "＊" * (name.length - 1);
  }

  Future<String> _signatureToBase64() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < _points.length - 1; i++) {
      if (_points[i] != null && _points[i + 1] != null) {
        canvas.drawLine(_points[i]!, _points[i + 1]!, paint);
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(600, 300);
    final byteData =
    await image.toByteData(format: ui.ImageByteFormat.png);

    return base64Encode(byteData!.buffer.asUint8List());
  }

}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  _SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

