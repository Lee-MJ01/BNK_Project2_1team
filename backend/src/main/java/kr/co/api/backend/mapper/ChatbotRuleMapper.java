package kr.co.api.backend.mapper;

import kr.co.api.backend.dto.ChatbotBadTypeDTO;
import kr.co.api.backend.dto.ChatbotBadWordDTO;
import kr.co.api.backend.dto.ChatbotRulesDTO;

import java.util.List;

public interface ChatbotRuleMapper {
    public List<ChatbotBadTypeDTO> selectBadTypeList();
    public List<ChatbotBadWordDTO> selectBadWordList();
    public List<ChatbotRulesDTO> selectRulesList();
    public List<ChatbotBadWordDTO> getActiveWords();
    public void insertBadWords(ChatbotBadWordDTO badWordDTO);
    public List<ChatbotRulesDTO> getActiveRules();
}
