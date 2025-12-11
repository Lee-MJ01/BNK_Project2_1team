package kr.co.api.backend.service;

import kr.co.api.backend.dto.BoardDTO;
import kr.co.api.backend.mapper.BoardMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class BoardService {

    private final BoardMapper boardMapper;

    private final int NOTICE_TYPE = 1;

    // 🔹 전체 목록
    public List<BoardDTO> getNoticeList() {
        return boardMapper.selectBoardListByType(NOTICE_TYPE);
    }

    // 🔹 상세조회 + 조회수 증가
    @Transactional
    public BoardDTO getNotice(Long boardNo) {
        boardMapper.updateBoardHit(boardNo);
        return boardMapper.selectBoardByNo(boardNo);
    }

    // 🔹 페이징
    public Map<String, Object> getNoticePage(int page) {

        int pageSize = 6;

        int totalCount = boardMapper.countBoard(NOTICE_TYPE);
        int totalPage = (int) Math.ceil(totalCount / (double) pageSize);
        if (totalPage < 1) totalPage = 1;

        int start = (page - 1) * pageSize + 1;
        int end = page * pageSize;

        List<BoardDTO> list = boardMapper.selectBoardPage(start, end, NOTICE_TYPE);

        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("page", page);
        result.put("pageSize", pageSize);
        result.put("totalPage", totalPage);
        result.put("totalCount", totalCount);

        return result;
    }

    // 🔹 등록
    public void insertNotice(BoardDTO board) {
        board.setBoardType(NOTICE_TYPE);
        boardMapper.insertBoard(board);
    }


    // ======================================
    // 🔹 이벤트 (board_type = 2)
    // ======================================

    private final int EVENT_TYPE = 2;

    /**
     * 이벤트 페이징 리스트
     */
    public Map<String, Object> getEventPage(int page) {

        int pageSize = 6;

        int totalCount = boardMapper.countBoard(EVENT_TYPE);
        int totalPage = (int) Math.ceil(totalCount / (double) pageSize);
        if (totalPage < 1) totalPage = 1;

        int start = (page - 1) * pageSize + 1;
        int end = page * pageSize;

        List<BoardDTO> list = boardMapper.selectBoardPage(start, end, EVENT_TYPE);

        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("page", page);
        result.put("pageSize", pageSize);
        result.put("totalPage", totalPage);
        result.put("totalCount", totalCount);

        return result;
    }

    /**
     * 이벤트 상세 조회 (조회수 증가)
     */
    @Transactional
    public BoardDTO getEvent(Long boardNo) {
        boardMapper.updateBoardHit(boardNo);   // 조회수 증가
        return boardMapper.selectBoardByNo(boardNo);
    }

    public void insertBoard(BoardDTO board) {
        if (board.getBoardAdminId() == null) {
            board.setBoardAdminId("admin"); // 기본 관리자 ID
        }
        boardMapper.insertBoard(board);
    }

    public List<BoardDTO> getBoardListByType(int boardType) {
        return boardMapper.selectBoardListByType(boardType);
    }

    public Map<String, Object> getAllBoardPage(int page) {

        int pageSize = 5;

        int totalCount = boardMapper.countAllBoard();
        int totalPage = (int) Math.ceil(totalCount / (double) pageSize);
        if (totalPage < 1) totalPage = 1;

        int start = (page - 1) * pageSize + 1;
        int end = page * pageSize;

        List<BoardDTO> list = boardMapper.selectAllBoardPage(start, end);

        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("page", page);
        result.put("pageSize", pageSize);
        result.put("totalPage", totalPage);
        result.put("totalCount", totalCount);

        return result;
    }



    public void updateBoard(BoardDTO board) {
        boardMapper.updateBoard(board);
    }

    public void deleteBoard(Long boardNo) {
        boardMapper.deleteBoard(boardNo);
    }



    public BoardDTO getBoardByNo(Long boardNo) {
        return boardMapper.selectBoardByNo(boardNo);
    }




}
