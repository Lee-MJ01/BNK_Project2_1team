package kr.co.api.backend.dto;

import com.fasterxml.jackson.databind.JsonNode;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * API 서버 -> AP 서버로 보내는 표준 요청 DTO
 */
@Data // @Getter, @Setter, @ToString, @EqualsAndHashCode 등을 자동 생성
@NoArgsConstructor // 파라미터가 없는 기본 생성자 (JSON 파싱 시 필요)
@AllArgsConstructor // 모든 필드를 인자로 받는 생성자 (이미지의 new ApRequestDTO(...)가 사용)
public class ApRequestDTO {

    /**
     * 요청 구분 코드 (필수)
     */
    private String requestCode;

    /**
     * 실제 요청 데이터 (JSON)
     */
    private JsonNode payload;

    /**
     * 요청 타임스탬프 (로깅용)
     */
    private LocalDateTime requestTimestamp;
}