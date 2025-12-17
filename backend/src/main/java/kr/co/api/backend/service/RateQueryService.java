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
}
