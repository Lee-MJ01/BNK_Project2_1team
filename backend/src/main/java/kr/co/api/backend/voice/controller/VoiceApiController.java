package kr.co.api.backend.voice.controller;

import kr.co.api.backend.voice.dto.VoiceReqDTO;
import kr.co.api.backend.voice.dto.VoiceResDTO;
import kr.co.api.backend.voice.service.VoiceFlowService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;


@Slf4j
@RestController
@RequestMapping("/api/mobile/voice")
@RequiredArgsConstructor
public class VoiceApiController {
    private final VoiceFlowService flowService;

    @PostMapping("/process")
    public VoiceResDTO process (@RequestBody VoiceReqDTO voiceReq, @RequestHeader("X-SESSION-ID") String sessionId) {
        log.info("🎤 [VOICE] sessionId={}", sessionId);
        log.info("🎤 [VOICE] text={}", voiceReq.getText());
        log.info("🎤 [VOICE] dpstId={}", voiceReq.getDpstId());
        log.info("🎤 [VOICE] intent={}", voiceReq.getIntent());
        VoiceResDTO res = flowService.handle(sessionId, voiceReq);
        log.info("🎤 [VOICE] nextState={}", res.getCurrentState());
        log.info("🎤 [VOICE] endReason={}", res.getEndReason());
        return res;
    }
}