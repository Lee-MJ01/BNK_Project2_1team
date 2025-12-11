package kr.co.api.backend.service;

import kr.co.api.backend.dto.BriefingDTO;
import kr.co.api.backend.dto.BriefingViewDTO;
import kr.co.api.backend.mapper.BriefingMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;

@Service
@RequiredArgsConstructor
public class BriefingService {
    private final BriefingMapper briefingMapper;
    public BriefingDTO getLatestBrifing(String mode){
        if(mode == null || mode.isBlank()){
            mode = "oneday";
        }
        return  briefingMapper.selectLatestBriefingByMode(mode);
    }

    public BriefingViewDTO buildBriefingView(String mode) {
        BriefingViewDTO viewDTO = new BriefingViewDTO();

        if (mode == null || mode.isBlank()) {
            mode = "oneday";
        }

        viewDTO.setBriefingMode(mode);

        BriefingDTO latest = getLatestBrifing(mode);

        if (latest != null && latest.getContent() != null) {
            viewDTO.setBriefingLines(latest.getContent().split("\\n"));
        }

        if ("oneday".equals(mode)) {
            LocalDate date = null;
            if (latest != null && latest.getBriefingDate() != null) {
                date = latest.getBriefingDate().toLocalDate();
            }

            viewDTO.setBriefingTitle("오늘의 브리핑");
            viewDTO.setBriefingDateText(date != null ? date.toString() : "날짜 없음");
        }

        if ("recent5".equals(mode)) {
            LocalDate today = LocalDate.now();
            LocalDate fiveDaysAgo = today.minusDays(5);

            viewDTO.setBriefingTitle("최근 5일 브리핑");
            viewDTO.setBriefingDateText(fiveDaysAgo + " ~ " + today);
        }

        if (viewDTO.getBriefingTitle() == null) {
            viewDTO.setBriefingTitle("브리핑");
            viewDTO.setBriefingDateText("-");
        }

        return viewDTO;
    }
}
