package mx.ipn.cajeme.service;

import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class LoginAttemptService {

    private static final int MAX_FAILED_ATTEMPTS = 3;
    private static final Duration BLOCK_TIME = Duration.ofMinutes(15);

    private final Map<String, AttemptState> attempts = new ConcurrentHashMap<>();

    public void registerFailure(String clientKey) {
        AttemptState state = attempts.computeIfAbsent(clientKey, key -> new AttemptState());
        if (state.blockedUntil != null && state.blockedUntil.isAfter(Instant.now())) {
            return;
        }

        state.failures++;
        if (state.failures > MAX_FAILED_ATTEMPTS) {
            state.blockedUntil = Instant.now().plus(BLOCK_TIME);
        }
    }

    public boolean isBlocked(String clientKey) {
        AttemptState state = attempts.get(clientKey);
        if (state == null || state.blockedUntil == null) {
            return false;
        }
        if (state.blockedUntil.isBefore(Instant.now())) {
            attempts.remove(clientKey);
            return false;
        }
        return true;
    }

    public void reset(String clientKey) {
        attempts.remove(clientKey);
    }

    private static final class AttemptState {
        private int failures;
        private Instant blockedUntil;
    }
}
