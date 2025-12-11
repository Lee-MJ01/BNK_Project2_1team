package kr.co.api.backend.dto;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class MypageDpstDTO {
    // 계좌 헤더 정보
    private String dpstHdrAcctNo;
    private String dpstHdrDpstId;
    private String dpstHdrPw;
    private String dpstHdrCustCode;
    private int dpstHdrMonth;
    private String dpstHdrStartDy;
    private String dpstHdrFinDy;
    private String dpstHdrCurrency;
    private String dpstHdrCurrencyExp;
    private BigDecimal dpstHdrBalance;
    private BigDecimal dpstHdrInterest;
    private BigDecimal dpstHdrRate;
    private int dpstHdrStatus;
    private String dpstHdrLinkedAcctNo;
    private int dpstHdrLinkedAcctType;
    private String dpstHdrAutoRenewYn;
    private int dpstHdrAutoRenewCnt;
    private int dpstHdrAutoRenewTerm;
    private String dpstHdrAutoTermiYn;
    private int dpstHdrAddPayCnt;
    private int dpstHdrPartWdrwCnt;

    // 예금 상품 정보
    private String dpstId;
    private String dpstName;
    private int dpstType;
    private int dpstRateType;
    private String dpstPartWdrwYn;
    private String dpstAddPayYn;
    private int dpstAddPayMax;

    // 예금 상품 중도인출 정보
    private int wdrwMinMonth;
    private int wdrwMax;
    private int amtMin;

    // 최초 계약 잔액
    private BigDecimal dpstDtlInitialbal;
    private String firstTranDt;
    private int tranCnt;
    private String lastTranDt;

}
