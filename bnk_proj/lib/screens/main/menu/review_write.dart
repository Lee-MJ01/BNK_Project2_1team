import 'package:flutter/material.dart';
import 'package:test_main/screens/app_colors.dart';

class DepositReviewWriteScreen extends StatefulWidget {
  static const routeName = "/deposit-review-write";

  const DepositReviewWriteScreen({super.key});

  @override
  State<DepositReviewWriteScreen> createState() => _DepositReviewWriteScreenState();
}

class _DepositReviewWriteScreenState extends State<DepositReviewWriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  double _rating = 0; // 별점

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pointDustyNavy,
        title: const Text(
          "상품 리뷰 작성",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerInfo(),
            const SizedBox(height: 25),

            _sectionTitle("리뷰 제목"),
            _inputBox(_titleController, "예: 외화적금 너무 만족합니다!"),

            const SizedBox(height: 25),
            _sectionTitle("별점 평가"),
            _ratingStars(),

            const SizedBox(height: 25),
            _sectionTitle("리뷰 내용"),
            _inputBox(
              _contentController,
              "상품 이용 경험을 자유롭게 작성해주세요.",
              maxLines: 8,
            ),

            const SizedBox(height: 40),
            _bottomButtons(context),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // 상단 상품 정보
  // ---------------------------------------------------
  Widget _headerInfo() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mainPaleBlue),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.mainPaleBlue.withOpacity(0.35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              "images/character11.png",
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 16),

          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "FLOBANK 외화 예금",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.pointDustyNavy,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "외화적금 상품 리뷰를 남겨주세요.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // 섹션 제목
  // ---------------------------------------------------
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.pointDustyNavy,
      ),
    );
  }

  // ---------------------------------------------------
  // 입력 박스
  // ---------------------------------------------------
  Widget _inputBox(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mainPaleBlue),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey.shade500),
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // 별점 UI
  // ---------------------------------------------------
  Widget _ratingStars() {
    return Row(
      children: List.generate(5, (index) {
        final isFilled = index < _rating;

        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1;
            });
          },
          child: Icon(
            isFilled ? Icons.star : Icons.star_border,
            size: 32,
            color: isFilled ? Colors.amber : AppColors.mainPaleBlue,
          ),
        );
      }),
    );
  }

  // ---------------------------------------------------
  // 하단 버튼
  // ---------------------------------------------------
  Widget _bottomButtons(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pointDustyNavy,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text(
          "리뷰 등록하기",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
