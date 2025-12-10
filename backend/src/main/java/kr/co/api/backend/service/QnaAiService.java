package kr.co.api.backend.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class QnaAiService {

    @Value("${ai-server-qna.url}")
    private String qnaAiUrl;

    private final WebClient webClient;

    public void sendToAi(Long qnaNo, String question, String title) {
        if (qnaNo == null) {
            log.warn("[QNA-AI] Skip sending because qnaNo is null");
            return;
        }

        Map<String, Object> payload = new HashMap<>();
        payload.put("qnaNo", qnaNo);
        payload.put("question", question);
        payload.put("title", title);

        try {
            webClient.post()
                    .uri(qnaAiUrl)
                    .bodyValue(payload)
                    .retrieve()
                    .toBodilessEntity()
                    .subscribe(
                            res -> log.info("[QNA-AI] Sent to AI server qnaNo={} status={}",
                                    qnaNo, res.getStatusCode()),
                            err -> log.error("[QNA-AI] Failed to call AI server for qnaNo={} reason={}",
                                    qnaNo, err.getMessage(), err)
                    );
            // ❗ 여기까지 오면 바로 리턴됨. 실제 호출은 비동기로 진행.
        } catch (Exception e) {
            // 파라미터 세팅/uri 문제 같은 "즉시 나는 에러"만 여기서 잡힘
            log.error("[QNA-AI] Exception while preparing AI call qnaNo={}: {}",
                    qnaNo, e.getMessage(), e);
        }
    }
}

