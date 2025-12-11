package kr.co.api.backend.service;

import kr.co.api.backend.dto.ArticleDTO;
import kr.co.api.backend.mapper.ArticleMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ArticleService {

    private final ArticleMapper articleMapper;

    private static final int PAGE_SIZE = 9;     // 한 페이지에 보여줄 게시글 수
    private static final int PAGE_BLOCK = 10;   // 한 번에 보여줄 페이지 번호 개수 (1~10)

    public Map<String, Object> getArticlePage(int page) {

        if (page < 1) page = 1;

        // 전체 개수
        int totalCount = articleMapper.countArticles();

        // 전체 페이지 수
        int totalPage = (int) Math.ceil(totalCount / (double) PAGE_SIZE);
        if (totalPage < 1) totalPage = 1;

        // 시작/끝 rownum
        int start = (page - 1) * PAGE_SIZE + 1;
        int end = page * PAGE_SIZE;

        // 실제 데이터 조회
        List<ArticleDTO> list = articleMapper.selectArticlePage(start, end);

        // 🔥 블록 페이징 계산
        int startPage = ((page - 1) / PAGE_BLOCK) * PAGE_BLOCK + 1;  // 1,11,21,...
        int endPage = startPage + PAGE_BLOCK - 1;                    // 10,20,30,...

        if (endPage > totalPage) {
            endPage = totalPage;
        }

        // 응답값 구성
        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("page", page);
        result.put("pageSize", PAGE_SIZE);
        result.put("totalPage", totalPage);
        result.put("totalCount", totalCount);

        // 🔥 블록 페이징 정보 추가
        result.put("startPage", startPage);
        result.put("endPage", endPage);
        result.put("blockSize", PAGE_BLOCK);   // ← 수정됨

        return result;
    }
}
