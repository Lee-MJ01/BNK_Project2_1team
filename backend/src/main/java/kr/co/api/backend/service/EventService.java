package kr.co.api.backend.service;

import kr.co.api.flobankapi.dto.MemberDTO;
import kr.co.api.flobankapi.mapper.EventMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
@RequiredArgsConstructor
public class EventService {

    private final EventMapper eventMapper;

    /** 1) 로그인 ID(cust_id) → cust_code 조회 */
    public String getCustCode(String custId) {
        return eventMapper.findCustCodeByCustId(custId);
    }

    /** 2) cust_code로 회원 정보 조회 */
    public MemberDTO getMemberInfo(String custCode) {
        return eventMapper.getMemberInfoByCustCode(custCode);
    }

    /** 3) 가입일 반환 (수정됨: 시간 정보 제거) */
    public LocalDate getJoinDate(MemberDTO member) {
        if (member == null) {
            throw new RuntimeException("회원 정보가 없습니다.");
        }

        String regDt = member.getCustRegDt(); // "2025-11-18 08:00:16"

        if (regDt == null || regDt.isEmpty()) {
            return LocalDate.now();
        }

        // ▼▼▼ [수정] 시간이 포함되어 있으면 앞 10자리(yyyy-MM-dd)만 자름
        if (regDt.length() > 10) {
            regDt = regDt.substring(0, 10);
        }

        return LocalDate.parse(regDt, DateTimeFormatter.ofPattern("yyyy-MM-dd"));
    }

    /** 4) 오늘 출석 여부 확인 (true: 이미 출석함, false: 출석 안함) */
    public boolean hasAttendedToday(String custCode) {
        // DB가 CHAR(8)이므로 "20251118" 형태로 변환
        String today = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));

        int count = eventMapper.checkTodayAttendance(custCode, today);
        return count > 0;
    }

    /** 5) 출석 기록 저장 (트랜잭션 처리) */
    @Transactional
    public void recordAttendance(String custCode) {
        String today = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        eventMapper.insertAttendance(custCode, today);
    }

    /** 6) 출석 히스토리 조회 */
    public List<String> getAttendanceHistory(String custCode) {
        return eventMapper.getAttendanceHistory(custCode);
    }


    /** 7) 쿠폰 발급 여부 확인 */
    public boolean checkCouponIssued(String custCode) {
        return eventMapper.hasCoupon(custCode) > 0;
    }

    /** 8) 쿠폰 발급하기 (랜덤 우대율 적용) */
    @Transactional
    public void issueCoupon(String custCode) {

        if (checkCouponIssued(custCode)) {
            throw new RuntimeException("이미 쿠폰을 발급받았습니다.");
        }

        // 2. 랜덤 우대율(10~100 10씩 뜀)
        int randomRate = ((int) (Math.random() * 10) + 1) * 10;

        // 3. DB에 저장
        eventMapper.insertCoupon(custCode, randomRate);
    }




}