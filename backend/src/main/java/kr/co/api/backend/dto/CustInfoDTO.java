package kr.co.api.backend.dto;

import lombok.Data;

import java.time.LocalDate;

@Data
public class CustInfoDTO {
    private String custCode;
    private String custId;
    private String custPw;              // 단방향 암호화
    private String custName;
    private String custJumin;           // 양방향 암호화
    private String custEmail;
    private String custHp;              // 양방향 암호화
    private LocalDate custBirthDt;
    private String custGen;
    private String custEngName;
    private String custRegDt;
    private Integer custStatus;
    private String custZip;
    private String custAddr1;
    private String custAddr2;
    private Integer custSecurityLevel;  // 보안 등급
    private String custLastLoginDt;
    private String custDeviceId;
    private String custMailAgree;
    private String custPhoneAgree;
    private String custEmailAgree;
    private String custSmsAgree;
    private String custPin;             // 추가: 간편인증번호 (해싱된 값)
    private String bioAuthYn;           // 추가: 생체인증 사용 여부 (Y/N)

    // 추가 필드
    private String custMaskHp;

}
