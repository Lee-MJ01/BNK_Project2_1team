package kr.co.api.backend.controller;

import kr.co.api.backend.dto.CustInfoDTO;
import kr.co.api.backend.jwt.JwtTokenProvider;
import kr.co.api.backend.service.CustInfoService;
import kr.co.api.backend.service.MobileAuthService; // ★ 새로 만든 서비스 import
import kr.co.api.backend.service.MobileMemberService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/mobile/member")
@RequiredArgsConstructor
public class MobileMemberController {

    private final CustInfoService custInfoService;
    private final JwtTokenProvider jwtTokenProvider;
    private final MobileMemberService mobileMemberService;

    // redis
    private final MobileAuthService mobileAuthService;

    @Data
    public static class LoginRequest {
        private String userid;
        private String password;
        private String deviceId;
    }

    @PostMapping("/login")
    public ResponseEntity<?> mobileLogin(@RequestBody LoginRequest request) {
        log.info("모바일 로그인 요청 - ID: {}, DeviceID: {}", request.getUserid(), request.getDeviceId());

        CustInfoDTO custInfoDTO = custInfoService.login(request.getUserid(), request.getPassword());

        if (custInfoDTO != null) {
            Boolean checkId = mobileMemberService.login(request);
            Map<String, Object> response = new HashMap<>();

            // PIN 존재 여부 확인 로직
            // custPin이 null이 아니면 true, null이면 false
            boolean hasPin = custInfoDTO.getCustPin() != null && !custInfoDTO.getCustPin().isEmpty();

            if(checkId){
                log.info("인증 성공. 토큰 생성 중...");
                String token = jwtTokenProvider.createToken(custInfoDTO.getCustCode(), "USER", custInfoDTO.getCustName());

                response.put("status", "SUCCESS");
                response.put("token", token);
                response.put("custName", custInfoDTO.getCustName());
                response.put("message", "로그인 성공");

                custInfoService.saveLastLogin(custInfoDTO.getCustId());
                return ResponseEntity.ok(response);
            } else {
                log.info("다른 기기로 접근하여 추가 인증이 필요합니다.");
                response.put("status", "NEW_DEVICE");
                response.put("message", "등록되지 않은 기기입니다. 추가 인증이 필요합니다.");

                // PIN 번호 존재 여부 확인 (null이 아니고 빈 문자열이 아니면 true)
                response.put("hasPin", hasPin);

                return ResponseEntity.ok(response);
            }
        } else {
            return ResponseEntity.status(401).body("아이디 또는 비밀번호가 일치하지 않습니다.");
        }
    }

    /*
     * [STEP 1] 인증번호 발송 요청
     */
    @PostMapping("/auth/send-code")
    public ResponseEntity<?> sendAuthCode(@RequestBody Map<String, String> request) {
        String userId = request.get("userid");

        try {
            Map<String, Object> result = mobileAuthService.sendAuthCode(userId);
            return ResponseEntity.ok(result);

        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(400).body(Map.of("message", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("message", "서버 오류가 발생했습니다."));
        }
    }

    @PostMapping("/auth/send-code-hp")
    public ResponseEntity<?> sendAuthCodeWithHp(@RequestBody Map<String, String> request) {
        String phoneNumber = request.get("phone");


        if (phoneNumber == null || phoneNumber.isEmpty()) {
            return ResponseEntity.status(400).body(Map.of("message", "전화번호가 없습니다."));
        }

        // 3. 랜덤 인증번호 6자리 생성 (예: "123456")
        String code = String.format("%06d", new Random().nextInt(999999));

        try {
            // 4. SMS 발송 (DB에서 가져온 번호로 전송됨)
            smsService.sendVerificationCode(phoneNumber, code);

            // 6. 앱 화면에 보여줄 마스킹된 번호 생성 (예: 010-****-5678)
            String maskedPhone = maskPhoneNumber(phoneNumber);

            return ResponseEntity.ok(Map.of(
                    "status", "SUCCESS",
                    "message", "인증번호가 발송되었습니다.",
                    "maskedPhone", maskedPhone // 앱에서는 이 번호로 문자가 갔다고 알려줍니다.
            ));

        } catch (Exception e) {
            log.error("SMS 발송 실패", e);
            return ResponseEntity.status(500).body(Map.of("message", "SMS 발송 중 오류가 발생했습니다."));
        }
    }

    /*
     * [STEP 2] 인증번호 검증 요청
     */
    @PostMapping("/auth/verify-code")
    public ResponseEntity<?> verifyAuthCode(@RequestBody Map<String, String> request) {
<<<<<<< Updated upstream
        String userId = request.get("userid");
        String inputCode = request.get("code");

        boolean isVerified = mobileAuthService.verifyAuthCode(userId, inputCode);
=======
        String phone = request.get("phone");
        String inputCode = request.get("code"); // 사용자가 입력한 값

        // 1. 아까 저장해둔 인증번호 꺼내오기
        String savedCode = authCodeStore.get(phone);

        // 2. 비교 로직
        // savedCode != null : 발송 기록이 있어야 함
        // savedCode.equals(inputCode) : 저장된 값과 입력값이 같아야 함
        if (savedCode != null && savedCode.equals(inputCode)) {

            // 3. 인증 성공!
            // 보안을 위해 사용한 인증번호는 즉시 삭제합니다. (재사용 방지)
            authCodeStore.remove(phone);
>>>>>>> Stashed changes

        if (isVerified) {
            return ResponseEntity.ok(Map.of("status", "SUCCESS"));
        } else {
            return ResponseEntity.ok(Map.of("status", "FAIL", "message", "인증번호가 일치하지 않습니다."));
        }
    }

    /*
     * [STEP 3] 기기 등록
     */
    @PostMapping("/register-device")
    public ResponseEntity<?> registerDevice(@RequestBody LoginRequest request) {
        log.info("기기 등록 요청 - ID: {}, DeviceID: {}", request.getUserid(), request.getDeviceId());

        CustInfoDTO user = custInfoService.login(request.getUserid(), request.getPassword());
        if (user == null) {
            return ResponseEntity.status(401).body("인증 실패");
        }

        mobileMemberService.modifyCustInfoByDeviceId(user.getCustId(), request.getDeviceId());
        String token = jwtTokenProvider.createToken(user.getCustCode(), "USER", user.getCustName());

        Map<String, Object> response = new HashMap<>();
        response.put("status", "SUCCESS");
        response.put("token", token);
        response.put("custName", user.getCustName());
        response.put("message", "기기 등록 및 로그인 완료");

        custInfoService.saveLastLogin(user.getCustId());

        return ResponseEntity.ok(response);
    }

    /*
     * [STEP 4] 간편비밀번호(PIN) 등록
     */
    @PostMapping("/auth/register-pin")
    public ResponseEntity<?> registerPin(@RequestBody Map<String, String> request) {
        String userId = request.get("userid");
        String pinCode = request.get("pin");

        try {
            mobileAuthService.registerPin(userId, pinCode);
            return ResponseEntity.ok(Map.of("status", "SUCCESS", "message", "PIN 등록 완료"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("message", "PIN 등록 중 오류 발생"));
        }
    }

    /*
     * [STEP 5] 생체인증 사용 여부 설정
     */
    @PostMapping("/auth/toggle-bio")
    public ResponseEntity<?> toggleBio(@RequestBody Map<String, String> request) {
        String userId = request.get("userid");
        String useYn = request.get("useYn"); // 'Y' 또는 'N'

        try {
            mobileAuthService.updateBioAuth(userId, useYn);
            return ResponseEntity.ok(Map.of("status", "SUCCESS"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("message", "설정 변경 실패"));
        }
    }

    @PostMapping("/login-pin")
    public ResponseEntity<?> loginWithPin(@RequestBody Map<String, String> request) {
        String userId = request.get("userid");
        String inputPin = request.get("pin");
        String deviceId = request.get("deviceId");

        // 1. PIN 번호 검증 (MobileAuthService 활용)
        boolean isPinValid = mobileAuthService.verifyPin(userId, inputPin);

        if (isPinValid) {
            // 2. 기기 ID 검사
            CustInfoDTO user = mobileMemberService.getCustInfoByCustId(userId);
            if (!user.getCustDeviceId().equals(deviceId)) {
                return ResponseEntity.status(401).body(Map.of("message", "등록되지 않은 기기입니다."));
            }

            // 3. 토큰 생성 및 반환
            String token = jwtTokenProvider.createToken(user.getCustCode(), "USER", user.getCustName());
            return ResponseEntity.ok(Map.of(
                    "status", "SUCCESS",
                    "token", token,
                    "custName", user.getCustName()
            ));
        } else {
            return ResponseEntity.status(401).body(Map.of("message", "비밀번호가 틀렸습니다."));
        }
    }
}