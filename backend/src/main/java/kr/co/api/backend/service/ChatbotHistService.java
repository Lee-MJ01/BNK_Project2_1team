package kr.co.api.backend.service;

import kr.co.api.backend.dto.ChatbotAdminDTO;
import kr.co.api.backend.dto.ChatbotHistDTO;
import kr.co.api.backend.mapper.ChatbotHistMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@Slf4j
@RequiredArgsConstructor
public class ChatbotHistService {
    private final ChatbotHistMapper chatbotHistMapper;

    public void insertHist(ChatbotHistDTO histDTO){
        chatbotHistMapper.insertHist(histDTO);
    }
    public void insertNoSessHist(ChatbotHistDTO histDTO){
        chatbotHistMapper.insertNoSessHist(histDTO);
    }

    public List<ChatbotHistDTO> selectHist(String sessId){
        return chatbotHistMapper.selectHist(sessId);
    }

    public List<ChatbotAdminDTO> selectRecentHist(){
        List<ChatbotHistDTO> hists = chatbotHistMapper.selectRecentHist();
        int index = hists.getFirst().getBotNo();
        List<ChatbotAdminDTO> admins = new ArrayList<>();
        ChatbotHistDTO tempBot = null;

        for (ChatbotHistDTO h : hists) {
            if (h.getBotType() == 2) {
                tempBot = h;
            } else if (h.getBotType() == 1 && tempBot != null) {
                // 사용자 → 직전 봇 메시지와 매핑
                ChatbotAdminDTO dto = new ChatbotAdminDTO();
                dto.setBotNo(index--);
                dto.setUserQuestion(h.getBotContent());
                dto.setBotAnswer(tempBot.getBotContent());
                dto.setBotDt(tempBot.getBotDt());
                admins.add(dto);

                tempBot = null; // 초기화
            }
        }

        return admins;
    }

}
