package kr.co.api.backend.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;

@Configuration
public class PineconeConfig {

    @Value("${pinecone.api-key}")
    private String apiKey;

    @Value("${pinecone.index-host}")
    private String indexHost;

    @Bean
    public WebClient pineconeClient() {
        return WebClient.builder()
                .baseUrl(indexHost)
                .defaultHeader("Api-Key", apiKey)
                .defaultHeader("Content-Type", "application/json")
                .build();
    }
}