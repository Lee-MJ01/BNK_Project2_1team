package kr.co.api.backend.controller;

import kr.co.api.backend.dto.ChatbotHistDTO;
import kr.co.api.backend.dto.ChatbotSessionDTO;
import kr.co.api.backend.dto.SearchResDTO;
import kr.co.api.backend.jwt.CustomUserDetails;
import kr.co.api.backend.service.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

@Controller
@RequiredArgsConstructor
@Slf4j
public class ChatbotController {

    private final QTypeClassifierService typeClassifier;
    private final EmbeddingService embeddingService;
    private final PineconeService pineconeService;
    private final ChatGPTService chatGPTService;
    private final ChatbotSessionService chatbotSessionService;
    private final ChatbotHistService chatbotHistService;
    private final WhiteListService whiteListService;
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    @GetMapping("/mypage/chatbot")
    public String chatbot(@AuthenticationPrincipal CustomUserDetails user, Model model) {

        ChatbotSessionDTO sessDTO = new ChatbotSessionDTO();
        if (user != null) {
            sessDTO.setSessCustCode(user.getUsername());
        }
        sessDTO.setSessStartDt(LocalDateTime.now().format(formatter));

        sessDTO = chatbotSessionService.insertSess(sessDTO);
        System.out.println("=== 세션 아이디 : " + sessDTO.getSessId());
        model.addAttribute("sessId", sessDTO.getSessId());

        return "mypage/chatbot";
    }

    private final ChatbotRuleService chatbotRuleService;

    @PostMapping("/api/mypage/chatbot")
    @ResponseBody
    public Map<String, Object> chatbotApi(
            @RequestBody Map<String, String> req
    ) {

        String q = req.get("question");
        String sessId = req.get("sessId");

        // 질문 저장
        ChatbotHistDTO qHistDTO = new ChatbotHistDTO();
        qHistDTO.setBotType(1);
        qHistDTO.setBotContent(q);
        chatbotHistService.insertNoSessHist(qHistDTO);

        try {
            ChatbotHistDTO aHistDTO = new ChatbotHistDTO();
            aHistDTO.setBotType(2);

            // 금칙어 체크
            String forbiddenResponse = chatbotRuleService.checkForbiddenWord(q);
            if (forbiddenResponse != null) {
                aHistDTO.setBotContent(forbiddenResponse);
                chatbotHistService.insertHist(aHistDTO);

                return Map.of(
                        "answer", forbiddenResponse,
                        "blocked", true
                );
            }

            StringBuilder contextBuilder = new StringBuilder();

            // 화이트리스트 SQL
            String query = typeClassifier.detectQueryByGPT(q);
            if (query != null && !"null".equals(query)) {
                String queryResult = whiteListService.queryAndFormat(query);
                contextBuilder.append("\n\n").append(queryResult);
            }

            // 질문 타입 분류 + RAG
            String type = typeClassifier.detectTypeByGPT(q);
            if (type != null && !"null".equals(type)) {

                List<Double> qEmbedding = embeddingService.embedText(q);

                var results = pineconeService.search(
                        qEmbedding,
                        5,
                        "fx-interest",
                        type,
                        0
                );

                for (SearchResDTO r : results) {
                    Map<String, Object> meta = r.getMetadata();
                    if (meta != null && meta.containsKey("content")) {
                        contextBuilder.append(meta.get("content"))
                                .append("\n\n");
                    }
                }
            }

            String context = contextBuilder.toString();
            log.info("=== API context ===\n{}", context);

            String response = chatGPTService.ask(q, context);

            aHistDTO.setBotContent(response);
            chatbotHistService.insertHist(aHistDTO);

            return Map.of(
                    "message", response,
                    "isUser", false,
                    "createdAt", LocalDateTime.now()
            );

        } catch (Exception e) {
            e.printStackTrace();
            return Map.of(
                    "error", "챗봇 처리 중 오류가 발생했습니다."
            );
        }
    }

}
