package kr.co.api.backend.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import kr.co.api.flobankapi.dto.SearchResDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class PineconeService {

    private final WebClient pineconeClient;
    private final ObjectMapper objectMapper;


    public void upsert(String id, List<Double> embedding, Map<String, Object> metadata, String namespace) {
        float[] floatEmbedding = new float[embedding.size()];
        for (int i = 0; i < embedding.size(); i++) {
            floatEmbedding[i] = embedding.get(i).floatValue();
        }


        log.info("metadata  = " + metadata);
        Map<String, Object> requestBody = Map.of(
                "vectors", List.of(
                        Map.of(
                                "id", id,
                                "values", floatEmbedding,
                                "metadata", metadata
                        )
                ),
                "namespace", namespace
        );

        try {
            // (2) JSON 문자열로 변환해서 출력 — 에러 원인 99% 여기서 보임
            String jsonBody = new ObjectMapper().writeValueAsString(requestBody);
            log.info("📌 UPSERT JSON BODY = {}", jsonBody);
        } catch (Exception e) {
            log.error("❌ JSON 변환 실패", e);
        }



        pineconeClient.post()
                .uri("/vectors/upsert")
                .bodyValue(requestBody)
                .retrieve()
                .bodyToMono(String.class)
                .block();

//        try {
//            String response = pineconeClient.post()
//                    .uri("/vectors/upsert")
//                    .bodyValue(requestBody)
//                    .retrieve()
//                    .onStatus(
//                            status -> status.is4xxClientError() || status.is5xxServerError(),
//                            clientResponse -> clientResponse.bodyToMono(String.class)
//                                    .map(errorBody -> {
//                                        System.err.println("🔥 Pinecone ERROR Status = " + clientResponse.statusCode());
//                                        System.err.println("🔥 Pinecone ERROR Body   = " + errorBody);
//                                        return new RuntimeException("Pinecone error: " + errorBody);
//                                    })
//                    )
//                    .bodyToMono(String.class)
//                    .block();
//
//            System.out.println("Pinecone Upsert Response = " + response);
//
//        } catch (Exception e) {
//            e.printStackTrace();
//            throw e;
//        }
    }

    public List<SearchResDTO> search(
            List<Double> embedding,
            int topK,
            String namespace,
            String requiredType,
            double minScore
    ) {
        try {
            Map<String, Object> body = new HashMap<>();
            body.put("vector", embedding);
            body.put("topK", topK);
            body.put("includeMetadata", true);
            if (namespace != null) body.put("namespace", namespace);


            log.info("🔎 [PINECONE QUERY REQUEST] namespace={}, requiredType={}, body={}",
                    namespace, requiredType, body);

            String resJson = pineconeClient.post()
                    .uri("/query")
                    .bodyValue(body)
                    .retrieve()
                    .bodyToMono(String.class)
                    .block();

            log.info("📌 [PINECONE RAW RESPONSE] {}", resJson);

            Map<String, Object> json = objectMapper.readValue(resJson, Map.class);

            List<Map<String, Object>> matches =
                    (List<Map<String, Object>>) json.getOrDefault("matches", List.of());

            List<SearchResDTO> results = new ArrayList<>();

            log.info("📌 [MATCHES BEFORE FILTER] size={}, data={}",
                    matches.size(), matches);

            for (Map<String, Object> m : matches) {

                double score = ((Number) m.get("score")).doubleValue();
                if (score < minScore) continue;

                String id = (String) m.get("id");
                Map<String, Object> metadata =
                        (Map<String, Object>) m.getOrDefault("metadata", Map.of());

                // type 필터링
                if (requiredType != null) {
                    String type = (String) metadata.get("type");
                    if (!requiredType.equals(type)) continue;
                }


                results.add(new SearchResDTO(id, score, metadata));
            }
            log.info("📌 [MATCHES AFTER FILTER(requiredType={})] size={}",
                    requiredType, results.size());


            return results;

        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }




}
