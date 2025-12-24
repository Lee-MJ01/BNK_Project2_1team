package kr.co.api.backend.controller.admin;

import kr.co.api.backend.dto.admin.DeviceTokenUpsertReqDTO;
import kr.co.api.backend.service.admin.DeviceTokenService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import java.util.Map;

@RestController
@RequestMapping("/api/device-tokens")
public class DeviceTokenController {

    private final DeviceTokenService deviceTokenService;

    public DeviceTokenController(DeviceTokenService deviceTokenService) {
        this.deviceTokenService = deviceTokenService;
    }

    @PostMapping
    public Map<String, Object> upsert(@RequestBody DeviceTokenUpsertReqDTO req) {
        if (req.token() == null || req.token().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "token is required");
        }
        if (req.platform() == null || req.platform().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "platform is required");
        }

        deviceTokenService.upsert(req);
        return Map.of("ok", true);
    }
}