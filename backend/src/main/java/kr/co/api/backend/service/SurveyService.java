package kr.co.api.backend.service;

import kr.co.api.backend.dto.survey.SurveyAnswerRequestDTO;
import kr.co.api.backend.dto.survey.SurveyDetailResponseDTO;
import kr.co.api.backend.dto.survey.SurveyOptionValueDTO;
import kr.co.api.backend.dto.survey.SurveyQuestionResponseDTO;
import kr.co.api.backend.dto.survey.SurveyResponseDetailDTO;
import kr.co.api.backend.dto.survey.SurveyResponseHeaderDTO;
import kr.co.api.backend.dto.survey.SurveyResponseRequestDTO;
import kr.co.api.backend.mapper.SurveyMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SurveyService {
    private static final Long RESULT_Q_ID = 10L;
    private static final Long TYPE_STABLE = 38L;
    private static final Long TYPE_LIQUID = 39L;
    private static final Long TYPE_FX = 40L;
    private static final Long TYPE_OVERSEAS = 41L;
    private static final Long TYPE_EVENT = 42L;

    private final SurveyMapper surveyMapper;

    public SurveyDetailResponseDTO getSurveyDetail(Long surveyId) {
        SurveyDetailResponseDTO detail = surveyMapper.selectSurveyById(surveyId);
        if (detail == null) {
            return null;
        }

        List<SurveyQuestionResponseDTO> questions = surveyMapper.selectSurveyQuestions(surveyId);
        for (SurveyQuestionResponseDTO question : questions) {
            question.setOptions(surveyMapper.selectQuestionOptions(question.getQId()));
        }
        detail.setQuestions(questions);
        return detail;
    }

    @Transactional
    public void submitSurveyResponse(Long surveyId, SurveyResponseRequestDTO request) {
        Long respId = surveyMapper.selectResponseId(surveyId, request.getCustCode());
        if (respId != null) {
            surveyMapper.deleteResponseDetails(respId);
            surveyMapper.updateResponseHeaderStatus(respId, "DONE");
        } else {
            SurveyResponseHeaderDTO headerDTO = new SurveyResponseHeaderDTO();
            headerDTO.setSurveyId(surveyId);
            headerDTO.setCustCode(request.getCustCode());
            headerDTO.setStatus("DONE");
            surveyMapper.insertResponseHeader(headerDTO);
            respId = headerDTO.getRespId();
        }

        List<SurveyAnswerRequestDTO> answers = Optional.ofNullable(request.getAnswers())
                .orElseGet(Collections::emptyList);

        List<SurveyResponseDetailDTO> details = new ArrayList<>();
        for (SurveyAnswerRequestDTO answer : answers) {
            if (answer.getOptIds() != null && !answer.getOptIds().isEmpty()) {
                for (Long optId : answer.getOptIds()) {
                    SurveyResponseDetailDTO detailDTO = new SurveyResponseDetailDTO();
                    detailDTO.setRespId(respId);
                    detailDTO.setQId(answer.getQId());
                    detailDTO.setOptId(optId);
                    details.add(detailDTO);
                }
            } else if (answer.getAnswerText() != null && !answer.getAnswerText().isBlank()) {
                SurveyResponseDetailDTO detailDTO = new SurveyResponseDetailDTO();
                detailDTO.setRespId(respId);
                detailDTO.setQId(answer.getQId());
                detailDTO.setAnswerText(answer.getAnswerText());
                details.add(detailDTO);
            }
        }

        Long typeOptId = deriveTypeOptId(answers);
        SurveyResponseDetailDTO resultDetail = new SurveyResponseDetailDTO();
        resultDetail.setRespId(respId);
        resultDetail.setQId(RESULT_Q_ID);
        resultDetail.setOptId(typeOptId);
        details.add(resultDetail);

        if (!details.isEmpty()) {
            surveyMapper.insertResponseDetails(details);
        }
    }

    private Long deriveTypeOptId(List<SurveyAnswerRequestDTO> answers) {
        List<Long> optIds = answers.stream()
                .filter(Objects::nonNull)
                .flatMap(answer -> Optional.ofNullable(answer.getOptIds())
                        .orElseGet(Collections::emptyList)
                        .stream())
                .collect(Collectors.toList());

        if (optIds.isEmpty()) {
            return TYPE_STABLE;
        }

        List<SurveyOptionValueDTO> optionValues = surveyMapper.selectOptionValues(optIds);
        Map<Long, List<String>> valuesByQId = new HashMap<>();
        for (SurveyOptionValueDTO option : optionValues) {
            valuesByQId
                    .computeIfAbsent(option.getQId(), key -> new ArrayList<>())
                    .add(option.getOptValue());
        }

        if (containsValue(valuesByQId, 3L, "LIQ_NEED")) {
            return TYPE_LIQUID;
        }

        if (containsValue(valuesByQId, 1L, "GOAL_STABLE")) {
            return TYPE_STABLE;
        }
        if (containsValue(valuesByQId, 1L, "GOAL_FX")) {
            return TYPE_FX;
        }
        if (containsValue(valuesByQId, 1L, "GOAL_OVERSEAS")) {
            return TYPE_OVERSEAS;
        }
        if (containsValue(valuesByQId, 1L, "GOAL_EVENT")) {
            return TYPE_EVENT;
        }

        if (containsValue(valuesByQId, 2L, "PRIOR_LIQ")) {
            return TYPE_LIQUID;
        }
        if (containsValue(valuesByQId, 2L, "PRIOR_RATE")) {
            return TYPE_STABLE;
        }
        if (containsValue(valuesByQId, 2L, "PRIOR_FX")) {
            return TYPE_FX;
        }
        if (containsValue(valuesByQId, 2L, "PRIOR_EVENT")) {
            return TYPE_EVENT;
        }

        return TYPE_STABLE;
    }

    private boolean containsValue(Map<Long, List<String>> valuesByQId, Long qId, String target) {
        return valuesByQId.getOrDefault(qId, Collections.emptyList()).contains(target);
    }
}
