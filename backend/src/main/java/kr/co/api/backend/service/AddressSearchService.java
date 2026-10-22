package kr.co.api.backend.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.JsonNodeFactory;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.fasterxml.jackson.databind.node.ArrayNode;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.server.ResponseStatusException;

import java.time.Duration;

@Service
public class AddressSearchService {
    private final WebClient client;
    private final String apiKey;
    private final ObjectMapper objectMapper;

    public AddressSearchService(WebClient.Builder builder, @Value("${juso.api-key:}") String apiKey, ObjectMapper objectMapper) {
        this.client = builder.baseUrl("https://business.juso.go.kr").build();
        this.apiKey = apiKey;
        this.objectMapper = objectMapper;
    }

    public JsonNode search(String keyword) {
        String query = keyword == null ? "" : keyword.trim();
        if (query.length() < 2 || query.length() > 100) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "검색어는 2~100자로 입력해 주세요.");
        }
        if (apiKey.isBlank()) {
            throw new ResponseStatusException(HttpStatus.SERVICE_UNAVAILABLE, "주소검색 설정이 필요합니다.");
        }
        try {
            String body = client.get().uri(builder -> builder
                    .path("/addrlink/addrLinkApi.do")
                    .queryParam("confmKey", "{key}")
                    .queryParam("currentPage", "1")
                    .queryParam("countPerPage", "20")
                    .queryParam("keyword", "{keyword}")
                    .queryParam("resultType", "json")
                    .build(apiKey, query))
                    .retrieve().bodyToMono(String.class).block(Duration.ofSeconds(5));
            JsonNode response = body == null ? null : objectMapper.readTree(body);
            if (response == null || !response.path("results").isObject()) {
                throw new IllegalStateException("Invalid address response");
            }
            // Return only the fields used by the app; upstream diagnostics can contain keys.
            JsonNode result = response.path("results");
            ObjectNode safe = JsonNodeFactory.instance.objectNode();
            ObjectNode safeResult = safe.putObject("results");
            safeResult.putObject("common").put("errorCode", result.path("common").path("errorCode").asText("-1"));
            ArrayNode addresses = safeResult.putArray("juso");
            if (result.path("juso").isArray()) {
                for (JsonNode address : result.path("juso")) {
                    addresses.addObject()
                            .put("zipNo", address.path("zipNo").asText())
                            .put("roadAddrPart1", address.path("roadAddrPart1").asText());
                }
            }
            return safe;
        } catch (Exception ignored) {
            // WebClient exceptions can contain the request URL (and confmKey).
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "주소검색 서비스에 연결할 수 없습니다.");
        }
    }
}
