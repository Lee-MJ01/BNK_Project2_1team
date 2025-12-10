package kr.co.api.backend.service.translate;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class TranslationService {

    @Value("${deepl.api.key}")
    private String deepLApiKey;

    private final StringRedisTemplate redisTemplate;

    private final WebClient webClient = WebClient.builder()
            .baseUrl("https://api-free.deepl.com/v2")
            .build();

    public String translate(String text, String targetLang) {

        String trimmedText = (text == null) ? "" : text.trim();
        if (trimmedText.isEmpty()) {
            return "";
        }

        String cacheKey = "deepl:" + targetLang.toLowerCase() + ":" + sha256(trimmedText);

        // Redis 조회
        try {
            String cached = redisTemplate.opsForValue().get(cacheKey);
            if (cached != null) {
//                System.out.println("[CACHE HIT] Redis에서 가져옴");
                return cached;
            }
        } catch (Exception e) {
//            System.err.println("Redis 조회 실패 (무시하고 API 진행): " + e.getMessage());
        }

        // API 호출
        try {
            Map<String, Object> body = Map.of(
                    "text", List.of(trimmedText),
                    "target_lang", targetLang.toUpperCase()
            );

//            System.out.println("[API START] DeepL 호출 시도... " + trimmedText);

            String translated = webClient.post()
                    .uri("/translate")
                    .header("Authorization", "DeepL-Auth-Key " + deepLApiKey)
                    .bodyValue(body)
                    .retrieve()
                    .bodyToMono(Map.class)
                    .map(res -> {
                        List<Map<String, String>> translations = (List<Map<String, String>>) res.get("translations");
                        if (translations != null && !translations.isEmpty()) {
                            return translations.get(0).get("text");
                        }
                        return null;
                    })
                    .block();

            // Redis 저장
            if (translated != null && !translated.isEmpty()) {
                try {
                    redisTemplate.opsForValue().set(cacheKey, translated);
//                    System.out.println("[SAVED] Redis 저장 완료");
                } catch (Exception e) {
//                    System.err.println("Redis 저장 실패: " + e.getMessage());
                }
            }

            return translated;

        } catch (Exception e) {
            e.printStackTrace(); // 에러의 진짜 이유를 콘솔에 찍어줌
            // 에러가 나면 원본 텍스트 리턴 (화면이 멈추지 않게)
            return text;
        }
    }

    private String sha256(String base) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(base.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder();
            for (byte b : hash) hex.append(String.format("%02x", b));
            return hex.toString();
        } catch (Exception e) {
            throw new RuntimeException("SHA-256 Error", e);
        }
    }
}