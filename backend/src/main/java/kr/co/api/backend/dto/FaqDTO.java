package kr.co.api.backend.dto;

import lombok.Data;

@Data
public class FaqDTO {

    private Long faqNo;        // faq_no
    private String faqAdminId; // faq_admin_id
    private Integer faqCate;   // faq_cate
    private String faqQuestion;// faq_question
    private String faqAnswer;  // faq_answer
}
