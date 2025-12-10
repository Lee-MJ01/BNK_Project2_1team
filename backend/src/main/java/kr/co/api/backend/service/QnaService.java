package kr.co.api.backend.service;

import kr.co.api.flobankapi.dto.QnaDTO;
import kr.co.api.flobankapi.mapper.QnaMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class QnaService {

    private final QnaMapper qnaMapper;
    private static final int PAGE_SIZE = 6;
    private static final int ADMIN_PAGE_SIZE = 5;

    public Map<String, Object> getQnaPage(int page) {
        return getQnaPage(page, null, PAGE_SIZE);
    }

    public Map<String, Object> getQnaPage(int page, String status) {
        return getQnaPage(page, status, PAGE_SIZE);
    }

    public Map<String, Object> getAdminQnaPage(int page, String status) {
        return getQnaPage(page, status, ADMIN_PAGE_SIZE);
    }

    private Map<String, Object> getQnaPage(int page, String status, int pageSize) {
        String normalizedStatus = normalizeStatus(status);

        int totalCount = qnaMapper.countQna(normalizedStatus);
        int totalPage = (int) Math.ceil(totalCount / (double) pageSize);
        if (totalPage < 1) totalPage = 1;
        if (page > totalPage) {
            page = totalPage;
        }

        int start = (page - 1) * pageSize + 1;
        int end = page * pageSize;

        List<QnaDTO> list = qnaMapper.selectQnaPage(start, end, normalizedStatus);

        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("page", page);
        result.put("pageSize", pageSize);
        result.put("totalPage", totalPage);
        result.put("totalCount", totalCount);
        result.put("status", normalizedStatus == null ? "all" : normalizedStatus);

        return result;
    }

    @Transactional
    public QnaDTO getQna(Long qnaNo) {
        qnaMapper.updateQnaViewCnt(qnaNo);
        return qnaMapper.selectQnaByNo(qnaNo);
    }

    public QnaDTO findQna(Long qnaNo) {
        return qnaMapper.selectQnaByNo(qnaNo);
    }

    public void createQna(QnaDTO qna) {
        if (qna.getQnaStatus() == null || qna.getQnaStatus().isBlank()) {
            qna.setQnaStatus("WAIT");
        }
        qnaMapper.insertQna(qna);
    }

    public void updateQna(QnaDTO qna) {
        qnaMapper.updateQna(qna);
    }

    public void deleteQna(Long qnaNo) {
        qnaMapper.deleteQna(qnaNo);
    }

    public void updateQnaReply(Long qnaNo, String reply, String status) {
        String normalized = reply;
        if (normalized != null && normalized.isBlank()) {
            normalized = null;
        }
        String normalizedStatus = normalizeStatus(status);
        qnaMapper.updateQnaReply(qnaNo, normalized, normalizedStatus);
    }

    private String normalizeStatus(String status) {
        if (status == null || status.isBlank()) {
            return null;
        }
        String upper = status.toUpperCase();
        return switch (upper) {
            case "WAIT", "SAFE", "MID", "HIGH", "ANSWERED" -> upper;
            default -> null;
        };
    }
}
