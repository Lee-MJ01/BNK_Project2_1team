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
        if (questions == null) {
            return;
        }
        for (SurveyQuestionDTO question : questions) {
            question.setSurveyId(surveyId);
            question.setCreatedBy(createdBy);
            question.setUpdatedBy(updatedBy);
            surveyAdminMapper.insertSurveyQuestion(question);
            if (question.getOptions() == null) {
                continue;
            }
            for (SurveyOptionDTO option : question.getOptions()) {
                option.setQId(question.getQId());
                option.setCreatedBy(createdBy);
                option.setUpdatedBy(updatedBy);
                surveyAdminMapper.insertSurveyOption(option);
            }
        }
    }
}
