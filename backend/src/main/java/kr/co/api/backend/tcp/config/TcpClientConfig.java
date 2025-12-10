// TCP 클라이언트 설정 (Spring Integration)
package kr.co.api.backend.tcp.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.integration.annotation.IntegrationComponentScan;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.integration.channel.DirectChannel;
import org.springframework.integration.config.EnableIntegration;
import org.springframework.integration.ip.tcp.TcpOutboundGateway;
import org.springframework.integration.ip.tcp.connection.AbstractClientConnectionFactory;
import org.springframework.integration.ip.tcp.connection.CachingClientConnectionFactory;
import org.springframework.integration.ip.tcp.connection.TcpNioClientConnectionFactory;
import org.springframework.integration.ip.tcp.serializer.ByteArrayLfSerializer;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.MessageHandler;

@Configuration
@EnableIntegration
@IntegrationComponentScan("kr.co.api.flobankapi.tcp") // ApGateway를 찾기 위한 스캔
public class TcpClientConfig {

    // application.yml에서 서버 정보(localhost)를 가져옵니다.
    @Value("${flobank.ap.host}")
    private String host; //

    // application.yml에서 포트 번호(9090)를 가져옵니다.
    @Value("${flobank.ap.port}")
    private int port; //

    /**
     * 1. TCP 클라이언트 연결 팩토리 (전화기)
     * - AP 서버(localhost:9090)로 연결을 생성하고 관리합니다.
     * - CachingClientConnectionFactory: 성능 향상을 위해 TCP 연결을 풀링(재사용)합니다.
     */
    @Bean
    public AbstractClientConnectionFactory clientConnectionFactory() {
        TcpNioClientConnectionFactory factory = new TcpNioClientConnectionFactory(host, port);

        // 2. Serializer / Deserializer 설정
        // - 서버(flobank_ap)와 반드시 동일한 ByteArrayLfSerializer를 사용합니다.
        ByteArrayLfSerializer serializer = new ByteArrayLfSerializer();
        factory.setSerializer(serializer);
        factory.setDeserializer(serializer);

        // (중요) 연결을 한 번만 사용하고 닫는 것이 아니라, 계속 재사용(풀링)합니다.
        factory.setSingleUse(false);

        // Caching을 통해 커넥션 풀을 관리합니다.
        CachingClientConnectionFactory cachingFactory = new CachingClientConnectionFactory(factory, 10); // 최대 10개 연결 풀링
        return cachingFactory;
    }

    /**
     * 3. 요청 메시지 채널 (발신 라인)
     * - 'ApGateway' 인터페이스가 이 채널로 메시지를 보냅니다.
     */
    @Bean
    public MessageChannel tcpClientRequestChannel() {
        return new DirectChannel();
    }

    /**
     * 4. TCP 아웃바운드 게이트웨이 (발신 창구)
     * - 'tcpClientRequestChannel'에 메시지가 들어오면,
     * - 'clientConnectionFactory'(전화기)를 통해 AP 서버로 메시지를 전송(send)하고,
     * - 응답(reply)이 오면 응답 채널로 반환합니다.
     */
    @Bean
    @ServiceActivator(inputChannel = "tcpClientRequestChannel")
    public MessageHandler tcpOutboundGateway(AbstractClientConnectionFactory clientConnectionFactory) {
        TcpOutboundGateway gateway = new TcpOutboundGateway();
        gateway.setConnectionFactory(clientConnectionFactory);
        gateway.setRequiresReply(true); // 반드시 응답을 받아야 함
        gateway.setRequestTimeout(5000); // 5초 타임아웃 (응답이 5초간 없으면 에러)
        return gateway;
    }
}