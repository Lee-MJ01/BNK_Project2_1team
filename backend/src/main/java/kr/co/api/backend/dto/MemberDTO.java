package kr.co.api.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;


@Data
@AllArgsConstructor
@NoArgsConstructor
public class MemberDTO {
    private String custCode;
    private String custId;
    private String custPw;
    private String custName;
    private String custJumin;
    private String custEmail;
    private String custHp;
    private String custBirth;
    private String custGen;
    private String custEngName;
    private String custRegDt;
    private Integer custStatus;
    private String custZip;
    private String custAddr1;
    private String custAddr2;
    private Integer custTransLimit;
    private String custLastLoginDt;
    private String custNation;
    private String custUpdDt;
}
