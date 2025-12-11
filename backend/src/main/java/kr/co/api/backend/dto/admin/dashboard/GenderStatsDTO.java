package kr.co.api.backend.dto.admin.dashboard;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class GenderStatsDTO {
    //성별
    private String gender;
    private long count;
}
