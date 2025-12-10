package kr.co.api.backend.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import kr.co.api.flobankapi.dto.ChatbotRulesDTO;
import kr.co.api.flobankapi.mapper.ChatbotRuleMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.List;
import java.util.Map;



@Service
@RequiredArgsConstructor
public class ChatGPTService {

    private final WebClient openAiWebClient;
    private final ObjectMapper objectMapper;
    private final ChatbotRuleMapper chatbotRuleMapper;

    public String ask(String question, String context) {

        List<ChatbotRulesDTO> rules = chatbotRuleMapper.getActiveRules();

        String numberedRules = "";
        for (int i = 0; i < rules.size(); i++) {
            numberedRules += (i + 1) + ") " + rules.get(i).getRuleTxt() + "\n";
        }

        String systemPrompt =
                """
                당신은 '플로뱅크' 은행의 상담원 역할으로,
                다음 범위의 질문에 응답합니다:
                        - 외환 서비스, 환전, 환율, 송금 관련 문의
                        - 외화예금 및 예금 상품 안내, 비교 요청, 타 은행과의 비교
                        - 예금·통장 개설/해지 절차 및 약관 내용 요약 (회원가입, 환전, 송금, 예금, 통장 개설 등)
                        - 약관(회원가입, 예금, 환전, 송금 등) 및 개인정보 처리 목적 설명
                * 범위 외 질문이 오면 다음과 같이 응답합니다:
                해당 문의는 플로뱅크의 챗봇 상담 범위를 벗어납니다. 외환 관련 질문이 있다면 도와드릴게요.
                
                ※ 사용자 질문은, 은행명에 대한 언급이 없으면, 플로뱅크 기준이라고 가정할 것.
                
                질문에는 주어진 context를 기반으로 답변하세요.
     
                규칙 :
                %s

               ※ 단, 오늘, 현재, 실시간 정보를 요구하는 질문의 경우,
               실제 적용 금리가 아닌 "최근 금리 기준 안내" + "실시간 조회 안내 문구" 형태로 응답하세요.
                ※ 수치가 잘못된 질문이라도 → 범위 외로 차단하지 말고, context 기준으로 정정하여 안내하세요.
                ※ 약관이나 개인정보 질문의 경우:
                - "왜 이러한 항목이 필요한지"를 안내 수준에서 설명
                - 단, 법적 판단이나 민감 책임은 “고객센터 또는 약관 전문”으로 안내
               """.formatted(numberedRules);

        String userPrompt =
                """
                ====== context ======
                %s
    
                ====== question ======
                %s
                """
                        .formatted(context, question);

        String responseJson = openAiWebClient.post()
                .uri("/chat/completions")
                .bodyValue(Map.of(
                        "model", "gpt-4o-mini",
                        "messages", List.of(
                                Map.of("role", "system", "content", systemPrompt),
                                Map.of("role", "user", "content", userPrompt)
                        ),
                        "max_tokens", 1024,
                        "temperature", 0
                ))
                .retrieve()
                .bodyToMono(String.class)
                .block();

        try {
            JsonNode root = objectMapper.readTree(responseJson);
            return root
                    .path("choices")
                    .get(0)
                    .path("message")
                    .path("content")
                    .asText();
        } catch (Exception e) {
            throw new RuntimeException("응답 파싱 실패: " + e.getMessage());
        }
    }

}