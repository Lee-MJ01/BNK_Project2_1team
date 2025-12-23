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


        Path path = Paths.get("/uploads/pdf_products/" + fileName);

        Resource resource = new UrlResource(path.toUri());

        if (!resource.exists()) {

            return ResponseEntity.notFound().build();
        }

        String encodedName = URLEncoder.encode(fileName, StandardCharsets.UTF_8)
                .replaceAll("\\+", "%20");


        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_PDF)
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "inline; filename=" + encodedName)
                .body(resource);
    }
}
