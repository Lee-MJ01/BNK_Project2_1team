package kr.co.api.backend.config;

import kr.co.api.backend.jwt.JwtAuthenticationFilter;
import kr.co.api.backend.jwt.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtTokenProvider jwtTokenProvider;

    @Value("${security.remember-me.seconds:0}")
    private int rememberMeSeconds;

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http, CustomAuthenticationEntryPoint customAuthenticationEntryPoint) throws Exception {
        http
                .csrf(csrf -> csrf.disable()) // JWT 사용 시 CSRF 비활성화 가능 (쿠키 사용 시엔 켜는 게 좋지만, 지금은 복잡도 줄이기 위해 끔)
                .formLogin(form -> form.disable())
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)) // 세션 안 씀
                .authorizeHttpRequests(auth -> auth
                                .requestMatchers("/",
                                        "/member/login",
                                        "/member/register",
                                        "/css/**",
                                        "/js/**", "/images/**",
                                        "/mypage/chatbot",
                                        "/remit/info",
                                        "/admin/login"
                                ).permitAll()
//                        .requestMatchers("/admin/**").hasRole("ADMIN")  //이게 걸린거
                                .requestMatchers("/admin/**").permitAll()   //이게 안걸린거 (개발용)
                                .requestMatchers("/mypage/**").authenticated() // 마이페이지는 로그인 필요
                                .requestMatchers("/remit/**").authenticated()
                                .requestMatchers("/exchange/step1").authenticated()
                                .requestMatchers("/exchange/step2").authenticated()
                                .requestMatchers("/exchange/step3").authenticated()
                                .requestMatchers("/deposit/deposit_step1").authenticated()
                                .requestMatchers("/deposit/deposit_step2").authenticated()
                                .requestMatchers("/deposit/deposit_step3").authenticated()
                                .requestMatchers("/deposit/deposit_step4").authenticated()
                                .requestMatchers("/customer/qna_write/**").authenticated()
                                .requestMatchers("/customer/qna_edit/**").authenticated()
                                .requestMatchers("/customer/qna_delete/**").authenticated()
                                .requestMatchers("/member/**").permitAll()
                                .requestMatchers("/uploads/**").permitAll()
                                .anyRequest().permitAll() // 일단 나머지는 다 허용 (개발 편의상)
                )
                // 우리가 만든 필터를 UsernamePasswordAuthenticationFilter 앞에 끼워넣기
                .addFilterBefore(new JwtAuthenticationFilter(jwtTokenProvider), UsernamePasswordAuthenticationFilter.class)
                .exceptionHandling(exception -> exception
                        .authenticationEntryPoint(customAuthenticationEntryPoint)   // ★ 미인증 사용자// ★ 권한 부족
                );

        return http.build();
    }
}
