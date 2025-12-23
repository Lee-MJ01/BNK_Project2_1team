package kr.co.api.backend.service;

import kr.co.api.backend.dto.RateDTO;
import kr.co.api.backend.mapper.RateMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class RateQueryService {

    private final RateMapper rateMapper;

    /**
     * 통화별 최신 환율 조회
     */
    public List<RateDTO> getLatestRates() {
        return rateMapper.selectLatestRates();
    }

    /**
     * 특정 통화 환율 히스토리 조회
     */
    public List<RateDTO> getRateHistory(String currency) {
        return rateMapper.selectRateHistory(currency);
    }

    public List<RateDTO> getLatestRatesWithChange() {
        return rateMapper.selectLatestRatesWithChange();
    }


    /**
     * 단일 통화의 최신 환율 1건 조회
     * TB_EXCH_RATE_HIST 에 저장된 가장 최근 고시일 데이터를 사용한다.
     */
    public RateDTO getLatestRateForCurrency(String currency) {
        if (currency == null || currency.isBlank()) {
            return null;
        }
        return rateMapper.selectLatestRate(currency);
    }




}
