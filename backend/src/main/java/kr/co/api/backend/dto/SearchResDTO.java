package kr.co.api.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import java.util.Map;

@Getter
@Setter
@ToString
@AllArgsConstructor
public class SearchResDTO {
    private String id;
    private double score;
    private Map<String, Object> metadata;
}
