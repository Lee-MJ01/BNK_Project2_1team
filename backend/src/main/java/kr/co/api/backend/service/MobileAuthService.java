package kr.co.api.backend.service;

import kr.co.api.backend.dto.CustInfoDTO;
import kr.co.api.backend.mapper.MobileCustInfoMapper;
import kr.co.api.backend.util.AesUtil;
import kr.co.api.backend.util.RedisUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.Random;

@Slf4j
@Service
@RequiredArgsConstructor
public class MobileAuthService {

    private final MobileMemberService mobileMemberService;
    private final SmsService smsService;
    private final RedisUtil redisUtil;
    private final MobileCustInfoMapper mobileCustInfoMapper;

    // 상수 정의 (정책)
    private static final int DAILY_SEND_LIMIT = 5; // 하루 발송 제한
    private static final int MAX_FAIL_COUNT = 5;   // 인증 실패 허용 횟수

    // PIN 암호화 용도
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    // [STEP 1] 인증번호 발송 (일일 제한 추가)
    public Map<String, Object> sendAuthCode(String userId) {

        // ★ 1. 일일 발송 횟수 확인 로직 추가
        String limitKey = "SMS_LIMIT:" + userId; // 키 예시: SMS_LIMIT:testUser
        String currentCountStr = redisUtil.getData(limitKey);

        int currentCount = 0;
        if (currentCountStr != null) {
            currentCount = Integer.parseInt(currentCountStr);
        }

        if (currentCount >= DAILY_SEND_LIMIT) {
            throw new IllegalArgumentException("일일 인증번호 전송 한도(5회)를 초과했습니다. 내일 다시 시도해주세요.");
        }

        // --- 기존 로직 시작 ---
        CustInfoDTO user = mobileMemberService.getCustInfoByCustId(userId);
        if (user == null) throw new IllegalArgumentException("사용자 정보를 찾을 수 없습니다.");

        String phoneNumber = AesUtil.decrypt(user.getCustHp());
        if (phoneNumber == null || phoneNumber.isEmpty()) throw new IllegalArgumentException("등록된 전화번호가 없습니다.");

        String code = String.format("%06d", new Random().nextInt(999999));

        try {
            smsService.sendVerificationCode(phoneNumber, code);

            // Redis에 인증번호 저장 (3분) - 키: SMS_AUTH:아이디
            redisUtil.setDataExpire("SMS_AUTH:" + userId, code, 180);

            // Redis에 실패 횟수 초기화 (인증번호를 새로 발급받았으므로)
            redisUtil.deleteData("AUTH_FAIL_COUNT:" + userId);

            // ★ 2. 일일 발송 횟수 증가시키기
            long newCount = redisUtil.increment(limitKey);
            if (newCount == 1) {
                // 처음 만들어진 키라면, 24시간(86400초) 뒤에 초기화되도록 설정
                redisUtil.setExpire(limitKey, 86400);
            }

            Map<String, Object> result = new HashMap<>();
            result.put("status", "SUCCESS");
            result.put("message", "인증번호가 발송되었습니다. (남은 횟수: " + (DAILY_SEND_LIMIT - newCount) + "회)");
            result.put("maskedPhone", maskPhoneNumber(phoneNumber));

            return result;

        } catch (Exception e) {
            log.error("SMS 발송 실패", e);
            throw new RuntimeException("SMS 발송 중 오류가 발생했습니다."); // Controller가 잡아서 500 에러 처리
        }
    }

    // [STEP 2] 인증번호 검증 (실패 횟수 제한 추가)
    public boolean verifyAuthCode(String userId, String inputCode) {
        String authKey = "SMS_AUTH:" + userId;
        String failKey = "AUTH_FAIL_COUNT:" + userId;

        // 1. 인증번호 존재 여부 확인 (시간 만료 체크)
        String savedCode = redisUtil.getData(authKey);
        if (savedCode == null) {
            return false; // 시간 만료
        }

        // ★ 2. 실패 횟수 체크
        String failCountStr = redisUtil.getData(failKey);
        int failCount = (failCountStr != null) ? Integer.parseInt(failCountStr) : 0;

        if (failCount >= MAX_FAIL_COUNT) {
            // 이미 5번 틀린 상태 -> 인증번호 강제 삭제
            redisUtil.deleteData(authKey);
            return false;
        }

        // 3. 코드 비교
        if (savedCode.equals(inputCode)) {
            // 성공 -> 데이터 삭제 후 true 반환
            redisUtil.deleteData(authKey);
            redisUtil.deleteData(failKey); // 실패 카운트도 삭제
            return true;
        } else {
            // ★ 4. 실패 시 카운트 증가
            redisUtil.increment(failKey);
            // 실패 카운트도 인증번호랑 수명을 같이 해야 함 (3분)
            redisUtil.setExpire(failKey, 180);
            return false;
        }
    }

    private String maskPhoneNumber(String phone) {
        if (phone == null || phone.length() < 10) return phone;
        String cleanPhone = phone.replaceAll("-", "");
        if (cleanPhone.length() == 11) {
            return cleanPhone.substring(0, 3) + "-****-" + cleanPhone.substring(7);
        }
        return phone;
    }

    // 간편번호(PIN) 등록
    public void registerPin(String userId, String pinCode) {
        // 1. PIN 번호 암호화
        String encodedPin = passwordEncoder.encode(pinCode);

        // 2. DB 업데이트 요청
        mobileCustInfoMapper.updateCustInfoByPIN(userId, encodedPin);
    }

    // 간편번호(PIN) 검증
    public boolean verifyPin(String userId, String inputPin) {
        CustInfoDTO user = mobileMemberService.getCustInfoByCustId(userId);
        if (user == null || user.getCustPin() == null) return false;

        // DB에 저장된 해시값과 사용자가 입력한 평문 비교
        return passwordEncoder.matches(inputPin, user.getCustPin());
    }

    // 생체인증 사용 여부 업데이트
    public void updateBioAuth(String userId, String useYn) {
        mobileCustInfoMapper.updateCustInfoByBIO(userId, useYn);
    }
}