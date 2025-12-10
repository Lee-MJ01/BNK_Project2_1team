package kr.co.api.backend.service;

import kr.co.api.flobankapi.dto.ChatbotSessionDTO;
import kr.co.api.flobankapi.mapper.ChatbotSessionMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChatbotSessionService {
    private final ChatbotSessionMapper chatbotSessionMapper;

    public ChatbotSessionDTO insertSess(ChatbotSessionDTO chatbotSessionDTO){
        if (chatbotSessionDTO.getSessCustCode() == null || chatbotSessionDTO.getSessCustCode() == ""){
            chatbotSessionMapper.insertAnoSession(chatbotSessionDTO);
            return chatbotSessionDTO;
        }else {
            chatbotSessionMapper.insertSession(chatbotSessionDTO);
            return chatbotSessionDTO;
        }
    }
}
