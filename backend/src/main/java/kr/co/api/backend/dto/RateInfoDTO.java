package kr.co.api.backend.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
@JsonIgnoreProperties(ignoreUnknown = true) // 필요 없는 필드는 무시
public class RateInfoDTO {
    @JsonProperty("cur_unit")
    private String curUnit;    // 통화코드 (USD, JPY(100) 등)

    @JsonProperty("cur_nm")
    private String curNm;      // 국가/통화명

    @JsonProperty("deal_bas_r")
    private String dealBasR;   // 매매 기준율 (문자열로 오므로 쉼표 제거 필요)

    @JsonProperty("bkpr")
    private String bkpr;       // 장부가격

    @JsonProperty("ttb")
    private String ttb; // 송금 받을 때

    @JsonProperty("tts")
    private String tts; // 송금 보낼 때
}
