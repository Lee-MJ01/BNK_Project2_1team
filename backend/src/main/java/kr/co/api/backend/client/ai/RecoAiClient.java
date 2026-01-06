package kr.co.api.backend.client.ai;

import kr.co.api.backend.dto.reco.AiRecoV2Request;
import kr.co.api.backend.dto.reco.RecoRerankResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.time.Duration;

@Slf4j
@Component
public class RecoAiClient {

    private final RestClient rest;

    public RecoAiClient(@Value("${ai-server-reco.url}") String baseUrl) {
        // ✅ 타임아웃 설정용 Factory
        HttpComponentsClientHttpRequestFactory factory = new HttpComponentsClientHttpRequestFactory();
        factory.setConnectTimeout((int) Duration.ofSeconds(3).toMillis());
        factory.setReadTimeout((int) Duration.ofSeconds(10).toMillis());

        this.rest = RestClient.builder()
                .baseUrl(baseUrl)
                .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .defaultHeader(HttpHeaders.ACCEPT, MediaType.APPLICATION_JSON_VALUE)
                .requestFactory(factory)
                .build();
    }

    public RecoRerankResponse rerank(AiRecoV2Request req) {
        log.info("[AI-RECO] call rerank start surveyId={}, custCode={}",
                req.getSurveyId(), req.getCustCode());

        try {
            RecoRerankResponse res = rest.post()
                    .uri("/reco/rerank")
                    .body(req)
                    .retrieve()
                    .body(RecoRerankResponse.class);

            if (res == null) {
                log.error("[AI-RECO] null response surveyId={}, custCode={}",
                        req.getSurveyId(), req.getCustCode());
                throw new IllegalStateException("AI-RECO returned null");
            }

            int size = (res.getItems() == null) ? 0 : res.getItems().size();
            log.info("[AI-RECO] rerank success surveyId={}, custCode={}, items={}",
                    req.getSurveyId(), req.getCustCode(), size);

            return res;

        } catch (Exception e) {
            log.error("[AI-RECO] rerank failed surveyId={}, custCode={}, err={}",
                    req.getSurveyId(), req.getCustCode(), e.getMessage(), e);
            throw e;
        }
    }
}
