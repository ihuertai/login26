package mx.ipn.cajeme.dto;

import java.time.LocalDateTime;

public record RolResponse(
        Long id,
        String nombre,
        String descripcion,
        LocalDateTime fechaCreacion,
        LocalDateTime fechaActualizacion,
        String creadoPor,
        String actualizadoPor
) {
}
