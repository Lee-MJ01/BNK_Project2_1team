

import 'package:flutter/material.dart';
import 'package:test_main/models/cust_info.dart';
import 'package:test_main/screens/app_colors.dart';
import 'package:test_main/screens/member/signup_7.dart';

class SignUp6Page extends StatelessWidget {
  final CustInfo custInfo;

  const SignUp6Page({super.key, required this.custInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(),
        title: const Text("회원가입"),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("취소", style: TextStyle(color: Colors.black54)),
          )
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 20),
                const Text("사용할 계좌 선택",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                const Text("FLOBANK 상품 안내",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                // 상품 카드
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.mainPaleBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 105,
                        child: Image.asset("images/krwaccounticon.png",
                            fit: BoxFit.contain),
                      ),
                      SizedBox(width: 30,),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("FLO 입출금통장",
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text("조건 없이 누구나 혜택을 받을 수 있는\n입출금 통장",
                                style: TextStyle(fontSize: 15)),
                            SizedBox(height: 6),
                            Text("#수수료 면제",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black54)),
                          ],
                        ),
                      ),

                      // 오른쪽 이미지
                    ],
                  ),
                ),



                const SizedBox(height: 20),
              ],
            ),
          ),
          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: (){
                _showLimitInfoPopup(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pointDustyNavy,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,   // ← 여기!
                ),
              ),
              child: Text(
                "다음",
                style: TextStyle(
                  color:Colors.white ,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      )
    );
  }

  // 팝업 호출
  void _showLimitInfoPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _LimitAccountPopup(custInfo),
    );
  }
}




class _LimitAccountPopup extends StatelessWidget {
  const _LimitAccountPopup(this.custInfo);
  final CustInfo custInfo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 팝업 제목
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("금융거래한도계좌 안내",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),

          const SizedBox(height: 10),
          const Text(
            "새 통장은 금융사고 예방을 위해 한도계좌로 개설되며,\n"
                "하루에 100만원까지 이체할 수 있습니다.",
            style: TextStyle(fontSize: 15),
          ),

          const SizedBox(height: 12),
          const Text(
            "가입완료 후 FB뱅킹에서 한도를 해제할 수 있습니다.",
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),

          const SizedBox(height: 30),

          // 확인 버튼
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointDustyNavy,
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => AgreementPage(custInfo: custInfo,)
                )); // 팝업 닫기

                // → 필요하면 다음 페이지 push
              },
              child: const Text(
                "확인",
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
}
