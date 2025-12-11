package kr.co.api.backend.mapper;

import kr.co.api.backend.dto.FaqDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface FaqMapper {

    /** 전체 목록 조회 (사용 중) */
    List<FaqDTO> selectFaqList();

    /** 페이징 전체 개수 */
    int selectFaqCount();

    /** 페이징 목록 조회 */
    List<FaqDTO> selectFaqPage(
            @Param("offset") int offset,
            @Param("pageSize") int pageSize
    );

    /** 상세 조회 */
    FaqDTO selectFaqByNo(Long faqNo);

    /** 등록 */
    void insertFaq(FaqDTO dto);

    /** 수정 */
    void updateFaq(FaqDTO dto);

    /** 삭제 */
    void deleteFaq(Long faqNo);

    List<FaqDTO> getFaqList(@Param("start") int start,
                            @Param("pageSize") int pageSize);


}
