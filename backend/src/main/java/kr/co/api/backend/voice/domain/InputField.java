package kr.co.api.backend.voice.domain;


public enum InputField {
    WITHDRAW_ACCOUNT,
    WITHDRAW_PASSWORD,
    WITHDRAW_CURRENCY,
    NEW_CURRENCY,
    NEW_AMOUNT,
    NEW_PERIOD,
    AUTO_RENEW,
    AUTO_TERMINATE,
    DEPOSIT_PASSWORD,       // 분석은 하지만
    DEPOSIT_PASSWORD_CHECK // 실제 값은 안 받음
}
