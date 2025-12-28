package kr.co.api.backend.mapper.admin;

import kr.co.api.backend.dto.admin.survey.SurveyOptionDTO;
import kr.co.api.backend.dto.admin.survey.SurveyQuestionDTO;
import kr.co.api.backend.dto.admin.survey.SurveySaveDTO;
import kr.co.api.backend.dto.admin.survey.SurveySummaryDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface SurveyAdminMapper {

    List<SurveySummaryDTO> selectSurveyList();

    SurveySummaryDTO selectSurveyById(@Param("surveyId") Long surveyId);

    int insertSurvey(SurveySaveDTO dto);

    int updateSurvey(SurveySaveDTO dto);

    List<SurveyQuestionDTO> selectSurveyQuestions(@Param("surveyId") Long surveyId);

    List<SurveyOptionDTO> selectQuestionOptions(@Param("qId") Long qId);

    int insertSurveyQuestion(SurveyQuestionDTO dto);

    int insertSurveyOption(SurveyOptionDTO dto);

    int deleteSurveyOptionsBySurveyId(@Param("surveyId") Long surveyId);

    int deleteSurveyQuestionsBySurveyId(@Param("surveyId") Long surveyId);
}
