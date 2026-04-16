package mx.ipn.cajeme.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;

import java.util.Set;

public record UsuarioCreateRequest(
        @NotBlank(message = "El nombre de usuario es obligatorio")
        @Size(max = 80, message = "El nombre de usuario no puede exceder 80 caracteres")
        String username,
        @NotBlank(message = "La contraseña es obligatoria")
        @Size(min = 8, message = "La contraseña debe tener al menos 8 caracteres")
        String password,
        @NotBlank(message = "El correo electrónico es obligatorio")
        @Email(message = "El correo electrónico no es válido")
        String email,
        @NotBlank(message = "El número de teléfono es obligatorio")
        @Size(max = 30, message = "El número de teléfono no puede exceder 30 caracteres")
        String telefono,
        @NotEmpty(message = "Debe asignarse al menos un rol")
        Set<Long> rolIds
) {
}
