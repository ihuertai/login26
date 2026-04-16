package mx.ipn.cajeme.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RolRequest(
        @NotBlank(message = "El nombre del rol es obligatorio")
        @Size(max = 80, message = "El nombre del rol no puede exceder 80 caracteres")
        String nombre,
        @NotBlank(message = "La descripción es obligatoria")
        @Size(max = 255, message = "La descripción no puede exceder 255 caracteres")
        String descripcion
) {
}
