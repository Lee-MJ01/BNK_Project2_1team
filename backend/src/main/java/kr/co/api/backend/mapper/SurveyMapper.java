package kr.co.api.backend.mapper;

import kr.co.api.backend.dto.survey.SurveyDetailResponseDTO;
import kr.co.api.backend.dto.survey.SurveyOptionResponseDTO;
import kr.co.api.backend.dto.survey.SurveyOptionValueDTO;
import kr.co.api.backend.dto.survey.SurveyQuestionResponseDTO;
import kr.co.api.backend.dto.survey.SurveyRecommendationDTO;
import kr.co.api.backend.dto.survey.SurveyRecommendationInsertDTO;
import kr.co.api.backend.dto.survey.SurveyResponseAnswerDTO;
import kr.co.api.backend.dto.survey.SurveyResponseDetailDTO;
import kr.co.api.backend.dto.survey.SurveyResponseHeaderDTO;
import kr.co.api.backend.dto.survey.SurveyProductDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface SurveyMapper {

    SurveyDetailResponseDTO selectSurveyById(@Param("surveyId") Long surveyId);

    List<SurveyQuestionResponseDTO> selectSurveyQuestions(@Param("surveyId") Long surveyId);

    List<SurveyOptionResponseDTO> selectQuestionOptions(@Param("qId") Long qId);

    Long selectResponseId(@Param("surveyId") Long surveyId, @Param("custCode") String custCode);

    int insertResponseHeader(SurveyResponseHeaderDTO dto);

    int updateResponseHeaderStatus(@Param("respId") Long respId, @Param("status") String status);

    int deleteResponseDetails(@Param("respId") Long respId);

    int insertResponseDetails(@Param("details") List<SurveyResponseDetailDTO> details);

    List<SurveyOptionValueDTO> selectOptionValues(@Param("optIds") List<Long> optIds);

    Long selectLatestResponseId(@Param("surveyId") Long surveyId, @Param("custCode") String custCode);

    List<SurveyResponseAnswerDTO> selectResponseAnswers(@Param("respId") Long respId);

    int deleteRecommendations(@Param("custCode") String custCode, @Param("surveyId") Long surveyId);

    int insertRecommendations(@Param("recs") List<SurveyRecommendationInsertDTO> recs);

    List<SurveyRecommendationDTO> selectRecommendations(@Param("custCode") String custCode, @Param("surveyId") Long surveyId);

    List<String> selectActiveProductIds();

    List<SurveyProductDTO> selectProductSummaries(@Param("productIds") List<String> productIds);
}
