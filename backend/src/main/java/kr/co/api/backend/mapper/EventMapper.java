package kr.co.api.backend.mapper;

import kr.co.api.flobankapi.dto.MemberDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface EventMapper {

    // 1) 로그인 ID로 cust_code 찾기
    String findCustCodeByCustId(String custId);

    // 2) cust_code로 회원정보 찾기
    MemberDTO getMemberInfoByCustCode(String custCode);

    // 3) 오늘 출석 여부 확인 (파라미터 2개 이상은 @Param 필수)
    int checkTodayAttendance(@Param("custCode") String custCode, @Param("attendDate") String attendDate);

    // 4) 출석 기록 저장 (파라미터 2개 이상은 @Param 필수)
    void insertAttendance(@Param("custCode") String custCode, @Param("attendDate") String attendDate);


    // 사용자 출석 날짜 목록 조회
    List<String> getAttendanceHistory(String custCode);


    // 6) 쿠폰 보유 확인
    int hasCoupon(String custCode);

    // 7) 쿠폰 발급 (파라미터: 고객코드, 랜덤우대율)
    void insertCoupon(@Param("custCode") String custCode, @Param("coupRate") int coupRate);
}
