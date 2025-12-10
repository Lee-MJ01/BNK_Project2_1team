package kr.co.api.backend.service;

import com.solapi.sdk.NurigoApp;
import com.solapi.sdk.message.exception.SolapiEmptyResponseException;
import com.solapi.sdk.message.exception.SolapiMessageNotReceivedException;
import com.solapi.sdk.message.exception.SolapiUnknownException;
import com.solapi.sdk.message.model.Message;
import com.solapi.sdk.message.service.DefaultMessageService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class SmsService {

    private final DefaultMessageService messageService;

    @Value("${solapi.phoneNumber}")
    private String fromNumber;

    public SmsService(
            @Value("${solapi.apiKey}") String apiKey,
            @Value("${solapi.apiSecret}") String apiSecret
    ) {
        this.messageService = NurigoApp.INSTANCE.initialize(apiKey, apiSecret, "https://api.solapi.com");
    }

    // 인증번호 전송
    public void sendVerificationCode(String to, String code) throws SolapiEmptyResponseException, SolapiUnknownException, SolapiMessageNotReceivedException {
        Message message = new Message();
        message.setFrom(fromNumber);
        message.setTo(to);
        message.setText("[FLOBANK] 인증번호는 " + code + " 입니다.");
        if (fromNumber == null || fromNumber.isBlank()) {
            throw new IllegalStateException("발신번호(fromNumber)가 설정되지 않았습니다.");
        }

        try {
            messageService.send(message);
            System.out.println("[SMS] 인증번호 전송 성공: " + to);
        } catch (Exception e) {
            System.err.println("[SMS] 전송 실패: " + e.getMessage());
            throw e;
        }
    }
}