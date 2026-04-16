package mx.ipn.cajeme.dto;

import jakarta.validation.constraints.NotBlank;

public record PasswordRecoveryRequest(
        @NotBlank(message = "El usuario es obligatorio")
        String username
) {
}
