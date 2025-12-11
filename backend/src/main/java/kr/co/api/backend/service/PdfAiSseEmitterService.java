package kr.co.api.backend.service;

import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class PdfAiSseEmitterService {

    private final Map<Long, SseEmitter> emitters = new ConcurrentHashMap<>();

    public SseEmitter subscribe(Long pdfId) {
        SseEmitter emitter = new SseEmitter(0L);  // no timeout
        emitters.put(pdfId, emitter);

        emitter.onCompletion(() -> emitters.remove(pdfId));
        emitter.onTimeout(() -> emitters.remove(pdfId));

        return emitter;
    }

    public void sendProgress(Long pdfId, int progress) {
        SseEmitter emitter = emitters.get(pdfId);

        if (emitter != null) {
            try {
                // 🔥 이벤트 이름 삭제 → default message 이벤트로 전송됨
                emitter.send(
                        SseEmitter.event()
                                .data(progress)
                );
            } catch (Exception e) {
                emitters.remove(pdfId);
            }
        }
    }
}
