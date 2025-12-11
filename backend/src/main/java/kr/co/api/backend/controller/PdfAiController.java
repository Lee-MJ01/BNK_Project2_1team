package kr.co.api.backend.controller;

import kr.co.api.flobankapi.service.PdfAiService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@Controller
@RequestMapping("/admin/pdf-ai")
@RequiredArgsConstructor
public class PdfAiController {

    private final PdfAiService pdfAiService;

    // PDF 업로드
    @PostMapping("/upload")
    public ResponseEntity<?> uploadPdf(@RequestParam("file") MultipartFile file) {
        try {
            Long pdfId = pdfAiService.savePdf(file);
            return ResponseEntity.ok(Map.of("pdfId", pdfId));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("업로드 실패: " + e.getMessage());
        }
    }

    // PDF 목록 조회
    @GetMapping("/list")
    public ResponseEntity<?> getPdfList() {
        return ResponseEntity.ok(pdfAiService.getAllPdfs());
    }

    // PDF 상세 (done 상태만)
    @GetMapping("/{pdfId}")
    public ResponseEntity<?> getPdf(@PathVariable Long pdfId) {
        try {
            return ResponseEntity.ok(pdfAiService.getDonePdf(pdfId));
        } catch (IllegalArgumentException | IllegalStateException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @DeleteMapping("/{pdfId}")
    public ResponseEntity<?> deletePdf(@PathVariable Long pdfId) {
        try {
            pdfAiService.deletePdf(pdfId);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}
