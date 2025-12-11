package kr.co.api.backend.controller.admin;


import kr.co.api.flobankapi.dto.admin.dashboard.DashboardDTO;
import kr.co.api.flobankapi.service.admin.DashboardService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.time.LocalDateTime;

@Slf4j
@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping({"", "/", "/index"})
    public String adminHome(Model model) {
        DashboardDTO stats = dashboardService.getStats();
        if (stats == null) {
            stats = new DashboardDTO();  // NPE 방지용
        }
        model.addAttribute("stats", stats);
        model.addAttribute("baseTime", LocalDateTime.now());
        model.addAttribute("activeItem", "stats");
        return "admin/index";
    }
}
