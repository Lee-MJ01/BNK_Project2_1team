package kr.co.api.backend.controller.common;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.Map;

@Slf4j
@Controller
@RequiredArgsConstructor
public class CertController {

    // 1. [API] 인증 초기화
    @ResponseBody
    @PostMapping("/api/cert/init")
    public ResponseEntity<?> initCert(HttpSession session) {
        session.setAttribute("CERT_STATUS", "PENDING");
        return ResponseEntity.ok(Map.of("status", "success"));
    }

    // 2. [View] 통합 인증 팝업 화면 (화면 1~7 흐름 포함)
    @GetMapping("/mock/kakao/auth")
    public String viewKakaoAuth(@RequestParam(defaultValue = "전자서명") String title,
                                @RequestParam(defaultValue = "0") String amount,
                                Model model) {
        model.addAttribute("title", title);
        model.addAttribute("amount", amount);
        return "common/kakao_auth_popup"; // 아래 HTML 파일로 연결
    }

    // 3. [API] 인증 완료 처리 (팝업에서 최종 완료 시 호출)
    @ResponseBody
    @PostMapping("/api/cert/complete")
    public ResponseEntity<?> completeCert(HttpSession session) {
        // 실제로는 외부 인증 기관의 응답을 검증해야 하지만, 여기선 시뮬레이션이므로 성공 처리
        session.setAttribute("CERT_STATUS", "COMPLETE");
        return ResponseEntity.ok(Map.of("status", "success"));
    }

    // 4. [API] 인증 상태 확인 (부모창 Polling 용)
    @ResponseBody
    @GetMapping("/api/cert/check")
    public ResponseEntity<?> checkCertStatus(HttpSession session) {
        String status = (String) session.getAttribute("CERT_STATUS");
        if ("COMPLETE".equals(status)) {
            // session.removeAttribute("CERT_STATUS"); // 필요 시 주석 해제 (1회성)
            return ResponseEntity.ok(Map.of("status", "complete"));
        } else {
            return ResponseEntity.ok(Map.of("status", "pending"));
        }
    }
}