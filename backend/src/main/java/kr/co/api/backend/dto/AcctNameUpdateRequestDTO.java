package kr.co.api.backend.dto;

import lombok.Data;

@Data
public class AcctNameUpdateRequestDTO {
    private String acctNo;
    private String acctName;
    private String acctType;
}
