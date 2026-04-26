package mx.ipn.cajeme.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import mx.ipn.cajeme.model.Usuario;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Base64;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class JwtService {

    private final ObjectMapper objectMapper;
    private final byte[] secret;
    private final long expirationSeconds;
    private final String issuer;
    private final String simaCallbackUrl;

    public JwtService(ObjectMapper objectMapper,
                      @Value("${app.jwt.secret}") String secret,
                      @Value("${app.jwt.expiration-seconds:3600}") long expirationSeconds,
                      @Value("${app.jwt.issuer:login-service}") String issuer,
                      @Value("${app.sso.sima-callback-url:http://localhost:8081/auth/callback}") String simaCallbackUrl) {
        this.objectMapper = objectMapper;
        this.secret = secret.getBytes(StandardCharsets.UTF_8);
        this.expirationSeconds = expirationSeconds;
        this.issuer = issuer;
        this.simaCallbackUrl = simaCallbackUrl;
    }

    public String generateToken(Usuario usuario) {
        Instant now = Instant.now();

        Map<String, Object> header = Map.of(
                "alg", "HS256",
                "typ", "JWT"
        );

        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("iss", issuer);
        payload.put("sub", usuario.getUsername());
        payload.put("uid", usuario.getId());
        payload.put("email", usuario.getEmail());
        payload.put("roles", usuario.getRoles().stream().map(rol -> rol.getNombre()).sorted().toList());
        payload.put("iat", now.getEpochSecond());
        payload.put("exp", now.plusSeconds(expirationSeconds).getEpochSecond());

        String encodedHeader = encodeJson(header);
        String encodedPayload = encodeJson(payload);
        String signature = sign(encodedHeader + "." + encodedPayload);
        return encodedHeader + "." + encodedPayload + "." + signature;
    }

    public String buildSimaCallbackUrl(String token) {
        return simaCallbackUrl + "?token=" + token;
    }

    public TokenPayload validateToken(String token) {
        if (token == null || token.isBlank()) {
            throw new IllegalArgumentException("Token no proporcionado");
        }

        String[] parts = token.split("\\.");
        if (parts.length != 3) {
            throw new IllegalArgumentException("Token invalido");
        }

        String signedContent = parts[0] + "." + parts[1];
        String expectedSignature = sign(signedContent);
        if (!expectedSignature.equals(parts[2])) {
            throw new IllegalArgumentException("Firma del token invalida");
        }

        Map<String, Object> payload = decodePayload(parts[1]);
        validatePayload(payload);

        Long userId = ((Number) payload.get("uid")).longValue();
        String username = String.valueOf(payload.get("sub"));
        String email = String.valueOf(payload.get("email"));
        Object rawRoles = payload.get("roles");
        List<String> roles = rawRoles instanceof List<?> list
                ? list.stream().map(String::valueOf).toList()
                : Collections.emptyList();

        return new TokenPayload(userId, username, email, roles);
    }

    private String encodeJson(Map<String, Object> value) {
        try {
            return Base64.getUrlEncoder().withoutPadding()
                    .encodeToString(objectMapper.writeValueAsBytes(value));
        } catch (JsonProcessingException ex) {
            throw new IllegalStateException("No fue posible construir el token", ex);
        }
    }

    private String sign(String content) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(secret, "HmacSHA256"));
            byte[] signature = mac.doFinal(content.getBytes(StandardCharsets.UTF_8));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(signature);
        } catch (Exception ex) {
            throw new IllegalStateException("No fue posible firmar el token", ex);
        }
    }

    private Map<String, Object> decodePayload(String encodedPayload) {
        try {
            byte[] decoded = Base64.getUrlDecoder().decode(encodedPayload);
            return objectMapper.readValue(decoded, Map.class);
        } catch (Exception ex) {
            throw new IllegalArgumentException("No fue posible leer el token", ex);
        }
    }

    private void validatePayload(Map<String, Object> payload) {
        if (!issuer.equals(String.valueOf(payload.get("iss")))) {
            throw new IllegalArgumentException("Emisor invalido");
        }

        long expiration = ((Number) payload.get("exp")).longValue();
        if (Instant.ofEpochSecond(expiration).isBefore(Instant.now())) {
            throw new IllegalArgumentException("Token expirado");
        }
    }

    public record TokenPayload(
            Long userId,
            String username,
            String email,
            List<String> roles
    ) {
    }
}
