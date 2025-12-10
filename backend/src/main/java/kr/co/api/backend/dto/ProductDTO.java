package kr.co.api.backend.dto;


import lombok.Data;

import java.time.LocalDate;
import java.util.List;

@Data
public class ProductDTO {
    private String dpstId;                 // DB 트리거가 자동생성함
    private String dpstName;               // VARCHAR2(200)
    private String dpstInfo;               // VARCHAR2(100)
    private Integer dpstType;              // NUMBER
    private String dpstCurrency;           // VARCHAR2(200)
    private Integer dpstRateType;          // NUMBER
    private String dpstMinYn;              // CHAR(1)
    private String dpstMaxYn;              // CHAR(1)
    private Integer dpstStatus;            // NUMBER
    private String dpstDescript;           // VARCHAR2(100)
    private Integer dpstPeriodType;        // NUMBER
    private Integer dpstMinAge;            // NUMBER
    private Integer dpstMaxAge;            // NUMBER
    private String dpstAutoRenewYn;        // CHAR(1)
    private String dpstAddPayYn;           // CHAR(1)
    private Integer dpstAddPayMax;         // NUMBER
    private String dpstPartWdrwYn;         // CHAR(1)
    private LocalDate dpstRegDt;
    private String dpstAppNo;               // VARCHAR2(50)
    private String dpstAppInstitution;     // VARCHAR2(50)
    private String dpstAppDy;              // CHAR(8)
    private String dpstDelibNo;            // CHAR(9)
    private String dpstDelibDy;            // CHAR(8)
    private String dpstDelibStartDy;       // CHAR(8)
    private String dpstInfoPdf;



    // 통화코드별 한도금액
    private List<ProductLimitDTO> limits;
    // 통화코드 목록
    private List<CurrencyInfoDTO> dpstCurrencyDtoList;
    private List<String> dpstCurrencyList;

    // 분할인출
    private Integer wdrwMinMonth;
    private Integer wdrwMax;
    private String amtCurrency;
    private Integer amtMin;
    // 통화코드별 분할인출 최소금액
    private List<ProductWithdrawAmtDTO> withdrawMinAmtList;

    // 예치 기간
    private Integer periodMinMonth;
    private Integer periodMaxMonth;
    private Integer periodFixedMonth;
    // 고정 기간 목록
    private List<Integer> periodFixedMonthList;

    // 가입 금액 제한
    private String lmtCurrency;
    private Integer lmtMinAmt;
    private Integer lmtMaxAmt;


    private List<ProductPeriodDTO> periodList;

}
