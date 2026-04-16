package mx.ipn.cajeme.dto;

import java.util.List;

public record LoginResponse(
        Long id,
        String username,
        String email,
        String telefono,
        List<String> roles,
        String mensaje,
        String token,
        String redirectUrl
) {
}
