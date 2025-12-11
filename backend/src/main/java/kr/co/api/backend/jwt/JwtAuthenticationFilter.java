/*
이 필터가 동작함으로써 컨트롤러에서는 누가 로그인했는지 신경 쓸 필요가 없음.
토큰이 유효하다면 Spring Security가 이미 로그인 처리를 완료해 둔 상태가 됨.

토큰이 없거나 유효하지 않으면 SecurityContext가 비어 있게 되고,
SecurityConfig에서 설정한 권한 규칙에 따라 403(Forbidden) 에러가 발생.
 */
package kr.co.api.backend.jwt;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.GenericFilterBean;

import java.io.IOException;

@RequiredArgsConstructor
public class JwtAuthenticationFilter extends GenericFilterBean {

    private final JwtTokenProvider jwtTokenProvider;

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        // 1. 쿠키에서 토큰 추출
        String token = jwtTokenProvider.resolveToken((HttpServletRequest) request);

        // 2. 토큰 유효성 검사
        if (token != null && jwtTokenProvider.validateToken(token)) {
            // 3. 유효하면 인증 객체를 만들어 시큐리티 컨텍스트에 저장 (로그인 처리 완료)
            Authentication authentication = jwtTokenProvider.getAuthentication(token);
            SecurityContextHolder.getContext().setAuthentication(authentication);
            }

        // 4. 다음 필터로 이동
        chain.doFilter(request, response);
    }
}