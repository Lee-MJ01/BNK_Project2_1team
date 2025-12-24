package kr.co.api.backend.voice.domain;

public enum VoiceIntent {
    REQ_RECOMMEND,
    REQ_OTHER,
    REQ_EXPLAIN,
    REQ_JOIN,

    AFFIRM,
    DENY,

    PROCEED,
    CONFIRM,

    REQ_BACK,
    REQ_CANCEL,

    SUCCESS,
    UNKNOWN
}
