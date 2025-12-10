package kr.co.api.backend.dto;

import lombok.Data;

@Data
public class TermsHistDTO {

    private Long thistNo;
    private Integer thistTermCate;
    private Integer thistTermOrder;

    private String thistFile;
    private String thistContent;
    private Integer thistVersion;

    private String thistVerMemo;
    private String thistAdminId;
    private String thistRegDy;

    // 🌟 MASTER에서 가져오는 필드
    private Integer termCate;   // m.term_cate
    private Integer termOrder;  // m.term_order
    private String termTitle;   // m.term_title


    private Integer tranBalance;
}
