package kr.co.api.backend.controller.admin;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
public class NoticeController {

    @GetMapping("/notification")
    public String notification(Model model) {

        // 1. 사이드바의 'AI 상품추천' 탭을 활성화(active) 시키기 위한 식별자
        // (sidebar.html에서 ${menu} == 'ai-product' 조건을 체크함)
        model.addAttribute("menu", "notification");

        // 2. 페이지 상단 타이틀 전달 (admin_template.html에서 사용)
        model.addAttribute("pageTitle", "알림관리");

        // 3. 실제 보여줄 HTML 파일 경로 (templates/admin/ai_product.html)
        return "admin/notification";
    }
}
