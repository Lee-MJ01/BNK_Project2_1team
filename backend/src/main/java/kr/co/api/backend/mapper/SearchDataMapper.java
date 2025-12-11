package kr.co.api.backend.mapper;

import kr.co.api.backend.document.*;
import kr.co.api.backend.dto.search.SearchLogDTO;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface SearchDataMapper {

    // 1. 상품 (TB_DPST_PROD_INFO)
    // dpst_id, dpst_name, dpst_info, dpst_descript, dpst_reg_dt
    @Select("""
    SELECT 
        dpst_id AS dpstId,
        dpst_name AS dpstName,
        dpst_info AS dpstInfo,
        dpst_descript AS dpstDescript
    FROM TB_DPST_PROD_INFO
    WHERE DPST_STATUS = 3
""")
    List<ProductDocument> selectAllProducts();

    // 2. FAQ (TB_FAQ_HDR)
    // faq_no, faq_question, faq_answer
    @Select("SELECT faq_no as faqNo, faq_question as faqQuestion, faq_answer as faqAnswer FROM TB_FAQ_HDR")
    List<FaqDocument> selectAllFaqs();

    // 3. 약관 (TB_TERMS_MASTER)
    @Select("""
    SELECT 
        h.thist_no        AS thistNo,
        m.term_title      AS termTitle,
        h.thist_content   AS thistContent,
        h.thist_version   AS thistVersion,
        h.thist_file      AS thistFile,
        TO_DATE(h.thist_reg_dy, 'YYYYMMDD') AS thistRegDy,
        
        -- [추가됨] 이력 테이블(h)에 있는 값을 가져와서 자바 객체에 매핑
        h.thist_term_order AS thistTermOrder,
        h.thist_term_cate  AS thistTermCate
        
    FROM TB_TERMS_HIST h
    JOIN TB_TERMS_MASTER m 
      ON h.thist_term_order = m.term_order 
     AND h.thist_term_cate  = m.term_cate
""")
    List<TermDocument> selectAllTerms();

    // 4. 공지사항 (TB_BOARD_HDR where board_type = 1)
    // board_no, board_title, board_content, board_reg_dt
    @Select("SELECT board_no as boardNo, board_title as boardTitle, board_content as boardContent, board_reg_dt as boardRegDt " +
            "FROM TB_BOARD_HDR " +
            "WHERE board_type = 1")
    List<NoticeDocument> selectAllNotices();

    // 5. 이벤트 (TB_BOARD_HDR where board_type = 2)
    //  board_no, board_title, board_content, board_reg_dt
    @Select("SELECT board_no as boardNo, board_title as boardTitle, board_content as boardContent, board_content as eventBenefit, board_reg_dt as boardRegDt " +
            "FROM TB_BOARD_HDR " +
            "WHERE board_type = 2")
    List<EventDocument> selectAllEvents();


    // 1. [저장] 토큰 저장 (모든 검색어 - 인기검색어용)
    @Insert("INSERT INTO TB_SEARCH_TOKEN (tok_no, tok_txt) VALUES (SEQ_SEARCH_TOKEN.NEXTVAL, #{keyword})")
    void insertSearchToken(String keyword);

    // 2. [저장] 내 검색 기록 저장 (로그인 시)
    @Insert("INSERT INTO TB_SEARCH_LOG (search_no, search_txt, search_cust_code, search_reg_dt) VALUES (SEQ_SEARCH_LOG.NEXTVAL, #{keyword}, #{custCode}, SYSDATE)")
    void insertSearchLog(String keyword, String custCode);

    // 3. [조회] 인기 검색어 TOP 10 (많이 검색된 순)
    @Select("""
        SELECT * FROM (
            SELECT tok_txt as keyword, COUNT(*) as count
            FROM TB_SEARCH_TOKEN
            WHERE tok_txt IS NOT NULL
            GROUP BY tok_txt
            ORDER BY COUNT(*) DESC
        ) WHERE ROWNUM <= 10
    """)
    List<SearchLogDTO> selectPopularKeywords();

    // 4. [조회] 내 최근 검색어 5개
    @Select("""
        SELECT search_txt as keyword, TO_CHAR(search_reg_dt, 'MM.DD') as date
        FROM (
            SELECT search_txt, search_reg_dt
            FROM TB_SEARCH_LOG
            WHERE search_cust_code = #{custCode}
            ORDER BY search_no DESC
        ) WHERE ROWNUM <= 5
    """)
    List<SearchLogDTO> selectRecentKeywords(String custCode);

}