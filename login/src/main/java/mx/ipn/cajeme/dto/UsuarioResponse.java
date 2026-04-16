package mx.ipn.cajeme.dto;

import java.time.LocalDateTime;
import java.util.List;

public record UsuarioResponse(
        Long id,
        String username,
        String email,
        String telefono,
        Boolean activo,
        Integer intentosFallidos,
        List<RolResponse> roles,
        LocalDateTime fechaCreacion,
        LocalDateTime fechaActualizacion,
        String creadoPor,
        String actualizadoPor
) {
}
