package kr.co.api.backend.controller.admin;

import kr.co.api.backend.service.admin.FcmSendService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/admin")

public class NoticeController {
    private final FcmSendService fcmSendService;

    public NoticeController(FcmSendService fcmSendService) {
        this.fcmSendService = fcmSendService;
    }

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
    @PostMapping("/notification/send")
    public String send(
            @RequestParam String target,     // all / marketing / dormant
            @RequestParam String title,
            @RequestParam(required = false) String body,
            @RequestParam(required = false) String sendTime,        // now / reserve
            @RequestParam(required = false) String reservationDate, // datetime-local 문자열
            RedirectAttributes ra
    ) {
        // 일단 예약은 나중에(지금은 즉시만)
        if ("reserve".equals(sendTime)) {
            ra.addFlashAttribute("msg", "예약 발송은 아직 미구현. 지금은 즉시 발송만 처리.");
            return "redirect:/admin/notification";
        }

        // target -> topic 매핑 (Flutter가 notice 구독 중이라면 all=notice는 바로 먹힘)
        String topic = switch (target) {
            case "marketing" -> "notice_marketing";
            case "dormant" -> "notice_dormant";
            default -> "notice";
        };

        fcmSendService.sendToTopic(topic, title, body == null ? "" : body);

        ra.addFlashAttribute("msg", "발송 완료(topic=" + topic + ")");
        return "redirect:/admin/notification";
    }
}
