package kr.co.api.backend.dto;

import lombok.Data;

@Data
public class TermsDTO {
    private Integer termCate;
    private Integer termOrder;
    private String termTitle;
    private String termContent;
}
