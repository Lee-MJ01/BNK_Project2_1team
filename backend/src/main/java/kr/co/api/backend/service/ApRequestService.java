package kr.co.api.backend.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import kr.co.api.flobankapi.dto.ApRequestDTO;
import kr.co.api.flobankapi.dto.ApResponseDTO;
import kr.co.api.flobankapi.tcp.ApGateway;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;

/**
 * [공통 서비스]
 * 모든 비즈니스 서비스(Member, Exchange 등)가 AP 서버와 통신할 때 사용하는
 * 공용 TCP 요청/응답 처리기입니다.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ApRequestService {

    private final ApGateway apGateway;       // TCP 통신 게이트웨이
    private final ObjectMapper objectMapper; // JSON 변환기

    /**
     * AP 서버로 요청을 보내고 표준 응답(ApResponseDTO)을 받습니다.
     *
     * @param requestCode        AP 서버의 RequestRouterService가 사용할 요청 코드 (예: "MEMBER_REGISTER")
     * @param payload            AP 서버로 보낼 실제 데이터 객체 (예: MemberDTO, ExchangeDTO 등)
     * @param apResponseDTOClass
     * @return AP 서버로부터 받은 표준 응답(ApResponseDTO)
     */
    public ApResponseDTO execute(String requestCode, Object payload, Class<ApResponseDTO> apResponseDTOClass) {

        String jsonRequest = "";
        try {
            // 1. Payload 객체를 JsonNode로 변환
            JsonNode payloadNode = objectMapper.valueToTree(payload);

            // 2. 표준 요청 DTO(ApRequestDTO) 생성
            ApRequestDTO requestDTO = new ApRequestDTO(
                    requestCode,
                    payloadNode,
                    LocalDateTime.now()
            );

            // 3. DTO -> JSON 문자열로 변환
            jsonRequest = objectMapper.writeValueAsString(requestDTO);
            log.info("[TCP SEND] RequestCode: {}, Payload: {}", requestCode, jsonRequest);

            // 4. 게이트웨이를 통해 AP 서버로 전송 및 응답 수신 (핵심)
            // [수정] String이 아닌 byte[]로 직접 통신하도록 변경
            byte[] responseBytes = apGateway.sendAndReceive(jsonRequest.getBytes(StandardCharsets.UTF_8));

            // 5. [수정] byte[] 응답을 UTF-8 문자열로 변환
            String jsonResponse = new String(responseBytes, StandardCharsets.UTF_8);
            log.info("[TCP RECV] Response: {}", jsonResponse);

            // 6. JSON 응답 -> 표준 응답 DTO(ApResponseDTO)로 변환
            ApResponseDTO responseDTO = objectMapper.readValue(jsonResponse, ApResponseDTO.class);

            // 7. AP 서버가 에러를 반환했는지 확인
            if ("ERROR".equals(responseDTO.getStatus())) {
                log.warn("[AP_SERVER_ERROR] Code: {}, Message: {}", requestCode, responseDTO.getMessage());
            }

            return responseDTO;

        } catch (Exception e) {
            // TCP 통신 실패 (타임아웃, 서버 다운 등) 또는 JSON 파싱 실패
            log.error("[TCP_CLIENT_ERROR] Request: {} | Error: {}", jsonRequest, e.getMessage(), e);

            // AP 서버와 통신 자체가 실패했을 때 클라이언트(컨트롤러)에게 보낼 공통 에러 DTO
            return new ApResponseDTO(
                    "ERROR",
                    "AP 서버와 통신 중 오류가 발생했습니다: " + e.getMessage(),
                    null,
                    LocalDateTime.now()
            );
        }
    }
}