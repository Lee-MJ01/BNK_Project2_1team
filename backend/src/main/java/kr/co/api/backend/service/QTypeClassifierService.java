package kr.co.api.backend.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class QTypeClassifierService {

    private final WebClient openAiWebClient;

    public String detectTypeByGPT(String question) throws JsonProcessingException {

        String systemPrompt =
                "사용자 질문이 요구하는 문서 유형을 판단해라.\n" +
                "부산은행 금리는 interest, 예금은 product\n" +
                        "반드시 아래 중 하나만 출력한다:\n" +
                        "- Interest\n" +
                        "- ProductInfo\n" +
                        "- FxRateGlossary\n" +
                        "- DepositGlossary\n" +
                        "- AccountTranGlossary\n" +
                        "- null\n" +
                        "설명 금지. 한 단어만 출력.";

        Map<String, Object> requestBody = Map.of(
                "model", "gpt-4.1-mini",
                "messages", List.of(
                        Map.of("role", "system", "content", systemPrompt),
                        Map.of("role", "user", "content", question)
                ),
                "max_tokens", 10,
                "temperature", 0
        );

        // WebClient 호출
        String response = openAiWebClient.post()
                .uri("/chat/completions")
                .bodyValue(requestBody)
                .retrieve()
                .bodyToMono(String.class)
                .block();

        // JSON 파싱
        ObjectMapper mapper = new ObjectMapper();
        JsonNode root = mapper.readTree(response);

        String content = root
                .path("choices").get(0)
                .path("message")
                .path("content")
                .asText()
                .trim();

        return content;
    }

    public String detectQueryByGPT(String question) throws JsonProcessingException {

        String systemPrompt =
                "사용자 질문이 요구하는 db 조회 쿼리문을 판단해라.\n" +
                        "우리 은행의 이름은 플로뱅크다.\n" +
                        "플로뱅크에서 판매하는 상품(product)은 예금\n" +
                        "반드시 아래 중 하나만 출력한다:\n" +
                        "- flobankDepositProduct\n" +
                        "- flobankInterest\n" +
                        "- registerTerms\n" +
                        "- fxTerms\n" +
                        "- remitTerms\n" +
                        "- depositTerms\n" +
                        "- krwAcctTerms\n" +
                        "- fxAcctTerms\n" +
                        "- null\n" +
                        "설명 금지. 한 단어만 출력.";

        Map<String, Object> requestBody = Map.of(
                "model", "gpt-4.1-mini",
                "messages", List.of(
                        Map.of("role", "system", "content", systemPrompt),
                        Map.of("role", "user", "content", question)
                ),
                "max_tokens", 10,
                "temperature", 0
        );

        // WebClient 호출
        String response = openAiWebClient.post()
                .uri("/chat/completions")
                .bodyValue(requestBody)
                .retrieve()
                .bodyToMono(String.class)
                .block();

        // JSON 파싱
        ObjectMapper mapper = new ObjectMapper();
        JsonNode root = mapper.readTree(response);

        String content = root
                .path("choices").get(0)
                .path("message")
                .path("content")
                .asText()
                .trim();

        return content;
    }

}
