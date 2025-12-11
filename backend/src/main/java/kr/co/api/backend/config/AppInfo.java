package kr.co.api.backend.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * application.yml의 속성을 읽어 뷰(Thymeleaf)에 제공하는 Bean
 * Thymeleaf에서 @appInfo로 이 Bean을 호출할 수 있습니다.
 */
@Component("appInfo") // Bean의 이름을 "appInfo"로 지정
public class AppInfo {

    private final String appVersion;

    // @Value를 사용하여 application.yml의 'app-version' 값을 주입받음
    public AppInfo(@Value("${app-version}") String appVersion) {
        this.appVersion = appVersion;
    }

    public String getVersion() {
        // 만약 IDE에서 'Run'으로 바로 실행하여 Gradle 교체가 안된 경우(값이 "@version@"일 경우),
        // 'DEV'로 표시하고, 그 외(빌드/배포)에는 실제 버전 값을 반환합니다.
        return appVersion.startsWith("@") ? "DEV" : appVersion;
    }
}