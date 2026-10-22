package kr.co.api.backend.controller;

import com.fasterxml.jackson.databind.JsonNode;
import kr.co.api.backend.service.AddressSearchService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/mobile/member/addresses")
public class AddressSearchController {
    private final AddressSearchService addressSearchService;

    @GetMapping
    public JsonNode search(@RequestParam String keyword) {
        return addressSearchService.search(keyword);
    }
}
