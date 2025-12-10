/*
Signature(서명): 이 클래스는 jwt.secret이라는 비밀키를 사용해 토큰에 서명.
해커가 토큰 내부의 데이터(예: 권한)를 조작하더라도,
이 비밀키가 없으면 서명이 깨져서 서버가 "이거 위조됐네?" 하고 바로 알아챔.

Claim: 토큰 안에 담기는 정보 조각. 보통 아이디나 권한을 담음.
 */
package kr.co.api.backend.jwt;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Slf4j
@Component
public class JwtTokenProvider {

    private Key key;
    private final long tokenValidityInMilliseconds = 1000 * 60 * 20; // 20분

    @Value("${jwt.secret}")
    private String secretKey;

    @PostConstruct
    public void init() {
        this.key = Keys.hmacShaKeyFor(secretKey.getBytes());
    }

    // 1. 토큰 생성
    public String createToken(String userId, String role, String custName) {
        Date now = new Date();
        Date validity = new Date(now.getTime() + tokenValidityInMilliseconds);

        return Jwts.builder()
                .setSubject(userId)
                .claim("role", role)
                .claim("custName", custName)
                .setIssuedAt(now)
                .setExpiration(validity)
                .signWith(key, SignatureAlgorithm.HS256)
                .compact();
    }

    // 2. 토큰에서 인증 정보 조회
    public Authentication getAuthentication(String token) {
        Claims claims = Jwts.parserBuilder().setSigningKey(key).build()
                .parseClaimsJws(token).getBody();

        // 토큰에서 이름 꺼내기 (없으면 "Unknown" 처리)
        String custName = claims.get("custName", String.class);
        if (custName == null) {
            custName = "Unknown";
        }

        // 관리자 로그인 시큐리티 admin > hasRole
        String role = claims.get("role", String.class);
        List<GrantedAuthority> authorities = new ArrayList<>();
        if(role != null && !role.isBlank()) {
            authorities.add(new SimpleGrantedAuthority(role));
        }


        // CustomUserDetails 객체 생성
        String username = claims.getSubject();
        //CustomUserDetails userDetails = new CustomUserDetails(claims.getSubject(), "", Collections.emptyList(), custName);
        //return new UsernamePasswordAuthenticationToken(userDetails, "", userDetails.getAuthorities());
        CustomUserDetails userDetails =
                new CustomUserDetails(username, "", authorities, custName);

        return new UsernamePasswordAuthenticationToken(userDetails, "", authorities);

    }

    // 3. 쿠키에서 토큰 추출
    public String resolveToken(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("accessToken".equals(cookie.getName())) {
                    return cookie.getValue();
                }
            }
        }
        return null;
    }

    // 4. 토큰 검증
    public boolean validateToken(String token) {
        try {
            Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            //log.error("유효하지 않은 JWT 토큰입니다: {}", e.getMessage());
            return false;
        }
    }
}