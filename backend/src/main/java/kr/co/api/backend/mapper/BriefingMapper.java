package kr.co.api.backend.mapper;

import kr.co.api.backend.dto.BriefingDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface BriefingMapper {
    BriefingDTO selectLatestBriefingByMode(@Param("mode") String mode);
}
