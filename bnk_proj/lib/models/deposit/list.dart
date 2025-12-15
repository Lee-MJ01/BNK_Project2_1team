/// 외화예금 상품 목록
class DepositProductList {
  final String id;
  final String name;
  final String info;

  const DepositProductList({
    required this.id,
    required this.name,
    required this.info,
  });

  factory DepositProductList.fromJson(Map<String, dynamic> json) {
    return DepositProductList(
      id: json['dpstId']?.toString() ?? '',
      name: json['dpstName']?.toString() ?? '',
      info: json['dpstInfo']?.toString() ?? '',
    );
  }
}
