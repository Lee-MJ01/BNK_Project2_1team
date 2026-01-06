import 'package:flutter/material.dart';
import 'package:test_main/models/survey.dart';
import 'package:test_main/screens/app_colors.dart';
import 'package:test_main/services/deposit_service.dart';
import 'package:test_main/services/survey_service.dart';
import 'package:test_main/screens/deposit/recommend.dart';

class DepositSurveyScreen extends StatefulWidget {
  static const routeName = "/deposit-survey";

  const DepositSurveyScreen({super.key});

  @override
  State<DepositSurveyScreen> createState() => _DepositSurveyScreenState();
}

class _DepositSurveyScreenState extends State<DepositSurveyScreen> {
  static const int surveyId = 43;
  static const int resultQId = 10;

  final SurveyService _surveyService = SurveyService();
  final DepositService _depositService = DepositService();
  final Map<int, dynamic> _answers = {};
  final Map<int, TextEditingController> _textControllers = {};

  late Future<SurveyDetail> _surveyFuture;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _surveyFuture = _surveyService.fetchSurveyDetail(surveyId);
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pointDustyNavy,
        title: const Text(
          "외화예금 성향 테스트",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<SurveyDetail>(
        future: _surveyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                '설문을 불러오지 못했습니다.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('설문 데이터가 없습니다.'));
          }

          final detail = snapshot.data!;
          final questions = detail.questions
              .where((q) => q.qId != resultQId && q.qKey != 'Q_RESULT_TYPE')
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _header(detail),
                const SizedBox(height: 25),
                ...questions.map((question) => Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: _buildQuestionCard(question),
                    )),
                const SizedBox(height: 10),
                _submitButton(questions),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(SurveyDetail detail) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.mainPaleBlue.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            detail.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w700,
              color: AppColors.pointDustyNavy,
            ),
          ),
          if (detail.description != null && detail.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              detail.description!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.pointDustyNavy.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionCard(SurveyQuestion question) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.mainPaleBlue.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${question.qNo}. ${question.qText}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.pointDustyNavy,
                  ),
                ),
              ),
              if (question.isRequired == 'Y')
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Text(
                    '*',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (question.qType == 'SINGLE') _buildSingleOptions(question),
          if (question.qType == 'MULTI') _buildMultiOptions(question),
          if (question.qType == 'TEXT') _buildTextField(question),
        ],
      ),
    );
  }

  Widget _buildSingleOptions(SurveyQuestion question) {
    final selected = _answers[question.qId] as int?;
    return Column(
      children: question.options.map((option) {
        return RadioListTile<int>(
          title: Text(
            option.optText,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.pointDustyNavy,
            ),
          ),
          value: option.optId,
          groupValue: selected,
          activeColor: AppColors.pointDustyNavy,
          onChanged: (value) {
            setState(() {
              _answers[question.qId] = value;
            });
          },
          dense: true,
        );
      }).toList(),
    );
  }

  Widget _buildMultiOptions(SurveyQuestion question) {
    final selected =
        (_answers[question.qId] as Set<int>?) ?? <int>{};
    final maxSelect = question.maxSelect;

    return Column(
      children: question.options.map((option) {
        final isChecked = selected.contains(option.optId);
        return CheckboxListTile(
          title: Text(
            option.optText,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.pointDustyNavy,
            ),
          ),
          value: isChecked,
          activeColor: AppColors.pointDustyNavy,
          onChanged: (value) {
            if (value == null) return;
            final updated = Set<int>.from(selected);
            if (value) {
              if (maxSelect != null && updated.length >= maxSelect) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('최대 $maxSelect개까지 선택할 수 있습니다.'),
                  ),
                );
                return;
              }
              updated.add(option.optId);
            } else {
              updated.remove(option.optId);
            }
            setState(() {
              _answers[question.qId] = updated;
            });
          },
          dense: true,
        );
      }).toList(),
    );
  }

  Widget _buildTextField(SurveyQuestion question) {
    final controller = _textControllers.putIfAbsent(
      question.qId,
      () => TextEditingController(),
    );

    return TextField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: '답변을 입력해 주세요',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.pointDustyNavy),
        ),
      ),
    );
  }

  Widget _submitButton(List<SurveyQuestion> questions) {
    final isFilled = _validateAnswers(questions, showMessage: false);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: !isFilled || _isSubmitting
            ? null
            : () => _submitSurvey(questions),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isFilled ? AppColors.pointDustyNavy : Colors.grey.shade400,
          padding: const EdgeInsets.symmetric(vertical: 15),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                '저장하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  bool _validateAnswers(List<SurveyQuestion> questions,
      {required bool showMessage}) {
    for (final question in questions) {
      if (question.isRequired != 'Y') continue;
      if (question.qType == 'SINGLE') {
        if (_answers[question.qId] == null) {
          if (showMessage) _showValidationMessage();
          return false;
        }
      } else if (question.qType == 'MULTI') {
        final selected = (_answers[question.qId] as Set<int>?) ?? <int>{};
        if (selected.isEmpty) {
          if (showMessage) _showValidationMessage();
          return false;
        }
      } else if (question.qType == 'TEXT') {
        final controller = _textControllers[question.qId];
        if (controller == null || controller.text.trim().isEmpty) {
          if (showMessage) _showValidationMessage();
          return false;
        }
      }
    }
    return true;
  }

  void _showValidationMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('필수 질문을 모두 응답해 주세요.')),
    );
  }

  Future<void> _submitSurvey(List<SurveyQuestion> questions) async {
    if (!_validateAnswers(questions, showMessage: true)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final contextData = await _depositService.fetchContext();
      final custCode = contextData.customerCode;
      if (custCode == null || custCode.isEmpty) {
        throw Exception('고객 정보를 찾을 수 없습니다.');
      }

      final answers = <Map<String, dynamic>>[];
      for (final question in questions) {
        if (question.qType == 'TEXT') {
          final text = _textControllers[question.qId]?.text.trim();
          if (text != null && text.isNotEmpty) {
            answers.add({
              'qId': question.qId,
              'optIds': null,
              'answerText': text,
            });
          }
        } else if (question.qType == 'SINGLE') {
          final selected = _answers[question.qId] as int?;
          if (selected != null) {
            answers.add({
              'qId': question.qId,
              'optIds': [selected],
              'answerText': null,
            });
          }
        } else if (question.qType == 'MULTI') {
          final selected = (_answers[question.qId] as Set<int>?) ?? <int>{};
          if (selected.isNotEmpty) {
            answers.add({
              'qId': question.qId,
              'optIds': selected.toList(),
              'answerText': null,
            });
          }
        }
      }

      //final echoed = await _surveyService.submitSurveyResponseDebug(
      //  surveyId: surveyId,
      //  custCode: custCode,
      //  answers: answers,
      //);
      //print('✅ SERVER ECHO = $echoed');

      await _surveyService.submitSurveyResponse(
        surveyId: surveyId,
        custCode: custCode,
        answers: answers,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        RecommendScreen.routeName,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
