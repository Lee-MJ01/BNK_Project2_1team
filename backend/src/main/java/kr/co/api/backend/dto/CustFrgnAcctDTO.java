package kr.co.api.backend.dto;

import lombok.Data;

@Data
public class CustFrgnAcctDTO {
    private String frgnAcctNo;
    private String frgnAcctPw;
    private String frgnAcctRegDt;
    private Integer frgnAcctStatus;
    private String frgnAcctCustEngName;
    private String frgnAcctCustCode;
    private String frgnAcctFundSource;
    private String frgnPurpose;
    private String frgnAcctName;
}
