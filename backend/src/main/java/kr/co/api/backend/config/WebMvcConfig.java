package kr.co.api.backend.config;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Paths;

@RequiredArgsConstructor
@Configuration
public class WebMvcConfig implements WebMvcConfigurer {
    private final FilePathConfig filePathConfig;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {

        registry.addResourceHandler("/pdf_ai/**")
                .addResourceLocations("file:/app/uploads/pdf_ai/");



        // 약관 PDF
        String termsPath = filePathConfig.getPdfTermsPath(); // 예: /app/uploads/terms
        String termsLocation = Paths.get(termsPath).toUri().toString();
        if (!termsLocation.endsWith("/")) {
            termsLocation += "/";
        }

        registry.addResourceHandler("/uploads/terms/**")
                .addResourceLocations(termsLocation);



        // 상품설명서 pdf
        String productPath = filePathConfig.getPdfProductsPath(); // /app/uploads/pdf_products
        String productLocation = Paths.get(productPath).toUri().toString();

        registry.addResourceHandler("/uploads/products/**")
                .addResourceLocations(productLocation);
    }


    }


