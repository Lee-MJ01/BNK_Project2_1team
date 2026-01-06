package kr.co.api.backend.controller;

import kr.co.api.backend.dto.FrgnExchOnlineDTO;
import kr.co.api.backend.dto.RateDTO;
import kr.co.api.backend.jwt.CustomUserDetails;
import kr.co.api.backend.service.OnlineExchangeService;
import kr.co.api.backend.service.RateQueryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/mobile/exchange")
@RequiredArgsConstructor
public class OnlineExchangeController {

    private final OnlineExchangeService onlineExchangeService;
    private final RateQueryService rateQueryService;

    // 환전 시, 약관 동의 여부 확인
    @GetMapping("/check-terms")
    public ResponseEntity<Boolean> checkTerms(Authentication authentication) {
        String custCode = authentication.getName(); // custCode
        return ResponseEntity.ok(onlineExchangeService.isTermsAgreed(custCode));
    }

    // 환전 전, 약관 동의 삽입
    @PostMapping("/agree-terms")
    public ResponseEntity<String> agreeTerms(Authentication authentication) {
        String custCode = authentication.getName(); // custCode
        onlineExchangeService.saveTermsAgreement(custCode);
        return ResponseEntity.ok("Success");
    }

    /**
     * 환율 목록 (통화별 최신 1건)
     */
    @GetMapping("/rates")
    public List<RateDTO> getRates() {
        return rateQueryService.getLatestRates();
    }

    /**
     * 특정 통화 환율 히스토리
     */
    @GetMapping("/rates/{currency}")
    public List<RateDTO> getRateHistory(
            @PathVariable String currency
    ) {
        return rateQueryService.getRateHistory(currency);
    }

    /**
     * 온라인 환전 요청
     */
    @PostMapping("/online")
    public ResponseEntity<?> onlineExchange(
            @RequestBody FrgnExchOnlineDTO dto,
            Authentication authentication
    ) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(401).body(Map.of("message", "Unauthorized"));
        }

        // 1. ID 추출 통일
        String custCode = authentication.getName();

        onlineExchangeService.processOnlineExchange(dto, custCode);

        return ResponseEntity.ok("온라인 환전이 정상적으로 처리되었습니다.");
    }

    /**
     * 내 환전 계좌 조회
     */
    @GetMapping("/accounts")
    public ResponseEntity<?> getMyExchangeAccounts(
            @RequestParam String currency,
            Authentication authentication
    ) {

        // 인증 체크
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(401).body(Map.of("message", "Unauthorized"));
        }

        String custCode = authentication.getName(); // custCode 출력됨

        Map<String, Object> result = onlineExchangeService.getMyExchangeAccounts(custCode, currency);

        return ResponseEntity.ok(result);
    }






}
