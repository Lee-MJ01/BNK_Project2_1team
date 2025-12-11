package kr.co.api.backend.controller;

import kr.co.api.backend.service.EmailService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("/email")
public class EmailController {

    private final EmailService emailService;

    /**
     * 1. 인증번호 전송 (JS의 btnSendEmail 클릭 시 호출)
     */
    @PostMapping("/send")
    public ResponseEntity<Void> sendEmailCode(@RequestParam("email") String email) {

        // ⭐️ @RequestParam: 쿼리 파라미터(?email=...)로 받음
        log.info("이메일 인증번호 전송 요청: {}", email);

        try {
            // (구현 필요) emailService가 인증 코드를 생성하고 메일을 발송하도록 함
            emailService.sendCode(email);

            // ⭐️ JS는 response.ok 만 확인하므로 200 OK만 반환
            return ResponseEntity.ok().build();

        } catch (Exception e) {
            log.error("이메일 전송 실패", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * 2. 인증번호 확인 (JS의 btnVerifyEmail 클릭 시 호출)
     */
    @PostMapping("/verify")
    public ResponseEntity<Boolean> verifyEmailCode(@RequestParam("email") String email,
                                                   @RequestParam("code") String code) {

        // ⭐️ @RequestParam 2개로 이메일과 코드를 받음
        log.info("이메일 인증번호 확인 요청: email={}, code={}", email, code);

        boolean isValid = emailService.verifyCode(email, code);

        // ⭐️ JS의 const isValid = await response.json() 부분과 일치
        // true 또는 false를 JSON 형태로 반환
        return ResponseEntity.ok(isValid);
    }
}