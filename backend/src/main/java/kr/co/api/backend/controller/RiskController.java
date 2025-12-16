package kr.co.api.backend.controller;


import kr.co.api.backend.dto.ExchangeRiskDTO;
import kr.co.api.backend.service.RiskService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/risk") // 앱이 여기로 접속합니다
@RequiredArgsConstructor
public class RiskController {

    private final RiskService riskService;

    @GetMapping
    public List<ExchangeRiskDTO> getRisk(@RequestParam("date") String date) {
        System.out.println("앱에서 요청한 날짜: " + date); // 로그로 확인 가능
        return riskService.getRiskDataByDate(date);
    }






}
