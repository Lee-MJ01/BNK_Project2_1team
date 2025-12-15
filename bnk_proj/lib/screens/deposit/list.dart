import 'package:flutter/material.dart';
import 'package:test_main/screens/deposit/view.dart';
import 'package:test_main/screens/deposit/step_1.dart';
import 'package:test_main/screens/deposit/recommend.dart';
import 'package:test_main/screens/app_colors.dart';
import 'package:test_main/models/deposit/list.dart';
import 'package:test_main/models/deposit/view.dart';
import 'package:test_main/services/deposit_service.dart';


class DepositListPage extends StatefulWidget {

  const DepositListPage({super.key});

  @override
  State<DepositListPage> createState() => _DepositListPageState();
}

class _DepositListPageState extends State<DepositListPage> {
  final DepositService _service = DepositService();
  late Future<List<DepositProductList>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = _service.fetchProductList();
  }

  void _reload() {
    setState(() {
      _futureProducts = _service.fetchProductList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        title: const Text(
          "외화예금상품",
          style: TextStyle(
            color: AppColors.pointDustyNavy,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.subIvoryBeige,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.pointDustyNavy),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // AI 추천 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, RecommendScreen.routeName);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pointDustyNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "AI 외화예금 추천 받기",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            FutureBuilder<List<DepositProductList>>(
              future: _futureProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Expanded(

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 상품명
                        Text(
                          '목록을 불러오는 중 오류가 발생했습니다.',
                          style: const TextStyle(color: Colors.redAccent),

                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _reload,
                          icon: const Icon(Icons.refresh),
                          label: const Text('다시 시도'),

                        ),







                      ],
                    ),
                  );
                }

                final products = snapshot.data ?? [];

                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "조회결과 [총 ${products.length}건]",
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          itemCount: products.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final item = products[index];

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.mainPaleBlue),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.pointDustyNavy,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.info.isNotEmpty
                                        ? item.info
                                        : '상품 설명이 없습니다.',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      height: 1.5,
                                    ),
                                  ),



                                  const SizedBox(height: 14),

                                  Row(
                                    children: [
                                      // 상세보기 버튼
                                      OutlinedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            DepositViewScreen.routeName,
                                            arguments: DepositViewArgs(
                                              dpstId: item.id,
                                            ),
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size(90, 40),
                                          side: const BorderSide(color: AppColors.pointDustyNavy),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                        ),
                                        child: const Text(
                                          "상세보기",
                                          style: TextStyle(
                                            color: AppColors.pointDustyNavy,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(context, DepositStep1Screen.routeName);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.pointDustyNavy,
                                          foregroundColor: Colors.white,
                                          minimumSize: const Size(90, 40),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                        ),
                                        child: const Text(
                                          "가입하기",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),

                                      const Spacer(),

                                      SizedBox(
                                        width: 60,
                                        height: 60,
                                        child: Image.asset(
                                          "images/deposit.png",
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) => const Icon(
                                            Icons.savings,
                                            size: 50,
                                            color: AppColors.pointDustyNavy,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )

                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },







            ),

          ],
        ),
      ),
    );
  }
}
