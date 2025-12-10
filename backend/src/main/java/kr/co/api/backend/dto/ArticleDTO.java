package kr.co.api.backend.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class ArticleDTO {
    private Long articleId;
    private String company;
    private String category;
    private String title;
    private String url;
    private LocalDateTime writtenAt;
    private String summary;
    private String summaryAi;
    private String content;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
