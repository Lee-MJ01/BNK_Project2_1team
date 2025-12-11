package kr.co.api.backend.mapper;

import kr.co.api.backend.dto.QnaDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface QnaMapper {

    int countQna(@Param("status") String status);

    List<QnaDTO> selectQnaPage(@Param("start") int start,
                               @Param("end") int end,
                               @Param("status") String status);

    QnaDTO selectQnaByNo(@Param("qnaNo") Long qnaNo);

    void updateQnaViewCnt(@Param("qnaNo") Long qnaNo);

    void insertQna(QnaDTO qna);

    void updateQna(QnaDTO qna);

    void updateQnaReply(@Param("qnaNo") Long qnaNo,
                        @Param("reply") String reply,
                        @Param("status") String status);

    void deleteQna(@Param("qnaNo") Long qnaNo);
}
