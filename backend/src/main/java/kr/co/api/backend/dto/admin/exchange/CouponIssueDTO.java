package kr.co.api.backend.dto.admin.exchange;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CouponIssueDTO {
    private Integer couponNo;
    private String custCode;
    private Integer coupRate;
    private String issuedDate;
    private Integer coupStatus;

}