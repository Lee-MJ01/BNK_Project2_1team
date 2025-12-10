package kr.co.api.backend.mapper;

import kr.co.api.flobankapi.dto.BoardDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface BoardMapper {

    List<BoardDTO> selectBoardListByType(@Param("boardType") int boardType);

    BoardDTO selectBoardByNo(@Param("boardNo") Long boardNo);

    void updateBoardHit(@Param("boardNo") Long boardNo);

    int countBoard(@Param("boardType") int boardType);

    List<BoardDTO> selectBoardPage(
            @Param("start") int start,
            @Param("end") int end,
            @Param("boardType") int boardType
    );

    void insertBoard(BoardDTO board);

    List<BoardDTO> selectAllBoardPage(
            @Param("start") int start,
            @Param("end") int end);

    int countAllBoard();

    void updateBoard(BoardDTO board);

    void deleteBoard(@Param("boardNo") Long boardNo);




}
