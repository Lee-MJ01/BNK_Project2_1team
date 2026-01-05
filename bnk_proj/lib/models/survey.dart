int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  return int.tryParse(value.toString()) ?? fallback;
}

int? _toNullableInt(dynamic value) {
  if (value == null) return null;
  return int.tryParse(value.toString());
}

dynamic _readKey(Map<String, dynamic> json, String camelKey, String snakeKey) {
  if (json.containsKey(camelKey)) {
    return json[camelKey];
  }
  return json[snakeKey];
}

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
      optId: _toInt(_readKey(json, 'optId', 'opt_id')),
      optCode: _readKey(json, 'optCode', 'opt_code')?.toString() ?? '',
      optText: _readKey(json, 'optText', 'opt_text')?.toString() ?? '',
      optValue: _readKey(json, 'optValue', 'opt_value')?.toString(),
      optOrder: _toInt(_readKey(json, 'optOrder', 'opt_order')),
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
    final rawOptions =
        (_readKey(json, 'options', 'options') as List<dynamic>? ?? []);
    return SurveyQuestion(
      qId: _toInt(_readKey(json, 'qId', 'qid')),
      qNo: _toInt(_readKey(json, 'qNo', 'qno')),
      qKey: _readKey(json, 'qKey', 'qkey')?.toString() ?? '',
      qText: _readKey(json, 'qText', 'qtext')?.toString() ?? '',
      qType: _readKey(json, 'qType', 'qtype')?.toString() ?? '',
      isRequired: _readKey(json, 'isRequired', 'is_required')?.toString() ?? 'N',
      maxSelect: _toNullableInt(_readKey(json, 'maxSelect', 'max_select')),
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
    final rawQuestions =
        (_readKey(json, 'questions', 'questions') as List<dynamic>? ?? []);
    return SurveyDetail(
      surveyId: _toInt(_readKey(json, 'surveyId', 'survey_id')),
      title: _readKey(json, 'title', 'title')?.toString() ?? '',
      description: _readKey(json, 'description', 'description')?.toString(),
      questions: rawQuestions
          .map((e) => SurveyQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
