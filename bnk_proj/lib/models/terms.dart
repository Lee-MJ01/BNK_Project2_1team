class TermsDocument {
  final int? id;
  final int? cate;
  final int? order;
  final String title;
  final int version;
  final String? regDate;
  final String filePath;
  final String content;
  final String downloadUrl;

  const TermsDocument({
    required this.id,
    required this.cate,
    required this.order,
    required this.title,
    required this.version,
    required this.regDate,
    required this.filePath,
    required this.content,
    required this.downloadUrl,
  });

  factory TermsDocument.fromJson(Map<String, dynamic> json) {
    final rawFile = json['file']?.toString() ?? '';
    final rawUrl = json['downloadUrl']?.toString();

    return TermsDocument(
      id: int.tryParse(json['histId']?.toString() ?? ''),
      cate: int.tryParse(json['cate']?.toString() ?? ''),
      order: int.tryParse(json['order']?.toString() ?? ''),
      title: json['title']?.toString() ?? '약관',
      version: int.tryParse(json['version']?.toString() ?? '') ?? 1,
      regDate: json['regDate']?.toString(),
      filePath: rawFile,
      content: json['content']?.toString() ?? '',
    
      downloadUrl: (rawUrl != null && rawUrl.isNotEmpty) ? rawUrl : rawFile,
    );
  }
}