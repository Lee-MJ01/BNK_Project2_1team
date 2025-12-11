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
    @PostMapping("/mypage/chatbot")
    public String chatbot(Model model, String q, String sessId) {

        ChatbotHistDTO qHistDTO = new ChatbotHistDTO();
        qHistDTO.setBotType(1);
        qHistDTO.setBotContent(q);
        qHistDTO.setBotSessId(sessId);
        chatbotHistService.insertHist(qHistDTO);


        try {

            ChatbotHistDTO aHistDTO = new ChatbotHistDTO();
            aHistDTO.setBotType(2);
            aHistDTO.setBotSessId(sessId);


            String forbiddenResponse = chatbotRuleService.checkForbiddenWord(q);
            if (forbiddenResponse != null){
                aHistDTO.setBotContent(forbiddenResponse);
                chatbotHistService.insertHist(aHistDTO);

                List<ChatbotHistDTO> dtoList = chatbotHistService.selectHist(sessId);
                model.addAttribute("dtoList", dtoList);
                model.addAttribute("sessId", sessId);

                return "mypage/chatbot"; // 금칙어 차단
            }


            StringBuilder contextBuilder = new StringBuilder();

            String query = typeClassifier.detectQueryByGPT(q);
            System.out.println("=== 실행될 QUERY = " + query);
            String queryResult = "";
            if (query != null && !query.equals("null")) {
                queryResult = whiteListService.queryAndFormat(query);
                contextBuilder.append("\n\n").append(queryResult);
            }
            //System.out.println("=== 쿼리 실행 결과 = " + queryResult);




            // 질문 타입 분류
            String type = typeClassifier.detectTypeByGPT(q);



            if (type != null && !type.equals("null")) {
                // 질문 임베딩
                List<Double> qEmbedding = embeddingService.embedText(q);
                // VectorDB 검색
                var results = pineconeService.search(
                        qEmbedding,
                        5,          // topK
                        "fx-interest",       // namespace 전체 검색
                        type,       // GPT가 판별한 문서 타입 (null 가능)
                        0
                );
                contextBuilder.append("\n\n\n\n");
                // 검색된 문서로 문맥 텍스트 구성
                for (SearchResDTO r : results) {
                    Map<String, Object> meta = r.getMetadata();
                    if (meta != null && meta.containsKey("content")) {
                        contextBuilder.append(meta.get("content")).append("\n\n");
                    }
                }
            }

            String context = contextBuilder.toString();
            log.info("=== 최종 context ===\n" + context);

            // GPT 호출 (문맥 + 질문)
            String response = chatGPTService.ask(q, context);

            if (response != null) {
                response = response.replace("\r\n", "\n");
                response = response.replace("\n", "<br/>");
                response = response.replace("<br>", "<br/>");
            }


            aHistDTO.setBotContent(response);
            chatbotHistService.insertHist(aHistDTO);

            List<ChatbotHistDTO> dtoList = chatbotHistService.selectHist(sessId);

            model.addAttribute("dtoList", dtoList);
            model.addAttribute("sessId", sessId);

            return "mypage/chatbot";


        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("error", e.getMessage());
            return "mypage/chatbot";
        }
    }
}
