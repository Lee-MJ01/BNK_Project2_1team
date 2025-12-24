package kr.co.api.backend.dto.admin;

public record DeviceTokenUpsertReqDTO(
        String token,
        String platform,   // ANDROID / IOS / WEB
        String deviceId,
        String appVersion,
        String locale
) {}
