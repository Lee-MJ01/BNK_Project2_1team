package kr.co.api.backend.dto;

import lombok.Data;

@Data
public class ChatbotAdminDTO {
    int botNo;
    String userQuestion;
    String botAnswer;
    String botDt;
}
