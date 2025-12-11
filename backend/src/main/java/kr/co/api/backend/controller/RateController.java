package kr.co.api.backend.controller;


import kr.co.api.flobankapi.service.RateService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
@RequiredArgsConstructor
@RequestMapping("/rate")
public class RateController {

    private final RateService rateService;


    @GetMapping("/rate_info")
    public String rateInfoPage() {
        return "rate/rate_info";   // templates/rate/rate_info.html
    }


    @GetMapping("/rate_calc")
    public String rateCalcPage() {
        return "rate/rate_calc";   // templates/rate/rate_calc.html
    }


    @ResponseBody
    @GetMapping("/data")
    public String getRateData(@RequestParam String date) {
        return rateService.getRate(date);
    }
}