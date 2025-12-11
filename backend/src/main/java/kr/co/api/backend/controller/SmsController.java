package kr.co.api.backend.controller;

import com.solapi.sdk.message.exception.SolapiEmptyResponseException;
import com.solapi.sdk.message.exception.SolapiMessageNotReceivedException;
import com.solapi.sdk.message.exception.SolapiUnknownException;
import kr.co.api.flobankapi.service.SmsService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

@RestController
@RequestMapping("/sms")
public class SmsController {

    private final SmsService solapiService;
    private final ConcurrentHashMap<String, String> verificationCodes = new ConcurrentHashMap<>();
    private final ConcurrentHashMap<String, Long> codeTimestamps = new ConcurrentHashMap<>();
    private static final long CODE_EXPIRE_MS = 3 * 60 * 1000; // 3분

    public SmsController(SmsService solapiService) {
        this.solapiService = solapiService;
    }

    @PostMapping("/send")
    public Map<String, Object> sendCode(@RequestParam String phoneNumber) throws SolapiEmptyResponseException, SolapiUnknownException, SolapiMessageNotReceivedException {
        String code = String.format("%06d", new Random().nextInt(999999));
        solapiService.sendVerificationCode(phoneNumber, code);
        verificationCodes.put(phoneNumber, code);
        codeTimestamps.put(phoneNumber, System.currentTimeMillis());
        return Map.of("result", "success", "message", "인증번호 전송 완료");
    }

    @PostMapping("/verify")
    public boolean verifyCode(@RequestParam String phoneNumber, @RequestParam String code) {
        String savedCode = verificationCodes.get(phoneNumber);
        Long timestamp = codeTimestamps.get(phoneNumber);

        if (savedCode == null || timestamp == null) return false;
        if (System.currentTimeMillis() - timestamp > CODE_EXPIRE_MS) {
            verificationCodes.remove(phoneNumber);
            codeTimestamps.remove(phoneNumber);
            return false; // 만료됨
        }
        return savedCode.equals(code);
    }
}