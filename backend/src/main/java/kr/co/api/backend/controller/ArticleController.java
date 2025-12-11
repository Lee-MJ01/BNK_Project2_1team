package kr.co.api.backend.controller;

import kr.co.api.backend.dto.BriefingViewDTO;
import kr.co.api.backend.service.ArticleService;
import kr.co.api.backend.service.BriefingService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.Map;

@Controller
@RequiredArgsConstructor
public class ArticleController {

    private final ArticleService articleService;
    private final BriefingService briefingService;

    @GetMapping("/articles")
    public String articleList(
            @RequestParam(value = "mode", required = false, defaultValue = "oneday") String mode,
            @RequestParam(value = "page", defaultValue = "1") int page,
            Model model
    ) {

        BriefingViewDTO briefingView = briefingService.buildBriefingView(mode);
        Map<String, Object> articlePage = articleService.getArticlePage(page);

        // 브리핑 정보
        model.addAttribute("briefingMode", briefingView.getBriefingMode());
        model.addAttribute("briefingTitle", briefingView.getBriefingTitle());
        model.addAttribute("briefingDateText", briefingView.getBriefingDateText());
        model.addAttribute("briefingLines", briefingView.getBriefingLines());

        // 기사 리스트 + 페이징
        model.addAttribute("articles", articlePage.get("list"));
        model.addAttribute("page", articlePage.get("page"));
        model.addAttribute("totalPage", articlePage.get("totalPage"));
        model.addAttribute("totalCount", articlePage.get("totalCount"));
        model.addAttribute("pageSize", articlePage.get("pageSize"));

        // ⭐⭐⭐ 블록 페이징 추가 (이게 있어야 page 1~10 / 11~20 잘 뜸)
        model.addAttribute("startPage", articlePage.get("startPage"));
        model.addAttribute("endPage", articlePage.get("endPage"));
        model.addAttribute("blockSize", articlePage.get("blockSize"));

        return "article/list";
    }

    @GetMapping("/api/briefing")
    @ResponseBody
    public BriefingViewDTO getBriefing(@RequestParam(value = "mode", defaultValue = "oneday") String mode) {
        return briefingService.buildBriefingView(mode);
    }
}
