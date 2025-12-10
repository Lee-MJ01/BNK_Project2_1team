package kr.co.api.backend.controller;

import kr.co.api.flobankapi.dto.MemberDTO;
import kr.co.api.flobankapi.jwt.CustomUserDetails;
import kr.co.api.flobankapi.service.EventService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Controller
@RequestMapping("/mypage")
@RequiredArgsConstructor
public class EventController {

    private final EventService eventService;

    @GetMapping("/event")
    public String attendance(@AuthenticationPrincipal CustomUserDetails userDetails,
                             Model model) {

        String custCode = userDetails.getUsername();


        // 1. 회원 정보 조회 (이제 null 아님!)
        MemberDTO member = eventService.getMemberInfo(custCode);

        // 2. 가입일 조회
        LocalDate joinDate = eventService.getJoinDate(member);

        // 3. 출석 히스토리 조회
        List<String> attendanceList = eventService.getAttendanceHistory(custCode);

        // 4. 오늘 출석 여부 확인
        boolean hasAttendedToday = eventService.hasAttendedToday(custCode);

        // 출석 14번 확인
        boolean isGoalReached = (attendanceList.size() >= 14);
        // 쿠폰 발급
        boolean hasCoupon = eventService.checkCouponIssued(custCode);

        model.addAttribute("isGoalReached", isGoalReached);
        model.addAttribute("hasCoupon", hasCoupon);
        model.addAttribute("member", member);
        model.addAttribute("joinDate", joinDate);
        model.addAttribute("attendanceList", attendanceList);
        model.addAttribute("hasAttendedToday", hasAttendedToday);

        return "mypage/event";
    }


    @PostMapping("/event/check-in")
    public String checkIn(@AuthenticationPrincipal CustomUserDetails userDetails,
                          RedirectAttributes redirectAttributes) {

        String custCode = userDetails.getUsername();

        try {
            // 중복 체크 (서버단에서 한 번 더 검증)
            if (eventService.hasAttendedToday(custCode)) {
                redirectAttributes.addFlashAttribute("message", "이미 오늘 출석을 완료했습니다.");
            } else {
                // 출석 기록 저장 (INSERT)
                eventService.recordAttendance(custCode);
                redirectAttributes.addFlashAttribute("message", "출석체크 완료! 포인트가 지급되었습니다.");
            }
        } catch (Exception e) {
            log.error("출석 체크 중 오류 발생", e);
            redirectAttributes.addFlashAttribute("message", "오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
        }

        // 처리가 끝나면 이벤트 페이지로 새로고침 (리다이렉트)
        return "redirect:/mypage/event";
    }



    /**
     * [POST] 쿠폰 발급 버튼 클릭 시 실행
     */
    @PostMapping("/event/coupon")
    @ResponseBody // ⭐ 이게 있어야 페이지 이동 안하고 데이터만 보냄
    public Map<String, Object> issueCoupon(@AuthenticationPrincipal CustomUserDetails userDetails) {

        Map<String, Object> response = new HashMap<>();
        String custCode = userDetails.getUsername();

        try {
            // 서비스 호출
            eventService.issueCoupon(custCode);

            // 성공 응답 생성
            response.put("success", true);
            response.put("message", "🎉 축하합니다! 쿠폰이 발급되었습니다.");
        } catch (Exception e) {
            // 실패 응답 생성
            response.put("success", false);
            response.put("message", "발급 실패: " + e.getMessage());
        }

        return response; // JSON 데이터 리턴
    }













}