package kr.co.api.backend.controller.translate;

import kr.co.api.backend.dto.translate.TranslationRequestDTO;
import kr.co.api.backend.dto.translate.TranslationResponseDTO;
import kr.co.api.backend.service.translate.TranslationService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api/translate")
public class TranslationController {

    private final TranslationService translationService;

    @PostMapping
    public TranslationResponseDTO translate(@RequestBody TranslationRequestDTO request) {

        String result = translationService.translate(
                request.getText(),
                request.getTargetLang()
        );

        TranslationResponseDTO response = new TranslationResponseDTO();
        response.setTranslatedText(result);

        return response;
    }


}
