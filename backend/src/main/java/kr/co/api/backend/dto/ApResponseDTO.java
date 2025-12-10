package kr.co.api.backend.dto;

import com.fasterxml.jackson.databind.JsonNode;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * AP 서버 -> API 서버로 반환하는 표준 응답 DTO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ApResponseDTO {

    /**
     * 처리 상태 (필수)
     */
    private String status;

    /**
     * 처리 메시지
     */
    private String message;

    /**
     * 실제 응답 데이터 (JSON)
     */
    private JsonNode data;

    /**
     * 응답 타임스탬프 (로깅용)
     */
    private LocalDateTime responseTimestamp;

    public static ApResponseDTO ok() {
        return new ApResponseDTO("OK", null, null, LocalDateTime.now());
    }

    public static ApResponseDTO ok(JsonNode data) {
        return new ApResponseDTO("OK", null, data, LocalDateTime.now());
    }

    public static ApResponseDTO ok(String message, JsonNode data) {
        return new ApResponseDTO("OK", message, data, LocalDateTime.now());
    }

    public static ApResponseDTO fail(String message) {
        return new ApResponseDTO("FAIL", message, null, LocalDateTime.now());
    }

    public boolean isSuccess() {
        return "OK".equalsIgnoreCase(status);
    }
}