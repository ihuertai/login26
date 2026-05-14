package mx.ipn.cajeme.service;

import mx.ipn.cajeme.dto.RolResponse;
import mx.ipn.cajeme.dto.UsuarioCreateRequest;
import mx.ipn.cajeme.dto.GerenteOptionResponse;
import mx.ipn.cajeme.dto.UsuarioResponse;
import mx.ipn.cajeme.dto.UsuarioUpdateRequest;
import mx.ipn.cajeme.model.Rol;
import mx.ipn.cajeme.model.Usuario;
import mx.ipn.cajeme.repository.RolRepository;
import mx.ipn.cajeme.repository.UsuarioRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@Service
public class UsuarioService {

    private static final String TEMP_PASSWORD_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789";
    private static final SecureRandom RANDOM = new SecureRandom();

    private final UsuarioRepository usuarioRepository;
    private final RolRepository rolRepository;
    private final RolService rolService;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;

    public UsuarioService(UsuarioRepository usuarioRepository,
                          RolRepository rolRepository,
                          RolService rolService,
                          PasswordEncoder passwordEncoder,
                          EmailService emailService) {
        this.usuarioRepository = usuarioRepository;
        this.rolRepository = rolRepository;
        this.rolService = rolService;
        this.passwordEncoder = passwordEncoder;
        this.emailService = emailService;
    }

    @Transactional(readOnly = true)
    public List<UsuarioResponse> listarUsuarios() {
        return usuarioRepository.findAllByEliminadoFalseOrderByUsernameAsc()
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<GerenteOptionResponse> listarGerentes() {
        return usuarioRepository.findAllByEliminadoFalseOrderByUsernameAsc().stream()
                .filter(usuario -> Boolean.TRUE.equals(usuario.getActivo()))
                .filter(usuario -> usuario.getRoles().stream().anyMatch(rol -> "GERENTE".equalsIgnoreCase(rol.getNombre())))
                .map(usuario -> new GerenteOptionResponse(
                        usuario.getId(),
                        usuario.getUsername(),
                        usuario.getEmail(),
                        usuario.getTelefono()
                ))
                .toList();
    }

    @Transactional(readOnly = true)
    public UsuarioResponse obtenerUsuario(Long id) {
        return toResponse(findUsuario(id));
    }

    @Transactional
    public UsuarioResponse crearUsuario(UsuarioCreateRequest request) {
        String username = request.username().trim();
        String email = request.email().trim().toLowerCase();

        Usuario reusable = findReusableUser(username, email);
        if (reusable != null) {
            return reactivarUsuario(reusable, request, email);
        }

        validarDuplicados(username, email, null);

        Usuario usuario = new Usuario();
        usuario.setUsername(username);
        usuario.setPassword(passwordEncoder.encode(request.password()));
        usuario.setEmail(email);
        usuario.setTelefono(request.telefono().trim());
        usuario.setActivo(true);
        usuario.setIntentosFallidos(0);
        usuario.setRoles(resolveRoles(request.rolIds()));

        Usuario saved = usuarioRepository.save(usuario);
        emailService.enviarBienvenida(saved.getEmail(), saved.getUsername());
        return toResponse(saved);
    }

    @Transactional
    public UsuarioResponse actualizarUsuario(Long id, UsuarioUpdateRequest request) {
        Usuario usuario = findUsuario(id);
        usuario.setTelefono(request.telefono().trim());
        usuario.setRoles(resolveRoles(request.rolIds()));

        if (request.password() != null && !request.password().isBlank()) {
            usuario.setPassword(passwordEncoder.encode(request.password()));
        }

        return toResponse(usuarioRepository.save(usuario));
    }

    @Transactional
    public void eliminarUsuario(Long id) {
        Usuario usuario = findUsuario(id);
        validarNoAutoEliminacion(usuario);
        usuario.setActivo(false);
        usuario.marcarEliminado();
        usuarioRepository.save(usuario);
    }

    @Transactional
    public void registrarIntentoFallido(String username) {
        usuarioRepository.findByUsernameAndEliminadoFalse(username).ifPresent(usuario -> {
            usuario.setIntentosFallidos(usuario.getIntentosFallidos() + 1);
            usuarioRepository.save(usuario);
        });
    }

    @Transactional
    public void resetIntentos(String username) {
        usuarioRepository.findByUsernameAndEliminadoFalse(username).ifPresent(usuario -> {
            usuario.setIntentosFallidos(0);
            usuarioRepository.save(usuario);
        });
    }

    @Transactional
    public void recuperarPassword(String username) {
        Usuario usuario = usuarioRepository.findByUsernameAndEliminadoFalse(username)
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));

        String passwordTemporal = generarPasswordTemporal();
        usuario.setPassword(passwordEncoder.encode(passwordTemporal));
        usuario.setIntentosFallidos(0);
        usuarioRepository.save(usuario);

        emailService.enviarPasswordTemporal(usuario.getEmail(), usuario.getUsername(), passwordTemporal);
    }

    private Usuario findUsuario(Long id) {
        return usuarioRepository.findByIdAndEliminadoFalse(id)
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));
    }

    private void validarDuplicados(String username, String email, Long currentId) {
        usuarioRepository.findByUsernameAndEliminadoFalse(username.trim())
                .ifPresent(existing -> {
                    if (!existing.getId().equals(currentId)) {
                        throw new IllegalArgumentException("El nombre de usuario ya esta registrado");
                    }
                });

        usuarioRepository.findByEmailAndEliminadoFalse(email.trim().toLowerCase())
                .ifPresent(existing -> {
                    if (!existing.getId().equals(currentId)) {
                        throw new IllegalArgumentException("El correo electronico ya esta registrado");
                    }
                });
    }

    private Usuario findReusableUser(String username, String email) {
        Usuario byUsername = usuarioRepository.findByUsernameIgnoreCase(username).orElse(null);
        Usuario byEmail = usuarioRepository.findByEmailIgnoreCase(email).orElse(null);

        if (byUsername != null && !canReuse(byUsername)) {
            throw new IllegalArgumentException("El nombre de usuario ya esta registrado");
        }

        if (byEmail != null && !canReuse(byEmail)) {
            throw new IllegalArgumentException("El correo electronico ya esta registrado");
        }

        if (byUsername != null && byEmail != null && !byUsername.getId().equals(byEmail.getId())) {
            throw new IllegalArgumentException("El nombre de usuario y el correo electronico pertenecen a usuarios distintos");
        }

        return byUsername != null ? byUsername : byEmail;
    }

    private boolean canReuse(Usuario usuario) {
        return Boolean.TRUE.equals(usuario.getEliminado()) || !Boolean.TRUE.equals(usuario.getActivo());
    }

    private UsuarioResponse reactivarUsuario(Usuario usuario, UsuarioCreateRequest request, String email) {
        usuario.restaurar();
        usuario.setActivo(true);
        usuario.setUsername(request.username().trim());
        usuario.setPassword(passwordEncoder.encode(request.password()));
        usuario.setEmail(email);
        usuario.setTelefono(request.telefono().trim());
        usuario.setIntentosFallidos(0);
        usuario.setRoles(resolveRoles(request.rolIds()));

        Usuario saved = usuarioRepository.save(usuario);
        emailService.enviarBienvenida(saved.getEmail(), saved.getUsername());
        return toResponse(saved);
    }

    private Set<Rol> resolveRoles(Set<Long> rolIds) {
        Set<Rol> roles = new LinkedHashSet<>();
        for (Long rolId : rolIds) {
            Rol rol = rolRepository.findByIdAndEliminadoFalse(rolId)
                    .orElseThrow(() -> new IllegalArgumentException("Rol no encontrado: " + rolId));
            roles.add(rol);
        }
        return roles;
    }

    private String generarPasswordTemporal() {
        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < 10; i++) {
            builder.append(TEMP_PASSWORD_CHARS.charAt(RANDOM.nextInt(TEMP_PASSWORD_CHARS.length())));
        }
        return builder.toString();
    }

    private void validarNoAutoEliminacion(Usuario usuario) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || authentication.getName() == null) {
            return;
        }

        if (authentication.getName().equalsIgnoreCase(usuario.getUsername())) {
            throw new IllegalStateException("No puedes eliminar tu propio usuario");
        }
    }

    private UsuarioResponse toResponse(Usuario usuario) {
        List<RolResponse> roles = usuario.getRoles().stream()
                .map(rolService::toResponse)
                .toList();

        return new UsuarioResponse(
                usuario.getId(),
                usuario.getUsername(),
                usuario.getEmail(),
                usuario.getTelefono(),
                usuario.getActivo(),
                usuario.getIntentosFallidos(),
                roles,
                usuario.getFechaCreacion(),
                usuario.getFechaActualizacion(),
                usuario.getCreadoPor(),
                usuario.getActualizadoPor()
        );
    }
}
