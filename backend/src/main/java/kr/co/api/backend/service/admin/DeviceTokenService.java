package kr.co.api.backend.service.admin;

import kr.co.api.backend.dto.admin.DeviceTokenUpsertReqDTO;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

@Service
public class DeviceTokenService {

    private final NamedParameterJdbcTemplate jdbc;

    public DeviceTokenService(NamedParameterJdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public void upsert(DeviceTokenUpsertReqDTO req) {
        // ✅ 너희 프로젝트에 맞게 userId/adminId를 가져오거나, 일단 null로 둬도 됨
        String userId = null;
        String adminId = null;

        String sql = """
      MERGE INTO TB_DEVICE_TOKEN t
      USING (SELECT :token AS token FROM dual) s
      ON (t.TOKEN = s.token)
      WHEN MATCHED THEN UPDATE SET
        t.USER_ID      = :userId,
        t.ADMIN_ID     = :adminId,
        t.PLATFORM     = :platform,
        t.DEVICE_ID    = :deviceId,
        t.APP_VERSION  = :appVersion,
        t.LOCALE       = :locale,
        t.IS_ACTIVE    = 'Y',
        t.LAST_SEEN_AT = SYSTIMESTAMP,
        t.UPDATED_AT   = SYSTIMESTAMP
      WHEN NOT MATCHED THEN INSERT (
        USER_ID, ADMIN_ID, PLATFORM, DEVICE_ID, TOKEN, APP_VERSION, LOCALE,
        IS_ACTIVE, LAST_SEEN_AT, CREATED_AT, UPDATED_AT
      ) VALUES (
        :userId, :adminId, :platform, :deviceId, :token, :appVersion, :locale,
        'Y', SYSTIMESTAMP, SYSTIMESTAMP, SYSTIMESTAMP
      )
      """;

        MapSqlParameterSource p = new MapSqlParameterSource()
                .addValue("userId", userId)
                .addValue("adminId", adminId)
                .addValue("platform", req.platform().toUpperCase())
                .addValue("deviceId", req.deviceId())
                .addValue("token", req.token())
                .addValue("appVersion", req.appVersion())
                .addValue("locale", req.locale());

        jdbc.update(sql, p);
    }
}
