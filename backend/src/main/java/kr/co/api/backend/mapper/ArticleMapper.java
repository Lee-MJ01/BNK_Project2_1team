package kr.co.api.backend.mapper;

import kr.co.api.flobankapi.dto.ArticleDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ArticleMapper {
    int countArticles();

    List<ArticleDTO> selectArticlePage(
            @Param("start") int start,
            @Param("end") int end
    );
}
