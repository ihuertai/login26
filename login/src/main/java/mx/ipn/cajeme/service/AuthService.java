package mx.ipn.cajeme.service;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import mx.ipn.cajeme.dto.LoginRequest;
import mx.ipn.cajeme.dto.LoginResponse;
import mx.ipn.cajeme.model.Usuario;
import mx.ipn.cajeme.repository.UsuarioRepository;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final UsuarioRepository usuarioRepository;
    private final LoginAttemptService loginAttemptService;
    private final UsuarioService usuarioService;
    private final JwtService jwtService;

    public AuthService(AuthenticationManager authenticationManager,
                       UsuarioRepository usuarioRepository,
                       LoginAttemptService loginAttemptService,
                       UsuarioService usuarioService,
                       JwtService jwtService) {
        this.authenticationManager = authenticationManager;
        this.usuarioRepository = usuarioRepository;
        this.loginAttemptService = loginAttemptService;
        this.usuarioService = usuarioService;
        this.jwtService = jwtService;
    }

    public LoginResponse login(LoginRequest request, HttpServletRequest httpRequest, HttpServletResponse httpResponse) {
        String clientKey = resolveClientKey(httpRequest);

        if (loginAttemptService.isBlocked(clientKey)) {
            throw new IllegalStateException("La conexion se encuentra bloqueada temporalmente. Intente nuevamente mas tarde.");
        }

        try {
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(request.username(), request.password())
            );

            SecurityContext context = SecurityContextHolder.createEmptyContext();
            context.setAuthentication(authentication);
            SecurityContextHolder.setContext(context);
            new HttpSessionSecurityContextRepository().saveContext(context, httpRequest, httpResponse);

            loginAttemptService.reset(clientKey);
            usuarioService.resetIntentos(request.username());

            Usuario usuario = usuarioRepository.findByUsernameAndEliminadoFalse(request.username())
                    .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));

            String token = jwtService.generateToken(usuario);

            return new LoginResponse(
                    usuario.getId(),
                    usuario.getUsername(),
                    usuario.getEmail(),
                    usuario.getTelefono(),
                    usuario.getRoles().stream().map(rol -> rol.getNombre()).sorted().toList(),
                    "Acceso concedido",
                    token,
                    jwtService.buildSimaCallbackUrl(token)
            );
        } catch (BadCredentialsException ex) {
            loginAttemptService.registerFailure(clientKey);
            usuarioService.registrarIntentoFallido(request.username());

            if (loginAttemptService.isBlocked(clientKey)) {
                throw new IllegalStateException("Se alcanzo el maximo de intentos. La conexion fue bloqueada temporalmente.");
            }

            throw ex;
        }
    }

    public void logout(HttpServletRequest request, HttpServletResponse response) throws Exception {
        request.logout();
        if (request.getSession(false) != null) {
            request.getSession(false).invalidate();
        }
        SecurityContextHolder.clearContext();
        response.setStatus(HttpServletResponse.SC_NO_CONTENT);
    }

    private String resolveClientKey(HttpServletRequest request) {
        String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isBlank()) {
            return forwarded.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
