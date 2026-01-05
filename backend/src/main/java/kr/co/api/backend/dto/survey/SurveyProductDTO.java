package kr.co.api.backend.dto.survey;

import lombok.Data;

@Data
public class SurveyProductDTO {
    private String dpstId;
    private String dpstName;
    private String dpstInfo;
    private String dpstDescript;
    private String dpstCurrency;
    private Integer dpstType;
    private Integer dpstPeriodType;
    private String dpstPartWdrwYn;
    private String dpstAddPayYn;
    private String dpstAutoRenewYn;
    private Integer periodMinMonth;
    private Integer periodMaxMonth;
    private Integer periodFixedMonth;
}
