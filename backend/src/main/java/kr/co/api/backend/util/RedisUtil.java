package kr.co.api.backend.util;

import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.stereotype.Component;

import java.time.Duration;

@Component
@RequiredArgsConstructor
public class RedisUtil {

    // RedisConfig에서 등록한 redisTemplate을 주입받습니다.
    // <String, String> 타입만 쓸 것이므로 StringRedisTemplate을 써도 무방합니다.
    private final StringRedisTemplate stringRedisTemplate;

    // 1. 데이터 저장 (TTL 설정 포함)
    public void setDataExpire(String key, String value, long durationSeconds) {
        ValueOperations<String, String> valueOperations = stringRedisTemplate.opsForValue();
        Duration expireDuration = Duration.ofSeconds(durationSeconds);
        valueOperations.set(key, value, expireDuration);
    }

    // 2. 데이터 조회
    public String getData(String key) {
        ValueOperations<String, String> valueOperations = stringRedisTemplate.opsForValue();
        return valueOperations.get(key);
    }

    // 3. 데이터 삭제
    public void deleteData(String key) {
        stringRedisTemplate.delete(key);
    }

    // 4. 데이터 카운트 증가 (없으면 0부터 시작해서 1 증가)
    public long increment(String key) {
        ValueOperations<String, String> valueOperations = stringRedisTemplate.opsForValue();
        return valueOperations.increment(key);
    }

    // 5. 유효시간 설정 (이미 존재하는 키에 시간만 다시 세팅할 때 사용)
    public void setExpire(String key, long durationSeconds) {
        stringRedisTemplate.expire(key, Duration.ofSeconds(durationSeconds));
    }
}