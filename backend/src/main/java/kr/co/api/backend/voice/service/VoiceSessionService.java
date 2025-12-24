package kr.co.api.backend.voice.service;

import kr.co.api.backend.voice.domain.VoiceState;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class VoiceSessionService {

    private final Map<String, VoiceState> sessionStore = new ConcurrentHashMap<>();

    // productCode 세션 저장
    private final Map<String, String> productStore = new ConcurrentHashMap<>();

    // UNKNOWN 재시도 카운트 (over 3 retries -> ERROR 종료)
    private final Map<String, Integer> unknownCountStore = new ConcurrentHashMap<>();

    public VoiceState getState(String sessionId) {
        return sessionStore.getOrDefault(sessionId, VoiceState.S0_IDLE);
    }

    public void updateState(String sessionId, VoiceState state) {
        sessionStore.put(sessionId, state);
    }

    public String getProductCode(String sessionId) {
        return productStore.get(sessionId);
    }

    public void setProductCode(String sessionId, String productCode) {
        if (productCode == null) return;
        productStore.put(sessionId, productCode);
    }

    public int incUnknownCount(String sessionId) {
        int next = unknownCountStore.getOrDefault(sessionId, 0) + 1;
        unknownCountStore.put(sessionId, next);
        return next;
    }

    public void resetUnknownCount(String sessionId) {
        unknownCountStore.put(sessionId, 0);
    }

    public void clear(String sessionId) {
        sessionStore.remove(sessionId);
        productStore.remove(sessionId);
        unknownCountStore.remove(sessionId);
    }
}

