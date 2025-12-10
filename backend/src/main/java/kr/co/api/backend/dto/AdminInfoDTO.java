package kr.co.api.backend.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AdminInfoDTO {

    private String adminId;
    private String adminPw;
    private Integer adminType;
    private String adminHp ;

}
