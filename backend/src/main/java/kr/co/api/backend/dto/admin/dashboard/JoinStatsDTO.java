package kr.co.api.backend.dto.admin.dashboard;


import lombok.*;

@Getter
@Setter
@Data
@AllArgsConstructor
@NoArgsConstructor
public class JoinStatsDTO {
    //가입자
    private String baseDate;  // "2025-11-19", "2025-11", "2025-W46" 등
    private int joinCount;

}
