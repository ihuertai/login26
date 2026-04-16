package mx.ipn.cajeme.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;

import java.util.Set;

public record UsuarioUpdateRequest(
        @Size(min = 8, message = "La contraseña debe tener al menos 8 caracteres")
        String password,
        @NotBlank(message = "El número de teléfono es obligatorio")
        @Size(max = 30, message = "El número de teléfono no puede exceder 30 caracteres")
        String telefono,
        @NotEmpty(message = "Debe asignarse al menos un rol")
        Set<Long> rolIds
) {
}
