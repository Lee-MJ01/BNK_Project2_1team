package kr.co.api.backend.mapper;

import kr.co.api.backend.dto.search.SearchLogDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface SearchMapper {

    // 1. 인기 검색어용 토큰 저장
    void insertSearchToken(@Param("keyword") String keyword);

    // 2. 내 검색 기록 저장(로그인한 이용자만)
    void insertSearchLog(@Param("keyword") String keyword, @Param("custCode") String custCode);


    // + 중복 검색어 삭제
    void deleteDuplicateSearchLog(@Param("keyword") String keyword, @Param("custCode") String custCode);


    // 3. 인기 검색어 조회
    List<SearchLogDTO> selectPopularKeywords();

    // 4. 최근 검색어 조회
    List<SearchLogDTO> selectRecentKeywords(String custCode);

    // 5. 최근 검색어 삭제
    void deleteSearchLog(@Param("keyword") String keyword, @Param("custCode") String custCode);
}