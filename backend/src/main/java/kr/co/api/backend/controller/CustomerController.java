package kr.co.api.backend.controller;

import kr.co.api.backend.dto.BoardDTO;
import kr.co.api.backend.dto.FaqDTO;
import kr.co.api.backend.dto.QnaDTO;
import kr.co.api.backend.dto.TermsHistDTO;
import kr.co.api.backend.jwt.CustomUserDetails;
import kr.co.api.backend.service.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
@Controller
@RequestMapping("/customer")
@RequiredArgsConstructor
@Slf4j
public class CustomerController {

    private final BoardService boardService;
    private final FaqService faqService;
    private final QnaService qnaService;
    private final TermsDbService termsDbService;
    private final QnaAiService qnaAiService;



    @GetMapping("/event_list")
    public String event_list(
            @RequestParam(defaultValue = "1") int page,
            Model model) {

        Map<String, Object> eventPage = boardService.getEventPage(page);

        model.addAttribute("eventList", eventPage.get("list"));
        model.addAttribute("page", eventPage.get("page"));
        model.addAttribute("totalPage", eventPage.get("totalPage"));
        model.addAttribute("totalCount", eventPage.get("totalCount"));
        model.addAttribute("pageSize", eventPage.get("pageSize"));
        model.addAttribute("activeItem","event");

        return "customer/event_list";
    }



    @GetMapping("/event_view/{boardNo}")
    public String event_view(@PathVariable Long boardNo, Model model){

        BoardDTO event = boardService.getEvent(boardNo);

        if (event == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND);
        }

        model.addAttribute("activeItem", "event");
        model.addAttribute("event", event);

        return "customer/event_view";
    }





    @GetMapping("/faq_list")
    public String faqList(Model model) {

        List<FaqDTO> faqList = faqService.getFaqList();

        // 카테고리별 그룹핑
        Map<Integer, List<FaqDTO>> grouped = faqList.stream()
                .collect(Collectors.groupingBy(FaqDTO::getFaqCate));

        model.addAttribute("faqMap", grouped);
        model.addAttribute("activeItem", "faq");

        return "customer/faq_list";
    }





    @GetMapping("/intro")
    public String intro(Model model){
        model.addAttribute("activeItem","intro");
        return "customer/intro";
    }


    @GetMapping("/notice_list")
    public String notice_list(
            @RequestParam(defaultValue = "1") int page,
            Model model){

        Map<String, Object> noticePage = boardService.getNoticePage(page);

        model.addAttribute("noticeList", noticePage.get("list"));  // ← 수정됨
        model.addAttribute("page", noticePage.get("page"));
        model.addAttribute("totalPage", noticePage.get("totalPage"));
        model.addAttribute("totalCount", noticePage.get("totalCount"));
        model.addAttribute("pageSize", noticePage.get("pageSize"));
        model.addAttribute("activeItem","notice");

        return "customer/notice_list";
    }




    @GetMapping("/notice_view/{boardNo}")
    public String notice_view(@PathVariable Long boardNo, Model model){
        BoardDTO notice = boardService.getNotice(boardNo);
        if (notice == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND);
        }
        model.addAttribute("activeItem", "notice");
        model.addAttribute("notice", notice);
        return "customer/notice_view";
    }


    @GetMapping("/terms_download")
    public String termsDownload(Model model) {
        int[] categories = {1, 2, 3, 5, 6};

        Map<Integer, List<TermsHistDTO>> termsByCate = new LinkedHashMap<>();
        Map<Integer, String> categoryNames = new LinkedHashMap<>();

        categoryNames.put(1, "회원가입");
        categoryNames.put(2, "환전하기");
        categoryNames.put(3, "외화송금");
        categoryNames.put(5, "원화통장 개설");
        categoryNames.put(6, "외화통장 개설");

        for (int cate : categories) {
            List<TermsHistDTO> terms = termsDbService.getTermsByLocation(cate);
            termsByCate.put(cate, terms == null ? Collections.emptyList() : terms);
        }

        model.addAttribute("categoryNames", categoryNames);
        model.addAttribute("termsByCate", termsByCate);
        model.addAttribute("activeItem", "terms");

        return "customer/terms_download";
    }


    @GetMapping("/terms_download/{histId}/file")
    public ResponseEntity<Resource> downloadTermsFile(@PathVariable Long histId) {
        TermsHistDTO hist = termsDbService.getTermsHist(histId);

        if (hist == null || hist.getThistFile() == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND);
        }

        Resource resource = termsDbService.loadTermsFile(hist);

        if (resource == null || !resource.exists() || !resource.isReadable()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND);
        }

        String downloadName = termsDbService.buildDownloadFileName(hist);

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_PDF)
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename=\"" + downloadName + "\"")
                .body(resource);
    }





    @GetMapping("/qna_list")
    public String qna_list(@RequestParam(defaultValue = "1") int page, Model model) {
        Map<String, Object> qnaPage = qnaService.getQnaPage(page);

        model.addAttribute("qnaList", qnaPage.get("list"));
        model.addAttribute("page", qnaPage.get("page"));
        model.addAttribute("totalPage", qnaPage.get("totalPage"));
        model.addAttribute("totalCount", qnaPage.get("totalCount"));
        model.addAttribute("pageSize", qnaPage.get("pageSize"));
        model.addAttribute("activeItem", "qna");

        return "customer/qna_list";
    }

    @GetMapping("/qna_view/{qnaNo}")
    public String qna_view(@PathVariable Long qnaNo,
                           @AuthenticationPrincipal CustomUserDetails userDetails,
                           Model model) {

        QnaDTO qna = qnaService.getQna(qnaNo);
        if (qna == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND);
        }

        boolean isOwner = userDetails != null && userDetails.getUsername().equals(qna.getQnaCustCode());
        boolean canViewAnswer = "SAFE".equalsIgnoreCase(qna.getQnaStatus()) || "ANSWERED".equalsIgnoreCase(qna.getQnaStatus());

        model.addAttribute("activeItem", "qna");
        model.addAttribute("qna", qna);
        model.addAttribute("isOwner", isOwner);
        model.addAttribute("canViewAnswer", canViewAnswer);

        return "customer/qna_view";
    }

    @GetMapping("/qna_write")
    public String qna_write(Model model,
                            @AuthenticationPrincipal CustomUserDetails userDetails) {
        model.addAttribute("activeItem", "qna");
        if (userDetails != null) {
            model.addAttribute("writerName", userDetails.getCustName());
        }
        return "customer/qna_write";
    }

    @PostMapping("/qna_write")
    public String submitQna(@RequestParam String title,
                            @RequestParam String content,
                            @AuthenticationPrincipal CustomUserDetails userDetails,
                            RedirectAttributes redirectAttributes) {

        if (userDetails == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
        }

        QnaDTO qna = new QnaDTO();
        qna.setQnaTitle(title);
        qna.setQnaContent(content);
        qna.setQnaCustCode(userDetails.getUsername());
        qna.setQnaStatus("WAIT");

        // 1) QNA 먼저 저장
        qnaService.createQna(qna);

        // 2) AI는 비동기로 처리 (예외는 서비스 내부에서 처리)
        qnaAiService.sendToAi(qna.getQnaNo(), content, title);

        // 3) 유저는 바로 리스트로 이동
        redirectAttributes.addFlashAttribute("message", "문의가 등록되었습니다. AI가 답변 초안을 준비 중입니다.");

        return "redirect:/customer/qna_list";
    }


    @GetMapping("/qna_edit/{qnaNo}")
    public String qna_edit(@PathVariable Long qnaNo,
                           @AuthenticationPrincipal CustomUserDetails userDetails,
                           Model model) {

        QnaDTO qna = qnaService.findQna(qnaNo);
        if (qna == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND);
        }
        if (userDetails == null || !userDetails.getUsername().equals(qna.getQnaCustCode())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN);
        }

        model.addAttribute("qna", qna);
        model.addAttribute("writerName", userDetails.getCustName());
        model.addAttribute("activeItem", "qna");

        return "customer/qna_edit";
    }

    @PostMapping("/qna_edit/{qnaNo}")
    public String updateQna(@PathVariable Long qnaNo,
                            @RequestParam String title,
                            @RequestParam String content,
                            @AuthenticationPrincipal CustomUserDetails userDetails,
                            RedirectAttributes redirectAttributes) {

        QnaDTO qna = qnaService.findQna(qnaNo);
        if (qna == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND);
        }
        if (userDetails == null || !userDetails.getUsername().equals(qna.getQnaCustCode())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN);
        }

        // 1) 질문 내용 수정 + AI 관련 필드 리셋
        qna.setQnaTitle(title);
        qna.setQnaContent(content);
        qna.setQnaDraft(null);          // 이전 AI 초안 제거
        qna.setQnaReply(null);          // 이전 최종답변 제거
        qna.setQnaStatus("WAIT");       // 다시 대기 상태로

        qnaService.updateQna(qna);

        // 2) AI 서버에 재요청 (비동기)
        qnaAiService.sendToAi(qna.getQnaNo(), content, title);

        // 3) 메시지 + 리다이렉트
        redirectAttributes.addFlashAttribute(
                "message",
                "문의가 수정되었습니다. 새로운 내용 기준으로 AI가 다시 초안을 준비 중입니다."
        );

        return "redirect:/customer/qna_view/" + qnaNo;
    }



    @PostMapping("/qna_delete/{qnaNo}")
    public String deleteQna(@PathVariable Long qnaNo,
                            @AuthenticationPrincipal CustomUserDetails userDetails,
                            RedirectAttributes redirectAttributes) {

        QnaDTO qna = qnaService.findQna(qnaNo);
        if (qna == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND);
        }
        if (userDetails == null || !userDetails.getUsername().equals(qna.getQnaCustCode())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN);
        }

        qnaService.deleteQna(qnaNo);
        redirectAttributes.addFlashAttribute("message", "문의가 삭제되었습니다.");

        return "redirect:/customer/qna_list";
    }

}
