package kr.co.api.backend.service;

import kr.co.api.flobankapi.dto.ApResponseDTO;
import kr.co.api.flobankapi.dto.CustInfoDTO;
import kr.co.api.flobankapi.mapper.MemberMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class MemberService {

    private static final String API_MEMBER_REGISTER   = "MEMBER_REGISTER";
    private static final String API_MEMBER_CHECK_ID   = "MEMBER_CHECK_ID";
    private static final String API_MEMBER_CHECK_EMAIL= "MEMBER_CHECK_EMAIL";
    // AP 서버 공용 통신 모듈
    private final ApRequestService apRequestService;
    private final MemberMapper memberMapper;



    public ApResponseDTO checkEmail(String custEmail) {
        if (!StringUtils.hasText(custEmail)) {
            return ApResponseDTO.fail("이메일을 입력하세요.");
        }
        try {
            Map<String, Object> payload = Map.of("custEmail", custEmail);
            return apRequestService.execute(API_MEMBER_CHECK_EMAIL, payload, ApResponseDTO.class);

        } catch (Exception e) {
            return ApResponseDTO.fail("AP 통신 오류: " + e.getMessage());
        }
    }

    private ApResponseDTO validateForRegister(CustInfoDTO d) {
        if (!StringUtils.hasText(d.getCustId()))
            return ApResponseDTO.fail("아이디를 입력하세요.");

        if (!StringUtils.hasText(d.getCustPw()))
            return ApResponseDTO.fail("비밀번호를 입력하세요.");

        if (d.getCustPw().length() < 4 || d.getCustPw().length() > 16)
            return ApResponseDTO.fail("비밀번호는 8~16자여야 합니다.");

        if (!StringUtils.hasText(d.getCustName()))
            return ApResponseDTO.fail("이름을 입력하세요.");

        if (d.getCustBirthDt() == null)
            return ApResponseDTO.fail("생년월일을 입력하세요.");

        if (!StringUtils.hasText(d.getCustGen()))
            return ApResponseDTO.fail("성별을 선택하세요.");

        if (!StringUtils.hasText(d.getCustEmail()))
            return ApResponseDTO.fail("이메일을 입력하세요.");

        if (!StringUtils.hasText(d.getCustHp()))
            return ApResponseDTO.fail("휴대폰 번호를 입력하세요.");

        return null; // 검증 통과
    }
}