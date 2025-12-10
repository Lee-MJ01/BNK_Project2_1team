package kr.co.api.backend.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class PdfAiDTO {
    private Long pdfId;
    private String orgFileName;
    private String storedFileName;
    private String filePath;
    private String extractedText;
    private String aiComment;
    private String aiOverallRisk;
    private String status;
    private String errorMessage;

    //추가
    private String downloadUrl;

    // 상품 기본 정보
    private String productName;
    private String productShortDesc;
    private String productFeatures;
    private String depositType;
    private String currencies;
    private String exchangeRatePolicy;
    private String termType;
    private Integer minMonth;
    private Integer maxMonth;
    private String eligibility;
    private String partialWithdrawal;
    private String autoRenewal;
    private String additionalDeposit;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

}