package kr.co.api.backend.config;

import kr.co.api.backend.jwt.JwtAuthenticationFilter;
import kr.co.api.backend.jwt.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpStatus;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.HttpStatusEntryPoint;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtTokenProvider jwtTokenProvider;
    private final CustomAuthenticationEntryPoint customAuthenticationEntryPoint; // 웹용 리다이렉트 핸들러

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    // 📱 1. 모바일 API용 시큐리티 설정 (API는 JSON 응답/401 에러 필요)
    @Bean
    @Order(1)
    public SecurityFilterChain mobileFilterChain(HttpSecurity http) throws Exception {

        http
                .securityMatcher("/api/mobile/**", "/backend/api/mobile/**")
                .csrf(csrf -> csrf.disable())
                .formLogin(form -> form.disable())
                .httpBasic(basic -> basic.disable())
                .sessionManagement(session ->
                        session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                )
                .authorizeHttpRequests(auth -> auth
                        // 🔓 로그인, 회원가입 관련 허용
                        .requestMatchers(
                                "/api/mobile/member/login",
                                "/api/mobile/member/check-device",    // 기기 확인
                                "/api/mobile/member/auth/send-code",  // 인증번호 발송
                                "/api/mobile/member/auth/verify-code",// 인증번호 검증
                                "/api/mobile/member/register-device", // 기기 등록 허용
                                "/api/mobile/member/login-pin",       // PIN 로그인
                                "/api/mobile/surveys/**",             // 설문 조회/저장
                                "/backend/api/mobile/surveys/**"      // 설문 조회/저장 (backend prefix)
                        ).permitAll()

                        // 🔓 환율 조회 API는 로그인 없이 허용
                        .requestMatchers(
                                "/api/mobile/exchange/rates",       // 전체 환율
                                "/api/mobile/exchange/rates/**"   // 특정 통화 히스토리

                        ).permitAll()
                        .requestMatchers(
                                "/api/mobile/voice/process"
                        ).permitAll()
                        .requestMatchers(
                                "/api/mobile/member/auth/send-code-hp",
                                "/api/mobile/member/auth/verify-code-hp",
                                "/member/api/register"
                        ).permitAll()
                        .requestMatchers(
                                "/api/mobile/mypage/chatbot"
                        ).permitAll()

                        // 🔐 나머지는 전부 인증 필요 (환전 신청, 계좌 조회 등)
                        .anyRequest().authenticated()
                )
                .addFilterBefore(
                        new JwtAuthenticationFilter(jwtTokenProvider),
                        UsernamePasswordAuthenticationFilter.class
                )
                // 모바일은 로그인 페이지 리다이렉트가 아닌 401 에러 코드 반환
                .exceptionHandling(exception ->
                        exception.authenticationEntryPoint(new HttpStatusEntryPoint(HttpStatus.UNAUTHORIZED))
                );

        return http.build();
    }

    // 💻 2. 웹(Web)용 시큐리티 설정 (웹은 로그인 페이지 리다이렉트 필요)
    @Bean
    @Order(2)
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .formLogin(form -> form.disable())
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(
                                "/", "/member/**", "/css/**", "/js/**", "/images/**",
                                "/uploads/**", "/api/register","/api/risk/**",
                                "/api/surveys/**", "/backend/api/surveys/**"
                        ).permitAll()
                        .requestMatchers("/admin/**").permitAll() // 개발용
                        .anyRequest().authenticated()
                )
                .addFilterBefore(new JwtAuthenticationFilter(jwtTokenProvider), UsernamePasswordAuthenticationFilter.class)
                // 웹은 인증 실패 시 로그인 페이지로 이동 (기존 클래스 사용)
                .exceptionHandling(exception ->
                        exception.authenticationEntryPoint(customAuthenticationEntryPoint)
                );

        return http.build();
    }
}
