package kr.co.api.backend.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "file.upload")
@Data
public class FilePathConfig {
    private String pdfTermsPath;
    private String pdfProductsPath;
}

