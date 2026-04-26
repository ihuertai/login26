package mx.ipn.cajeme.service;

import mx.ipn.cajeme.dto.RolRequest;
import mx.ipn.cajeme.dto.RolResponse;
import mx.ipn.cajeme.model.Rol;
import mx.ipn.cajeme.repository.RolRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.text.Normalizer;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@Service
public class RolService {

    public static final String ROL_GERENTE = "GERENTE";
    public static final String ROL_SUCURSAL = "SUCURSAL";

    private static final Map<String, String> ROLE_ALIASES = Map.of(
            "GERENTE", ROL_GERENTE,
            "ADMIN", ROL_GERENTE,
            "ADMINISTRADOR", ROL_GERENTE,
            "SUCURSAL", ROL_SUCURSAL,
            "JEFE_SUCURSAL", ROL_SUCURSAL,
            "JEFE DE SUCURSAL", ROL_SUCURSAL,
            "JEFE-SUCURSAL", ROL_SUCURSAL
    );

    private final RolRepository rolRepository;

    public RolService(RolRepository rolRepository) {
        this.rolRepository = rolRepository;
    }

    @Transactional(readOnly = true)
    public List<RolResponse> listarRoles() {
        return rolRepository.findAllByEliminadoFalseOrderByNombreAsc()
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public RolResponse obtenerRol(Long id) {
        return toResponse(findRol(id));
    }

    @Transactional
    public RolResponse crearRol(RolRequest request) {
        String nombreNormalizado = normalizeRoleName(request.nombre());
        validarNombreUnico(nombreNormalizado, null);
        Rol rol = new Rol(nombreNormalizado, request.descripcion().trim());
        return toResponse(rolRepository.save(rol));
    }

    @Transactional
    public RolResponse actualizarRol(Long id, RolRequest request) {
        Rol rol = findRol(id);
        String nombreNormalizado = normalizeRoleName(request.nombre());
        validarNombreUnico(nombreNormalizado, id);
        rol.setNombre(nombreNormalizado);
        rol.setDescripcion(request.descripcion().trim());
        return toResponse(rolRepository.save(rol));
    }

    @Transactional
    public void eliminarRol(Long id) {
        Rol rol = findRol(id);
        rol.marcarEliminado();
        rolRepository.save(rol);
    }

    public RolResponse toResponse(Rol rol) {
        return new RolResponse(
                rol.getId(),
                rol.getNombre(),
                rol.getDescripcion(),
                rol.getFechaCreacion(),
                rol.getFechaActualizacion(),
                rol.getCreadoPor(),
                rol.getActualizadoPor()
        );
    }

    private Rol findRol(Long id) {
        return rolRepository.findByIdAndEliminadoFalse(id)
                .orElseThrow(() -> new IllegalArgumentException("Rol no encontrado"));
    }

    @Transactional
    public Rol ensureBaseRole(String nombre, String descripcion) {
        String normalizedName = normalizeRoleName(nombre);
        Rol rol = rolRepository.findByNombreIgnoreCaseAndEliminadoFalse(normalizedName)
                .orElseGet(() -> new Rol(normalizedName, descripcion.trim()));
        rol.restaurar();
        rol.setNombre(normalizedName);
        rol.setDescripcion(descripcion.trim());
        return rolRepository.save(rol);
    }

    @Transactional
    public void ensureDefaultRoles() {
        ensureBaseRole(ROL_GERENTE, "Rol operativo responsable de crear anuncios, campañas y envíos.");
        ensureBaseRole(ROL_SUCURSAL, "Rol operativo responsable de registrar clientes y atender solicitudes.");

        migrateLegacyRole("JEFE_SUCURSAL", ROL_SUCURSAL, "Rol operativo responsable de registrar clientes y atender solicitudes.");
        migrateLegacyRole("JEFE DE SUCURSAL", ROL_SUCURSAL, "Rol operativo responsable de registrar clientes y atender solicitudes.");
    }

    private void validarNombreUnico(String nombre, Long currentId) {
        rolRepository.findByNombreIgnoreCaseAndEliminadoFalse(normalizeRoleName(nombre))
                .ifPresent(existing -> {
                    if (!existing.getId().equals(currentId)) {
                        throw new IllegalArgumentException("Ya existe un rol con ese nombre");
                    }
                });
    }

    private void migrateLegacyRole(String legacyName, String canonicalName, String descripcion) {
        Rol canonical = rolRepository.findByNombreIgnoreCaseAndEliminadoFalse(canonicalName).orElse(null);
        rolRepository.findByNombreIgnoreCaseAndEliminadoFalse(legacyName).ifPresent(legacy -> {
            if (canonical == null || canonical.getId().equals(legacy.getId())) {
                legacy.setNombre(canonicalName);
                legacy.setDescripcion(descripcion);
                legacy.restaurar();
                rolRepository.save(legacy);
            }
        });
    }

    private String normalizeRoleName(String nombre) {
        String trimmed = nombre == null ? "" : nombre.trim();
        String plain = Normalizer.normalize(trimmed, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "");
        String upper = plain.toUpperCase(Locale.ROOT)
                .replace('-', ' ')
                .replaceAll("\\s+", " ")
                .trim();
        return ROLE_ALIASES.getOrDefault(upper, upper.replace(' ', '_'));
    }
}
