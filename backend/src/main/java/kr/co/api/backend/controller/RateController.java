package kr.co.api.backend.controller;

import kr.co.api.backend.dto.RateDTO;
import kr.co.api.backend.service.RateQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/exchange")
@RequiredArgsConstructor
public class RateController {

    private final RateQueryService rateQueryService;

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


}
