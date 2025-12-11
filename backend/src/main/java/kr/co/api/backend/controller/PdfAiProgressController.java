package kr.co.api.backend.controller;

import kr.co.api.backend.dto.PdfAiProgressDTO;
import kr.co.api.backend.service.PdfAiSseEmitterService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

@RestController
@RequiredArgsConstructor
@RequestMapping("/pdf-ai")
public class PdfAiProgressController {

    private final PdfAiSseEmitterService emitterService;

    /** 브라우저가 SSE 구독 */
    @GetMapping("/progress/{pdfId}")
    public SseEmitter subscribe(@PathVariable Long pdfId) {
        return emitterService.subscribe(pdfId);
    }

    /** FastAPI → progress 전송 */
    @PostMapping("/progress")
    public void pushProgress(@RequestBody PdfAiProgressDTO dto) {
        emitterService.sendProgress(dto.getPdfId(), dto.getProgress());
    }
}
