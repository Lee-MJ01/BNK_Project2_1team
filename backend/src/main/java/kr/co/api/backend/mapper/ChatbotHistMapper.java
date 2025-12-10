package kr.co.api.backend.mapper;

import kr.co.api.flobankapi.dto.ChatbotHistDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface ChatbotHistMapper {
    public void insertHist(ChatbotHistDTO chatbotHistDTO);
    public List<ChatbotHistDTO> selectHist(String sessId);
    public List<ChatbotHistDTO> selectRecentHist();
}
