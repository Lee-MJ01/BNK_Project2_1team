package kr.co.api.backend.dto.translate;

import lombok.Data;

@Data
public class TranslationRequestDTO {
    private String text;
    private String targetLang;
}
