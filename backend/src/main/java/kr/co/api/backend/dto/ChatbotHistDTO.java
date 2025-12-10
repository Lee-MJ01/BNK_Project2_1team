package kr.co.api.backend.dto;

import lombok.*;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class ChatbotHistDTO {
    private int botNo;
    private String botContent;
    private int botType;
    private String botDt;
    private String botSessId;
}
