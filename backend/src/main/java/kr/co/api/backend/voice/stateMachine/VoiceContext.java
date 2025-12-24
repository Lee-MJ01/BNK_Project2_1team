package kr.co.api.backend.voice.stateMachine;

public class VoiceContext {

    private final String productCode; // nullable

    public VoiceContext(String productCode) {
        this.productCode = productCode;
    }

    public String productCode() {
        return productCode;
    }

    public boolean hasProduct() {
        return productCode != null;
    }
}
