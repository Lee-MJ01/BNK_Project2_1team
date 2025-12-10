package kr.co.api.backend.service;

import jakarta.mail.Message;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import java.util.concurrent.ThreadLocalRandom;

// EmailService.java

@Slf4j
@RequiredArgsConstructor
@Service
public class EmailService {

    private final JavaMailSender mailSender;

    @Autowired
    private HttpSession session; // ⭐️ 이 세션을 직접 활용

    @Value("${spring.mail.username}")
    private String sender;

    public void sendCode(String receiver) {
        MimeMessage message = mailSender.createMimeMessage();
        int code = ThreadLocalRandom.current().nextInt(100000, 1000000);
        String title = "FLOBANK 인증코드 입니다.";
        String content = "<h1>인증코드는 " + code + "입니다.</h1>";

        try {
            message.setFrom(new InternetAddress(sender, "보내는 사람", "UTF-8"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(receiver));
            message.setSubject(title);
            message.setContent(content, "text/html;charset=UTF-8");
            mailSender.send(message);

            // 세션에 "이메일 주소"를 키로 하여 코드를 저장
            session.setAttribute(receiver, String.valueOf(code));

        } catch (Exception e) {
            log.error(e.getMessage());
        }
    }

    // 시그니처에 email 파라미터 추가
    public boolean verifyCode(String email, String code) {

        // 세션에서 "이메일 주소" 키로 코드를 가져옴
        String sessCode = (String) session.getAttribute(email);
        // String sessCode = sessionData.getCode();

        // 널 체크 및 코드 일치 여부 확인
        if (sessCode != null && sessCode.equals(code)) {
            // (선택) 인증 성공 시 세션에서 코드 제거
            session.removeAttribute(email);
            return true;
        }

        return false;
    }
}