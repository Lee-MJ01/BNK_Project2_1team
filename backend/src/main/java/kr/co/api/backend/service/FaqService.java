package kr.co.api.backend.service;

import kr.co.api.flobankapi.dto.FaqDTO;
import kr.co.api.flobankapi.mapper.FaqMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class FaqService {

    private final FaqMapper faqMapper;

    public List<FaqDTO> getFaqList() {
        return faqMapper.selectFaqList();
    }

    public FaqDTO getFaq(Long faqNo) {
        return faqMapper.selectFaqByNo(faqNo);
    }

    public void insertFaq(FaqDTO dto) {
        faqMapper.insertFaq(dto);
    }

    public void updateFaq(FaqDTO dto) {
        faqMapper.updateFaq(dto);
    }

    public void deleteFaq(Long faqNo) {
        faqMapper.deleteFaq(faqNo);
    }

    public Map<String, Object> getFaqPage(int faqPage) {

        int faqPageSize = 3; // 한 페이지당 10개씩 보여주고 싶다 가정
        int offset = (faqPage - 1) * faqPageSize;

        // 전체 개수
        int totalFaqCount = faqMapper.selectFaqCount();

        // 현재 페이지 데이터
        List<FaqDTO> faqList = faqMapper.selectFaqPage(offset, faqPageSize);

        int totalFaqPage = (int) Math.ceil((double) totalFaqCount / faqPageSize);

        Map<String, Object> result = new HashMap<>();
        result.put("faqList", faqList);
        result.put("faqPage", faqPage);
        result.put("faqPageSize", faqPageSize);
        result.put("totalFaqPage", totalFaqPage);
        result.put("totalFaqCount", totalFaqCount);

        return result;
    }


}
