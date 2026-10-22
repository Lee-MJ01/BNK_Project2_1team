package kr.co.api.backend.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.reactive.function.client.ClientResponse;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.server.ResponseStatusException;
import reactor.core.publisher.Mono;

import java.util.concurrent.atomic.AtomicReference;
import java.net.URI;

import static org.junit.jupiter.api.Assertions.*;

class AddressSearchServiceTest {
    private static final String KEY = "address-test-fixture";

    @Test
    void keyStaysOnServerAndKeywordIsEncoded() {
        AtomicReference<URI> requested = new AtomicReference<>();
        WebClient.Builder builder = WebClient.builder().exchangeFunction(request -> {
            requested.set(request.url());
            return Mono.just(ClientResponse.create(HttpStatus.OK)
                    .header("Content-Type", MediaType.TEXT_PLAIN_VALUE)
                    .body("""
                            {"results":{"common":{"errorCode":"0","errorMessage":"address-test-fixture"},
                            "juso":[{"zipNo":"12345","roadAddrPart1":"부산 해운대로","confmKey":"address-test-fixture"}]},
                            "confmKey":"address-test-fixture"}
                            """)
                    .build());
        });
        JsonNode response = new AddressSearchService(builder, KEY, new ObjectMapper()).search("  부산 & 서울  ");
        assertEquals("business.juso.go.kr", requested.get().getHost());
        assertTrue(requested.get().getRawQuery().contains("%26"));
        assertTrue(requested.get().getRawQuery().contains("confmKey=" + KEY));
        assertEquals("12345", response.path("results").path("juso").get(0).path("zipNo").asText());
        assertFalse(response.toString().contains(KEY));
        assertFalse(response.toString().contains("confmKey"));
    }

    @Test
    void invalidKeywordsNeverReachProvider() {
        AddressSearchService service = new AddressSearchService(WebClient.builder().exchangeFunction(request -> {
            fail("Invalid search must not call provider");
            return Mono.empty();
        }), KEY, new ObjectMapper());
        for (String keyword : new String[]{null, "", "가", "가".repeat(101)}) {
            assertEquals(HttpStatus.BAD_REQUEST,
                    assertThrows(ResponseStatusException.class, () -> service.search(keyword)).getStatusCode());
        }
    }

    @Test
    void missingConfigurationReturns503() {
        AddressSearchService service = new AddressSearchService(WebClient.builder(), "", new ObjectMapper());
        assertEquals(HttpStatus.SERVICE_UNAVAILABLE,
                assertThrows(ResponseStatusException.class, () -> service.search("부산")).getStatusCode());
    }

    @Test
    void providerErrorsNeverExposeRequestUrlOrKey() {
        WebClient.Builder builder = WebClient.builder().exchangeFunction(request ->
                Mono.error(new RuntimeException("Provider failed: " + request.url())));
        ResponseStatusException error = assertThrows(ResponseStatusException.class,
                () -> new AddressSearchService(builder, KEY, new ObjectMapper()).search("부산"));
        assertEquals(HttpStatus.BAD_GATEWAY, error.getStatusCode());
        assertFalse(error.toString().contains(KEY));
        assertNull(error.getCause());
    }

    @Test
    void malformedProviderResponseReturns502() {
        WebClient.Builder builder = WebClient.builder().exchangeFunction(request ->
                Mono.just(ClientResponse.create(HttpStatus.OK)
                        .header("Content-Type", MediaType.APPLICATION_JSON_VALUE).body("{}").build()));
        assertEquals(HttpStatus.BAD_GATEWAY, assertThrows(ResponseStatusException.class,
                () -> new AddressSearchService(builder, KEY, new ObjectMapper()).search("부산")).getStatusCode());
    }
}
