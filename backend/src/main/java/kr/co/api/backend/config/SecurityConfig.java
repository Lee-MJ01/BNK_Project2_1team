package kr.co.api.backend.config;

import kr.co.api.backend.jwt.JwtAuthenticationFilter;
import kr.co.api.backend.jwt.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
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

    @Value("${security.remember-me.seconds:0}")
    private int rememberMeSeconds;

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    /**
     * 1) API 전용 체인: /api/** 는 절대 redirect 하지 말고 401로만 응답
     */
    @Bean
    @Order(1)
    public SecurityFilterChain apiFilterChain(HttpSecurity http) throws Exception {
        http
                .securityMatcher("/api/**")
                .csrf(csrf -> csrf.disable())
                .formLogin(form -> form.disable())
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        .anyRequest().authenticated()
                )
                .addFilterBefore(new JwtAuthenticationFilter(jwtTokenProvider), UsernamePasswordAuthenticationFilter.class)
                .exceptionHandling(ex -> ex
                                // 핵심: API는 미인증 시 302로 로그인 페이지 보내지 말고 401을 내려라
                                .authenticationEntryPoint(new HttpStatusEntryPoint(HttpStatus.UNAUTHORIZED))
                        // 권한 부족은 403
                        // .accessDeniedHandler((req,res,e)-> res.sendError(HttpStatus.FORBIDDEN.value()))
                );

        return http.build();
    }

    /**
     *  2) WEB 전용 체인: 나머지(/member, /exchange/step1 등) 기존 정책 유지 (redirect 허용)
     */
    @Bean
    @Order(2)
    public SecurityFilterChain webFilterChain(HttpSecurity http,
                                              CustomAuthenticationEntryPoint customAuthenticationEntryPoint) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .formLogin(form -> form.disable())
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
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

                        // .requestMatchers("/admin/**").hasRole("ADMIN")
                        .requestMatchers("/admin/**").permitAll()   // 개발용
                        .requestMatchers("/mypage/**").authenticated()
                        .requestMatchers("/remit/**").authenticated()
                        .requestMatchers("/exchange/step1").authenticated()
                        .requestMatchers("/exchange/step2").authenticated()
                        .requestMatchers("/exchange/step3").authenticated()

                        //  여기서 /api/** 는 web체인에서 굳이 만질 필요 없음 (api체인이 먼저 잡아감)
                        // .requestMatchers("/api/exchange/**").authenticated()

                        .requestMatchers("/deposit/deposit_step1").authenticated()
                        .requestMatchers("/deposit/deposit_step2").authenticated()
                        .requestMatchers("/deposit/deposit_step3").authenticated()
                        .requestMatchers("/deposit/deposit_step4").authenticated()
                        .requestMatchers("/customer/qna_write/**").authenticated()
                        .requestMatchers("/customer/qna_edit/**").authenticated()
                        .requestMatchers("/customer/qna_delete/**").authenticated()
                        .requestMatchers("/member/**").permitAll()
                        .requestMatchers("/uploads/**").permitAll()
                        .anyRequest().permitAll()
                )
                .addFilterBefore(new JwtAuthenticationFilter(jwtTokenProvider), UsernamePasswordAuthenticationFilter.class)
                .exceptionHandling(ex -> ex
                        //  웹은 기존처럼 로그인 페이지로 보내는 엔트리포인트 사용
                        .authenticationEntryPoint(customAuthenticationEntryPoint)
                );

        return http.build();
    }
}
