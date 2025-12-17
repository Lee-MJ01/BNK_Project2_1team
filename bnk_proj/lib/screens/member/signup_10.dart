import 'package:flutter/material.dart';
import 'package:test_main/models/cust_info.dart';
import 'package:test_main/screens/app_colors.dart';
import 'package:test_main/screens/member/signup_11.dart';

class IdCardConfirmPage extends StatelessWidget {
  final String ocrText;

  final CustInfo custInfo;

  const IdCardConfirmPage({
    super.key,
    required this.ocrText, required this.custInfo,
  });



  @override
  Widget build(BuildContext context) {


    final sname = extractName(ocrText) ?? "인식 실패";
    final rrnRaw = extractRrn(ocrText);
    final issueDate = extractIssueDate(ocrText) ?? "-";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("주민등록증 정보"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow("이름", sname),
            _infoRow(
              "주민등록번호",
              rrnRaw != null ? maskRrn(rrnRaw) : "인식 실패",
            ),
            _infoRow("발급일자", issueDate),

            
          ],
        ),
      ),
      bottomNavigationBar: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 60,
                alignment: Alignment.center,
                color: Colors.grey.shade300,
                child: const Text(
                  "재촬영",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => IdVerifyCompletePage(custInfo: custInfo,)));
              },
              child: Container(
                height: 60,
                alignment: Alignment.center,
                color: AppColors.pointDustyNavy,
                child: const Text(
                  "다음",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 3),

          // 언더라인 추가
          const Divider(
            thickness: 2,
            color: AppColors.pointDustyNavy
          ),
        ],
      ),
    );
  }

}


String? extractRrn(String text) {
  final cleaned = text.replaceAll(RegExp(r'[^0-9]'), '');

  if (cleaned.length < 13) return null;

  return '${cleaned.substring(0, 6)}-${cleaned.substring(6, 13)}';
}

String? extractIssueDate(String text) {
  final reg = RegExp(
    r'\d{4}\s*[.,-]\s*\d{1,2}\s*[.,-]\s*\d{1,2}'
  );

  final match = reg.firstMatch(text);
  if (match == null) return null;

  // 정규화: YYYY.MM.DD
  final parts = match.group(0)!
      .replaceAll(RegExp(r'[^0-9]'), ' ')
      .trim()
      .split(RegExp(r'\s+'));

  return '${parts[0]}.${parts[1].padLeft(2, '0')}.${parts[2].padLeft(2, '0')}';
}



String? extractName(String text) {
  final lines = text.split('\n');

  for (final line in lines) {
    // 괄호 앞까지 자름 (뒤에 한자 제거)
    final noParen = line.split('(').first;

    // 공백 제거 + 한글만 남기기
    final cleaned = noParen
        .replaceAll(' ', '')
        .replaceAll(RegExp(r'[^가-힣]'), '');

    // 이름 길이 체크
    if (cleaned.length >= 2 && cleaned.length <= 4) {
      return cleaned;
    }
  }
  return null;
}



String maskRrn(String rrn) {
  final digits = rrn.replaceAll(RegExp(r'[^0-9]'), '');
  return '${digits.substring(0, 6)} - ${digits[6]}******';
}
