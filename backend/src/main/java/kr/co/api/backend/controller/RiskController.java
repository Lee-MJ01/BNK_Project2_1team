package kr.co.api.backend.controller;


import kr.co.api.backend.dto.ExchangeRiskDTO;
import kr.co.api.backend.service.RiskService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/risk") // 앱이 여기로 접속합니다
@RequiredArgsConstructor
public class RiskController {

    private final RiskService riskService;

    @GetMapping("/{currency}")
    public Map<String, Object> getRisk(
            @PathVariable String currency,
            @RequestParam(value = "date", required = false) String date
    ) {
        return riskService.getRiskInfo(currency, date);
    }
}