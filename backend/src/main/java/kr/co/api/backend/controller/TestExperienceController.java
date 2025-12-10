package kr.co.api.backend.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/test")
public class TestExperienceController {

    @GetMapping({"", "/"})
    public String overview() {
        return "event/product_dashboard";
    }

    @GetMapping("/lounge")
    public String creatorHub() {
        return "event/event_lounge";
    }

}
