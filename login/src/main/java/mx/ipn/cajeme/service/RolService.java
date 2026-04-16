package mx.ipn.cajeme.service;

import mx.ipn.cajeme.dto.RolRequest;
import mx.ipn.cajeme.dto.RolResponse;
import mx.ipn.cajeme.model.Rol;
import mx.ipn.cajeme.repository.RolRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class RolService {

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
        validarNombreUnico(request.nombre(), null);
        Rol rol = new Rol(request.nombre().trim(), request.descripcion().trim());
        return toResponse(rolRepository.save(rol));
    }

    @Transactional
    public RolResponse actualizarRol(Long id, RolRequest request) {
        Rol rol = findRol(id);
        validarNombreUnico(request.nombre(), id);
        rol.setNombre(request.nombre().trim());
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

    private void validarNombreUnico(String nombre, Long currentId) {
        rolRepository.findByNombreIgnoreCaseAndEliminadoFalse(nombre.trim())
                .ifPresent(existing -> {
                    if (!existing.getId().equals(currentId)) {
                        throw new IllegalArgumentException("Ya existe un rol con ese nombre");
                    }
                });
    }
}
