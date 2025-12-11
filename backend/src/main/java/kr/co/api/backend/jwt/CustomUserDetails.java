package kr.co.api.backend.jwt;

import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.User;

import java.util.Collection;

@Getter
public class CustomUserDetails extends User {

    private final String custName; // 실제 이름 (예: 홍길동)

    public CustomUserDetails(String username, String password, Collection<? extends GrantedAuthority> authorities, String custName) {
        super(username, password, authorities);
        this.custName = custName;
    }
}