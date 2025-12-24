package kr.co.api.backend.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.io.FileInputStream;
import java.io.InputStream;

@Configuration
public class FirebaseConfig {

    @Bean
    public FirebaseApp firebaseApp(@Value("${firebase.service-account-path}") String path) throws Exception {
        try (InputStream is = new FileInputStream(path)) {
            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(is))
                    .build();

            // 이미 초기화됐으면 재초기화 방지
            if (FirebaseApp.getApps() != null && !FirebaseApp.getApps().isEmpty()) {
                return FirebaseApp.getInstance();
            }
            return FirebaseApp.initializeApp(options);
        }
    }
}
