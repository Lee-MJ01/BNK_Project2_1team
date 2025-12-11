package kr.co.api.backend.mapper.admin;

import kr.co.api.backend.dto.AdminInfoDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface AdminInfoMapper {
    @Select("""
            SELECT
                ADMIN_ID   AS adminId,
                ADMIN_PW   AS adminPw,
                ADMIN_TYPE AS adminType,
                ADMIN_PH AS adminPh
            FROM TB_ADMIN_INFO
            WHERE ADMIN_ID = #{adminId}
            """)

    AdminInfoDTO findById(@Param("adminId") String adminId);
    @Select("SELECT COUNT(*) FROM TB_ADMIN_INFO")
    int countAdmins();
}
