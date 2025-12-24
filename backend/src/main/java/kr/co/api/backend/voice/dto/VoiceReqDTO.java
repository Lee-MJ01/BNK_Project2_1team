package kr.co.api.backend.voice.dto;

import kr.co.api.backend.voice.domain.EndReason;
import kr.co.api.backend.voice.domain.VoiceIntent;
import lombok.Data;

@Data
public class VoiceReqDTO {
    private String text;
    private String dpstId;

    private VoiceIntent intent;
    private EndReason clientEndReason;
}
