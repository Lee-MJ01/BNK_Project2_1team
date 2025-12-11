package kr.co.api.backend.service.admin;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletResponse;
import kr.co.api.backend.dto.AdminInfoDTO;
import kr.co.api.backend.jwt.JwtTokenProvider;
import kr.co.api.backend.mapper.admin.AdminInfoMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class AdminAuthService {
    private final AdminInfoMapper adminInfoMapper;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    public void login(String adminId,
                      String rawPassword,
                      String adminPh,
                      String code,
                      HttpServletResponse response) {



        int count = adminInfoMapper.countAdmins();
        // 1. TB_ADMIN_INFO 에서 관리자 조회
        AdminInfoDTO admin = adminInfoMapper.findById(adminId);
        if (admin == null) {
            throw new BadCredentialsException("존재하지 않는 관리자입니다.");
        }

        // 비밀번호 검증
        if (!rawPassword.equals(admin.getAdminPw())) {
            throw new BadCredentialsException("비밀번호가 일치하지 않습니다.");
        }

        // ★ adminType에 따라 role 결정
        String role;
        if (admin.getAdminType() != null && admin.getAdminType() == 1) {
            role = "ROLE_ADMIN";   // 슈퍼 관리자
        } else {
            throw new BadCredentialsException("관리자 권한이 없습니다."); // 일반 관리자는 접근 불가
        }

        // JwtTokenProvider에 맞는 createToken(...) 사용
        // (이미 userId, role, custName 구조로 만들기로 했으니 그대로 사용)
        String token = jwtTokenProvider.createToken(
                admin.getAdminId(),  // userId
                role,                // "ROLE_ADMIN"
                admin.getAdminId()   // ??
        );

        // 5. accessToken 쿠키에 JWT 저장 (JwtTokenProvider.resolveToken 이 이 이름을 찾아야 함)
        Cookie cookie = new Cookie("accessToken", token);
        cookie.setHttpOnly(true);
        cookie.setPath("/");        // 전체 경로에서 사용 가능
        cookie.setMaxAge(60 * 60);  // 1시간

        response.addCookie(cookie);
    }
}
