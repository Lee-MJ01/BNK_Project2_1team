class SurveyOption {
  final int optId;
  final String optCode;
  final String optText;
  final String? optValue;
  final int optOrder;

  const SurveyOption({
    required this.optId,
    required this.optCode,
    required this.optText,
    required this.optValue,
    required this.optOrder,
  });

  factory SurveyOption.fromJson(Map<String, dynamic> json) {
    return SurveyOption(
      optId: int.parse(json['optId'].toString()),
      optCode: json['optCode']?.toString() ?? '',
      optText: json['optText']?.toString() ?? '',
      optValue: json['optValue']?.toString(),
      optOrder: int.tryParse(json['optOrder']?.toString() ?? '') ?? 0,
    );
  }
}

class SurveyQuestion {
  final int qId;
  final int qNo;
  final String qKey;
  final String qText;
  final String qType;
  final String isRequired;
  final int? maxSelect;
  final List<SurveyOption> options;

  const SurveyQuestion({
    required this.qId,
    required this.qNo,
    required this.qKey,
    required this.qText,
    required this.qType,
    required this.isRequired,
    required this.maxSelect,
    required this.options,
  });

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = (json['options'] as List<dynamic>? ?? []);
    return SurveyQuestion(
      qId: int.parse(json['qId'].toString()),
      qNo: int.tryParse(json['qNo']?.toString() ?? '') ?? 0,
      qKey: json['qKey']?.toString() ?? '',
      qText: json['qText']?.toString() ?? '',
      qType: json['qType']?.toString() ?? '',
      isRequired: json['isRequired']?.toString() ?? 'N',
      maxSelect: json['maxSelect'] == null
          ? null
          : int.tryParse(json['maxSelect'].toString()),
      options: rawOptions
          .map((e) => SurveyOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SurveyDetail {
  final int surveyId;
  final String title;
  final String? description;
  final List<SurveyQuestion> questions;

  const SurveyDetail({
    required this.surveyId,
    required this.title,
    required this.description,
    required this.questions,
  });

  factory SurveyDetail.fromJson(Map<String, dynamic> json) {
    final rawQuestions = (json['questions'] as List<dynamic>? ?? []);
    return SurveyDetail(
      surveyId: int.parse(json['surveyId'].toString()),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      questions: rawQuestions
          .map((e) => SurveyQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
