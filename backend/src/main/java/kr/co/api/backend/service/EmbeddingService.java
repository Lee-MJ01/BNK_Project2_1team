package kr.co.api.backend.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import kr.co.api.flobankapi.dto.EmbeddingRespDTO;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;
import java.util.Map;
@Service
public class EmbeddingService {

    private final WebClient openAiWebClient;
    private final ObjectMapper objectMapper;

    public EmbeddingService(WebClient openAiWebClient, ObjectMapper objectMapper) {
        this.openAiWebClient = openAiWebClient;
        this.objectMapper = objectMapper;
    }

    public List<Double> embedText(String text) throws JsonProcessingException {

        String resJson = openAiWebClient.post()
                .uri("/embeddings")
                .bodyValue(Map.of(
                        "model", "text-embedding-3-small",
                        "input", text
                ))
                .retrieve()
                .bodyToMono(String.class)
                .block();

        EmbeddingRespDTO res = objectMapper.readValue(resJson, EmbeddingRespDTO.class);

        return res.data.get(0).embedding;
    }
}
