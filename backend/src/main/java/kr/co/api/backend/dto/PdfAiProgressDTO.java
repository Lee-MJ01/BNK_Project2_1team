package kr.co.api.backend.dto;

import lombok.Data;

@Data
public class PdfAiProgressDTO {
    private Long pdfId;
    private int progress;
}
