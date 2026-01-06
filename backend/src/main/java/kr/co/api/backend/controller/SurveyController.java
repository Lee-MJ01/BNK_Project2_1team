package kr.co.api.backend.controller;

import kr.co.api.backend.dto.survey.SurveyDetailResponseDTO;
import kr.co.api.backend.dto.survey.SurveyPrefillResponseDTO;
import kr.co.api.backend.dto.survey.SurveyRecommendationDTO;
import kr.co.api.backend.dto.survey.SurveyResponseRequestDTO;
import kr.co.api.backend.service.SurveyService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/surveys")
@RequiredArgsConstructor
public class SurveyController {

    private final SurveyService surveyService;

    @GetMapping("/{surveyId}")
    public ResponseEntity<SurveyDetailResponseDTO> getSurvey(@PathVariable Long surveyId) {
        SurveyDetailResponseDTO detail = surveyService.getSurveyDetail(surveyId);
        if (detail == null) return ResponseEntity.notFound().build();
        return ResponseEntity.ok(detail);
    }

    @PostMapping("/{surveyId}/responses")
    public ResponseEntity<Void> submitSurveyResponse(
            @PathVariable Long surveyId,
            @RequestBody SurveyResponseRequestDTO request
    ) {
        surveyService.submitSurveyResponse(surveyId, request);
        return ResponseEntity.ok().build();
    }

    /**
     * ✅ UX용 추천 조회
     * - 이미 저장된 추천이 있으면 바로 반환
     * - 없으면 FAST(v1+v3)로 생성해서 저장 후 반환
     */
    @GetMapping("/{surveyId}/recommendations")
    public ResponseEntity<List<SurveyRecommendationDTO>> getRecommendations(
            @PathVariable Long surveyId,
            @RequestParam String custCode
    ) {
        return ResponseEntity.ok(surveyService.getRecommendations(surveyId, custCode));
    }

    /**
     * ✅ FAST 추천 강제 갱신 (v1+v3 즉시 top3)
     * - 화면 즉시 표시용 / 디버깅용
     */
    @PostMapping("/{surveyId}/recommendations/refresh")
    public ResponseEntity<List<SurveyRecommendationDTO>> refreshRecommendationsFast(
            @PathVariable Long surveyId,
            @RequestParam String custCode
    ) {
        return ResponseEntity.ok(surveyService.refreshRecommendationsFast(surveyId, custCode));
    }

    /**
     * ✅ AI rerank(v2) 실행 후 DB 갱신
     * - 프론트: 추천 화면에서 fast 먼저 보여주고
     * - 이 API 호출 후 다시 GET 호출하면 바뀐 결과 반영됨
     */
    @PostMapping("/{surveyId}/recommendations/rerank")
    public ResponseEntity<List<SurveyRecommendationDTO>> rerankRecommendationsV2(
            @PathVariable Long surveyId,
            @RequestParam String custCode
    ) {
        return ResponseEntity.ok(surveyService.rerankRecommendationsV2(surveyId, custCode));
    }

    @GetMapping("/{surveyId}/prefill")
    public ResponseEntity<SurveyPrefillResponseDTO> getPrefill(
            @PathVariable Long surveyId,
            @RequestParam String custCode
    ) {
        return ResponseEntity.ok(surveyService.buildPrefill(surveyId, custCode));
    }
}
