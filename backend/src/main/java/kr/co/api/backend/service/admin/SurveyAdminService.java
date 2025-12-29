package kr.co.api.backend.service.admin;

import kr.co.api.backend.dto.admin.survey.SurveyDetailDTO;
import kr.co.api.backend.dto.admin.survey.SurveyOptionDTO;
import kr.co.api.backend.dto.admin.survey.SurveyQuestionDTO;
import kr.co.api.backend.dto.admin.survey.SurveySaveDTO;
import kr.co.api.backend.dto.admin.survey.SurveySummaryDTO;
import kr.co.api.backend.mapper.admin.SurveyAdminMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class SurveyAdminService {

    private final SurveyAdminMapper surveyAdminMapper;

    public List<SurveySummaryDTO> getSurveys() {
        return surveyAdminMapper.selectSurveyList();
    }

    public SurveySummaryDTO getSurveyById(Long surveyId) {
        return surveyAdminMapper.selectSurveyById(surveyId);
    }

    public SurveySummaryDTO createSurvey(SurveySaveDTO dto) {
        surveyAdminMapper.insertSurvey(dto);
        return surveyAdminMapper.selectSurveyById(dto.getSurveyId());
    }

    public SurveySummaryDTO updateSurvey(SurveySaveDTO dto) {
        surveyAdminMapper.updateSurvey(dto);
        return surveyAdminMapper.selectSurveyById(dto.getSurveyId());
    }

    public SurveyDetailDTO getSurveyDetail(Long surveyId) {
        SurveySummaryDTO summary = surveyAdminMapper.selectSurveyById(surveyId);
        if (summary == null) {
            return null;
        }
        SurveyDetailDTO detail = new SurveyDetailDTO();
        detail.setSurveyId(summary.getSurveyId());
        detail.setTitle(summary.getTitle());
        detail.setDescription(summary.getDescription());
        detail.setIsActive(summary.getIsActive());
        detail.setQuestionCount(summary.getQuestionCount());
        detail.setCreatedAt(summary.getCreatedAt());
        detail.setCreatedBy(summary.getCreatedBy());
        detail.setUpdatedAt(summary.getUpdatedAt());
        detail.setUpdatedBy(summary.getUpdatedBy());
        List<SurveyQuestionDTO> questions = surveyAdminMapper.selectSurveyQuestions(surveyId);
        for (SurveyQuestionDTO question : questions) {
            List<SurveyOptionDTO> options = surveyAdminMapper.selectQuestionOptions(question.getQId());
            question.setOptions(options);
        }
        detail.setQuestions(questions);
        return detail;
    }

    @Transactional
    public SurveyDetailDTO createSurveyWithQuestions(
            SurveySaveDTO survey,
            List<SurveyQuestionDTO> questions
    ) {
        surveyAdminMapper.insertSurvey(survey);
        insertQuestions(survey.getSurveyId(), survey.getCreatedBy(), survey.getUpdatedBy(), questions);
        return getSurveyDetail(survey.getSurveyId());
    }

    @Transactional
    public SurveyDetailDTO updateSurveyWithQuestions(
            SurveySaveDTO survey,
            List<SurveyQuestionDTO> questions
    ) {
        surveyAdminMapper.updateSurvey(survey);
        surveyAdminMapper.deleteSurveyOptionsBySurveyId(survey.getSurveyId());
        surveyAdminMapper.deleteSurveyQuestionsBySurveyId(survey.getSurveyId());
        insertQuestions(survey.getSurveyId(), survey.getUpdatedBy(), survey.getUpdatedBy(), questions);
        return getSurveyDetail(survey.getSurveyId());
    }

    private void insertQuestions(
            Long surveyId,
            String createdBy,
            String updatedBy,
            List<SurveyQuestionDTO> questions
    ) {
        if (questions == null || questions.isEmpty()) {
            return;
        }

        int qNo = 1;

        for (SurveyQuestionDTO question : questions) {

            // 🔥 1. qText 없으면 저장 자체를 안 함 (ORA-01400 방지)
            if (question.getQText() == null || question.getQText().isBlank()) {
                continue;
            }

            // 🔥 2. FK / 순번 세팅
            question.setSurveyId(surveyId);
            question.setQNo(qNo++);

            // 🔥 3. 필수값 방어
            if (question.getQKey() == null || question.getQKey().isBlank()) {
                question.setQKey("Q" + question.getQNo());
            }

            if (question.getQType() == null || question.getQType().isBlank()) {
                question.setQType("SINGLE");
            }

            if (question.getIsRequired() == null) {
                question.setIsRequired("Y");
            }

            if (question.getIsActive() == null) {
                question.setIsActive("Y");
            }

            // 🔥 4. audit 컬럼
            question.setCreatedBy(createdBy);
            question.setUpdatedBy(updatedBy);

            // 🔥 5. 질문 INSERT
            surveyAdminMapper.insertSurveyQuestion(question);

            // 🔥 6. 옵션 없으면 스킵
            if (question.getOptions() == null || question.getOptions().isEmpty()) {
                continue;
            }

            int optOrder = 1;
            for (SurveyOptionDTO option : question.getOptions()) {
                option.setQId(question.getQId());
                option.setOptOrder(optOrder++);
                option.setCreatedBy(createdBy);
                option.setUpdatedBy(updatedBy);

                surveyAdminMapper.insertSurveyOption(option);
            }
        }
    }

}
