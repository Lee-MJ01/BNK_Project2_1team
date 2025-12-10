package kr.co.api.backend.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class SearchViewController {

    @GetMapping("/search")
    public String searchPage(@RequestParam(required = false) String keyword, Model model) {

        if(keyword != null) {
            model.addAttribute("keyword", keyword);
        }

        return "search/search_result";
    }
}