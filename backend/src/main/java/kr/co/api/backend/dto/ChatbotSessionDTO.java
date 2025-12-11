package kr.co.api.backend.dto;

import lombok.*;

@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class ChatbotSessionDTO {
    private String sessId;
    private String sessCustCode;
    private String sessStartDt;
}
