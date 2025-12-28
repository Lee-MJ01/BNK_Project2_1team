package kr.co.api.backend.controller.admin;

import kr.co.api.backend.dto.admin.survey.SurveyDetailDTO;
import kr.co.api.backend.dto.admin.survey.SurveyOptionDTO;
import kr.co.api.backend.dto.admin.survey.SurveyQuestionDTO;
import kr.co.api.backend.dto.admin.survey.SurveyQuestionRequestDTO;
import kr.co.api.backend.dto.admin.survey.SurveyRequestDTO;
import kr.co.api.backend.dto.admin.survey.SurveySaveDTO;
import kr.co.api.backend.dto.admin.survey.SurveySummaryDTO;
import kr.co.api.backend.service.admin.SurveyAdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/admin") // 이 컨트롤러의 기본 URL 경로
@RequiredArgsConstructor
public class AdminAiProductController {

    private final SurveyAdminService surveyAdminService;

    /**
     * AI 상품 추천 관리 메인 페이지
     * 요청 URL: /admin/ai-product
     */
    @GetMapping("/ai-product")
    public String aiProductList(Model model) {

        // 1. 사이드바의 'AI 상품추천' 탭을 활성화(active) 시키기 위한 식별자
        // (sidebar.html에서 ${menu} == 'ai-product' 조건을 체크함)
        model.addAttribute("menu", "ai-product");

        // 2. 페이지 상단 타이틀 전달 (admin_template.html에서 사용)
        model.addAttribute("pageTitle", "AI 상품 추천 관리");

        // 3. 실제 보여줄 HTML 파일 경로 (templates/admin/ai_product.html)
        return "admin/ai_product";
    }

    @GetMapping("/ai-product/surveys")
    @ResponseBody
    public List<SurveySummaryDTO> getSurveys() {
        return surveyAdminService.getSurveys();
    }

    @GetMapping("/ai-product/surveys/{surveyId}")
    @ResponseBody
    public ResponseEntity<SurveyDetailDTO> getSurveyDetail(@PathVariable Long surveyId) {
        SurveyDetailDTO detail = surveyAdminService.getSurveyDetail(surveyId);
        if (detail == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(detail);
    }

    @PostMapping("/ai-product/surveys")
    @ResponseBody
    public ResponseEntity<SurveyDetailDTO> createSurvey(@RequestBody SurveyRequestDTO request) {
        SurveySaveDTO survey = buildSurveySaveDTO(request, null);
        List<SurveyQuestionDTO> questions = buildQuestionDTOs(request.getQuestions());
        SurveyDetailDTO saved = surveyAdminService.createSurveyWithQuestions(survey, questions);
        return new ResponseEntity<>(saved, HttpStatus.CREATED);
    }

    @PutMapping("/ai-product/surveys/{surveyId}")
    @ResponseBody
    public ResponseEntity<SurveyDetailDTO> updateSurvey(
            @PathVariable Long surveyId,
            @RequestBody SurveyRequestDTO request
    ) {
        SurveySummaryDTO existing = surveyAdminService.getSurveyById(surveyId);
        if (existing == null) {
            return ResponseEntity.notFound().build();
        }

        SurveySaveDTO survey = buildSurveySaveDTO(request, existing.getSurveyId());
        survey.setIsActive(request.getIsActive() != null ? request.getIsActive() : existing.getIsActive());
        List<SurveyQuestionDTO> questions = buildQuestionDTOs(request.getQuestions());
        SurveyDetailDTO saved = surveyAdminService.updateSurveyWithQuestions(survey, questions);
        return ResponseEntity.ok(saved);
    }

    private SurveySaveDTO buildSurveySaveDTO(SurveyRequestDTO request, Long surveyId) {
        SurveySaveDTO dto = new SurveySaveDTO();
        dto.setSurveyId(surveyId);
        dto.setTitle(request.getTitle());
        dto.setDescription(request.getDescription());
        dto.setIsActive(request.getIsActive() != null ? request.getIsActive() : "Y");
        dto.setCreatedBy(request.getCreatedBy() != null ? request.getCreatedBy() : "admin");
        dto.setUpdatedBy(request.getUpdatedBy() != null ? request.getUpdatedBy() : dto.getCreatedBy());
        return dto;
    }

    private List<SurveyQuestionDTO> buildQuestionDTOs(List<SurveyQuestionRequestDTO> requests) {
        if (requests == null) {
            return List.of();
        }
        return requests.stream().map(request -> {
            SurveyQuestionDTO question = new SurveyQuestionDTO();
            question.setQNo(request.getQNo());
            question.setQKey(request.getQKey());
            question.setQText(request.getQText());
            question.setQType(request.getQType());
            question.setIsRequired(request.getIsRequired());
            question.setMaxSelect(request.getMaxSelect());
            question.setIsActive(request.getIsActive());
            if (request.getOptions() != null) {
                List<SurveyOptionDTO> options = request.getOptions().stream().map(optionRequest -> {
                    SurveyOptionDTO option = new SurveyOptionDTO();
                    option.setOptCode(optionRequest.getOptCode());
                    option.setOptText(optionRequest.getOptText());
                    option.setOptValue(optionRequest.getOptValue());
                    option.setOptOrder(optionRequest.getOptOrder());
                    option.setIsActive(optionRequest.getIsActive());
                    return option;
                }).collect(Collectors.toList());
                question.setOptions(options);
            }
            return question;
        }).collect(Collectors.toList());
    }
}
