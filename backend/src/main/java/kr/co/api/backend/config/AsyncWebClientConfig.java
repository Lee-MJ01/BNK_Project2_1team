package kr.co.api.backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.web.reactive.function.client.WebClient;

@Configuration
@EnableAsync   // ⭐ 비동기 기능 활성화
public class AsyncWebClientConfig {

    /**
     * WebClient Bean — 비동기 Webhook 호출에 사용
     */
    @Bean
    public WebClient webClient() {
        return WebClient.builder()
                .build();
    }
}
