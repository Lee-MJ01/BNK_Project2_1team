// flobank_ap와 실제 TCP 통신 담당 (매우 중요)
package kr.co.api.backend.tcp;

import org.springframework.integration.annotation.MessagingGateway;

/**
 * flobank_api의 모든 서비스들이 AP 서버와 통신할 때 사용하는 공식 출입구(게이트웨이)
 *
 * @MessagingGateway: 이 인터페이스의 구현체는 Spring Integration이 자동으로 생성해 줍니다.
 * defaultRequestChannel: 이 인터페이스의 메서드가 호출되면, 메시지를 "tcpClientRequestChannel"로 보냅니다.
 */
@MessagingGateway(defaultRequestChannel = "tcpClientRequestChannel")
public interface ApGateway {

    /**
     * AP 서버에 JSON 문자열(byte[])을 보내고,
     * AP 서버로부터 JSON 문자열(byte[]) 응답을 받습니다.
     *
     * @param requestPayload 서버로 보낼 JSON 문자열 (byte[])
     * @return 서버로부터 받은 JSON 문자열 (byte[])
     */
    byte[] sendAndReceive(byte[] requestPayload);

    /**
     * (참고) Spring이 byte[] <-> String 자동 변환을 지원하므로
     * 서비스단에서는 아래와 같이 String을 사용하는 것이 더 편리할 수 있습니다.
     *
     * @param jsonRequest 서버로 보낼 JSON 문자열
     * @return 서버로부터 받은 JSON 문자열
     */
    String sendAndReceive(String jsonRequest);
}