package kr.co.api.backend.dto;

import lombok.Data;

@Data
public class BriefingViewDTO {
    private String briefingMode;
    private String briefingTitle;
    private String briefingDateText;
    private String[] briefingLines;
}
