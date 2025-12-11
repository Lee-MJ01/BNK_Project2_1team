package kr.co.api.backend.util;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

@Component // 이 클래스가 스프링 컨테이너에 의해 관리되어야 설정 파일(application.yml)을 읽어올 수 있음.
public class AesUtil {

    // ✅ 1. 암호화 알고리즘 설정 (AES / 운용모드 CBC / 패딩 PKCS5)
    private static final String alg = "AES/CBC/PKCS5Padding";

    // ✅ 2. 비밀키 (32byte = 256bit) -> application.yml 파일에 별로 관리
    private static String key;

    // ✅ 3. 초기화 벡터 (16byte)
    private static String iv;

    @Value("${flobank.aes.secret}")
    public void setKey(String key) {
        AesUtil.key = key;
        iv = key.substring(0, 16);
    }

    /**
     * 암호화 메서드
     * @param text 암호화할 평문 (예: 주민번호 원본)
     * @return 암호화된 문자열 (Base64 인코딩)
     */
    public static String encrypt(String text) {
        try {
            Cipher cipher = Cipher.getInstance(alg);
            SecretKeySpec keySpec = new SecretKeySpec(key.getBytes(), "AES");
            IvParameterSpec ivParamSpec = new IvParameterSpec(iv.getBytes());

            cipher.init(Cipher.ENCRYPT_MODE, keySpec, ivParamSpec);

            byte[] encrypted = cipher.doFinal(text.getBytes(StandardCharsets.UTF_8));

            // 암호화된 바이트 배열을 문자열로 보기 위해 Base64 인코딩
            return Base64.getEncoder().encodeToString(encrypted);
        } catch (Exception e) {
            throw new RuntimeException("암호화 중 오류 발생: " + e.getMessage(), e);
        }
    }

    /**
     * 복호화 메서드
     * @param cipherText 암호화된 문자열
     * @return 복호화된 평문 (예: 주민번호 원본)
     */
    public static String decrypt(String cipherText) {
        try {
            Cipher cipher = Cipher.getInstance(alg);
            SecretKeySpec keySpec = new SecretKeySpec(key.getBytes(), "AES");
            IvParameterSpec ivParamSpec = new IvParameterSpec(iv.getBytes());

            cipher.init(Cipher.DECRYPT_MODE, keySpec, ivParamSpec);

            // Base64 디코딩 후 복호화 수행
            byte[] decodedBytes = Base64.getDecoder().decode(cipherText);
            byte[] decrypted = cipher.doFinal(decodedBytes);

            return new String(decrypted, StandardCharsets.UTF_8);
        } catch (Exception e) {
            throw new RuntimeException("복호화 중 오류 발생: " + e.getMessage(), e);
        }
    }
}