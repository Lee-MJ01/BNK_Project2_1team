package kr.co.api.backend.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.io.FileInputStream;
import java.io.InputStream;
@Configuration

public class FirebaseConfig {

//    @Bean
//    public FirebaseApp firebaseApp(@Value("${firebase.service-account-path:}") String path) throws Exception {
//
//        if (FirebaseApp.getApps() != null && !FirebaseApp.getApps().isEmpty()) {
//            return FirebaseApp.getInstance();
//        }
//
//        GoogleCredentials credentials;
//
//        if (path != null && !path.isBlank()) {
//            try (InputStream is = new FileInputStream(path)) {
//                credentials = GoogleCredentials.fromStream(is);
//            }
//        } else {
//            // ✅ GCP VM 서비스계정(ADC)
//            credentials = GoogleCredentials.getApplicationDefault();
//       }
//
//        FirebaseOptions options = FirebaseOptions.builder()
//                .setCredentials(credentials)
//                .build();
//
//        return FirebaseApp.initializeApp(options);
//    }

}
