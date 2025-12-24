package kr.co.api.backend.controller;

import kr.co.api.backend.dto.CustInfoDTO;
import kr.co.api.backend.jwt.JwtTokenProvider;
import kr.co.api.backend.service.CustInfoService;
import kr.co.api.backend.service.MobileAuthService; // ★ 새로 만든 서비스 import
import kr.co.api.backend.service.MobileMemberService;
import kr.co.api.backend.service.SmsService;
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
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
@RestController
@RequestMapping("/api/mobile/member")
@RequiredArgsConstructor
public class MobileMemberController {

    private final CustInfoService custInfoService;
    private final JwtTokenProvider jwtTokenProvider;
    private final MobileMemberService mobileMemberService;
    private final SmsService smsService;
    private final ConcurrentHashMap<String, String> authCodeStore = new ConcurrentHashMap<>();


    // redis
    private final MobileAuthService mobileAuthService;

    @Data
    public static class LoginRequest {
        private String userid;
        private String password;
        private String deviceId;
    }



    /*
     * [STEP 0] 스플래시 화면용 기기 일치 여부 확인
     * 로그인 전에 저장된 아이디와 현재 기기 ID가 DB와 일치하는지 단순 확인
     */
    @PostMapping("/check-device")
    public ResponseEntity<?> checkDevice(@RequestBody Map<String, String> request) {
        String userId = request.get("userid");
        String deviceId = request.get("deviceId");

        CustInfoDTO user = mobileMemberService.getCustInfoByCustId(userId);

        if (user != null && deviceId.equals(user.getCustDeviceId())) {
            // 성공 시 상세 정보(Flags) 함께 반환
            Map<String, Object> response = new HashMap<>();
            response.put("status", "MATCH");

            // 1. PIN 존재 여부 (null이 아니고 비어있지 않으면 true)
            boolean hasPin = user.getCustPin() != null && !user.getCustPin().isEmpty();
            response.put("hasPin", hasPin);

            // 2. 생체인증 동의 여부 ('Y'이면 true)
            boolean useBio = "Y".equals(user.getBioAuthYn());
            response.put("useBio", useBio);

            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.ok(Map.of("status", "MISMATCH"));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> mobileLogin(@RequestBody LoginRequest request) {
        log.info("모바일 로그인 요청 - ID: {}, DeviceID: {}", request.getUserid(), request.getDeviceId());

        CustInfoDTO custInfoDTO = custInfoService.login(request.getUserid(), request.getPassword());

        if (custInfoDTO != null) {
            Boolean checkId = mobileMemberService.login(request);
            Map<String, Object> response = new HashMap<>();

            // PIN 존재 여부 확인 (공통 변수)
            boolean hasPin = custInfoDTO.getCustPin() != null && !custInfoDTO.getCustPin().isEmpty();

            if(checkId){
                // [Case 1] 기존 기기 (로그인 성공)
                log.info("인증 성공. 토큰 생성 중...");
                String token = jwtTokenProvider.createToken(custInfoDTO.getCustCode(), "USER", custInfoDTO.getCustName());

                response.put("status", "SUCCESS");
                response.put("token", token);
                response.put("custName", custInfoDTO.getCustName());
                response.put("message", "로그인 성공");

                // 성공 시에도 PIN이 있는지 알려줘야 함!
                response.put("hasPin", hasPin);

                custInfoService.saveLastLogin(custInfoDTO.getCustId());
                return ResponseEntity.ok(response);
            } else {
                // [Case 2] 새로운 기기
                // ... (기존 코드와 동일)
                response.put("status", "NEW_DEVICE");
                response.put("hasPin", hasPin); // 여기는 이미 있음
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
        String phone = request.get("phone");


        if (phone == null || phone.isEmpty()) {
            return ResponseEntity.status(400).body(Map.of("message", "전화번호가 없습니다."));
        }

        // 3. 랜덤 인증번호 6자리 생성 (예: "123456")
        String code = String.format("%06d", new Random().nextInt(999999));

        try {
            // 4. SMS 발송
            smsService.sendVerificationCode(phone, code);

            authCodeStore.put(phone, code);
            return ResponseEntity.ok(Map.of(
                    "status", "SUCCESS",
                    "message", "인증번호가 발송되었습니다."
            ));

        } catch (Exception e) {
            log.error("SMS 발송 실패", e);
            return ResponseEntity.status(500).body(Map.of("message", "SMS 발송 중 오류가 발생했습니다."));
        }
    }

    /*
     * [STEP 2] 인증번호 검증 및 확인
     * * 동작 방식:
     * 1. 사용자가 문자로 온 번호를 앱에 입력합니다.
     * 2. 앱은 아이디(userId)와 입력한 번호(code)를 서버로 보냅니다.
     * 3. 서버는 아까 저장해둔(authCodeStore) 값과 비교합니다.
     */
    @PostMapping("/auth/verify-code-hp")
    public ResponseEntity<?> verifyAuthCodeHp(@RequestBody Map<String, String> request) {
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

            return ResponseEntity.ok(Map.of("status", "SUCCESS"));
        } else {
            // 4. 인증 실패 (번호가 틀렸거나, 만료되었거나, 발송 요청을 안 했거나)
            return ResponseEntity.ok(Map.of("status", "FAIL", "message", "인증번호가 일치하지 않습니다."));
        }
    }

    /*
     * [STEP 2] 인증번호 검증 요청
     */
    @PostMapping("/auth/verify-code")
    public ResponseEntity<?> verifyAuthCode(@RequestBody Map<String, String> request) {
        String userId = request.get("userid");
        String inputCode = request.get("code");

        boolean isVerified = mobileAuthService.verifyAuthCode(userId, inputCode);

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
        log.info("dto 출력: {}", user);
        log.info("아이디: {}, 기기ID: {}", request.getUserid(), request.getDeviceId());

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

    /**
     * [설정] 생체인증 사용 여부 토글 (DB 반영)
     */
    @PostMapping("/auth/toggle-bio")
    public ResponseEntity<?> toggleBio(@RequestBody Map<String, Object> request) {
        try {
            String userId = (String) request.get("userid");

            // 앱에서 온 true/false를 'Y'/'N'으로 변환
            Boolean useBio = (Boolean) request.get("useBio");
            String useYn = (useBio != null && useBio) ? "Y" : "N";

            log.info("생체인증 설정 변경 요청: User={}, Status={}", userId, useYn);

            // 서비스 호출하여 DB 업데이트
            mobileMemberService.updateBioAuth(userId, useYn);

            // 성공 응답
            return ResponseEntity.ok(Map.of(
                    "status", "SUCCESS",
                    "message", "설정이 저장되었습니다."
            ));

        } catch (Exception e) {
            log.error("생체인증 설정 실패", e);
            return ResponseEntity.status(500).body(Map.of(
                    "status", "ERROR",
                    "message", "서버 오류가 발생했습니다."
            ));
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