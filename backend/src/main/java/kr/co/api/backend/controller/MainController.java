package kr.co.api.backend.controller;

import kr.co.api.backend.dto.BoardDTO;
import kr.co.api.backend.dto.BriefingViewDTO;
import kr.co.api.backend.service.BoardService;
import kr.co.api.backend.service.BriefingService;
import kr.co.api.backend.service.RateService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Controller
@RequiredArgsConstructor
public class MainController {

    private final BriefingService briefingService;
    private final BoardService boardService;
    private final RateService rateService;

    @GetMapping("/")
    public String mainPage(
            @RequestParam(value = "mode", required = false, defaultValue = "oneday")
            String mode,
            Model model
    ) {

        /** 1) 오늘의 브리핑 */
        BriefingViewDTO briefingView = briefingService.buildBriefingView(mode);
        model.addAttribute("briefingMode", briefingView.getBriefingMode());
        model.addAttribute("briefingTitle", briefingView.getBriefingTitle());
        model.addAttribute("briefingDateText", briefingView.getBriefingDateText());
        model.addAttribute("briefingLines", briefingView.getBriefingLines());

        /** 2) 공지사항 */
        List<BoardDTO> noticeList =
                ((List<BoardDTO>) boardService.getNoticePage(1).get("list"))
                        .stream().limit(5).collect(Collectors.toList());
        model.addAttribute("noticeList", noticeList);

        /** 3) 이벤트 */
        List<BoardDTO> eventList =
                ((List<BoardDTO>) boardService.getEventPage(1).get("list"))
                        .stream().limit(5).collect(Collectors.toList());
        model.addAttribute("eventList", eventList);

        /** 4) 최신 영업일 날짜 (화면 표시용) */
        LocalDate targetDate = rateService.getTargetDate();
        model.addAttribute("fxDate", targetDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")));


        return "index";
    }
}