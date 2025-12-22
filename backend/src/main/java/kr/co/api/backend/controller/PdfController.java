package kr.co.api.backend.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.nio.file.Paths;

@Slf4j
@RestController
@RequestMapping("/api/pdf/products")
public class PdfController {

    @GetMapping("/{fileName:.+}")
    public ResponseEntity<Resource> getPdf(@PathVariable String fileName) throws Exception {

        log.info("====== PDF 요청 들어옴 ======");
        log.info("요청 파일명: {}", fileName);

        Path path = Paths.get("/uploads/pdf_products/" + fileName);
        log.info("실제 조회 경로 : {}", path.toString());

        Resource resource = new UrlResource(path.toUri());

        if (!resource.exists()) {
            log.error("❌ 파일 없음!!!!");
            return ResponseEntity.notFound().build();
        }

        String encodedName = URLEncoder.encode(fileName, StandardCharsets.UTF_8)
                .replaceAll("\\+", "%20");

        log.info("✅ 파일 존재, 반환 성공!");

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_PDF)
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "inline; filename=" + encodedName)
                .body(resource);
    }
}
