package kr.co.api.backend.mapper;

import kr.co.api.backend.dto.ChatbotSessionDTO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ChatbotSessionMapper {
    public void insertSession(ChatbotSessionDTO sessionDTO);
    public void insertAnoSession(ChatbotSessionDTO sessionDTO);
}
