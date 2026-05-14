package mx.ipn.cajeme.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import mx.ipn.cajeme.dto.GerenteOptionResponse;
import jakarta.validation.Valid;
import mx.ipn.cajeme.dto.LoginRequest;
import mx.ipn.cajeme.dto.LoginResponse;
import mx.ipn.cajeme.dto.PasswordRecoveryRequest;
import mx.ipn.cajeme.dto.UsuarioCreateRequest;
import mx.ipn.cajeme.dto.UsuarioResponse;
import mx.ipn.cajeme.service.AuthService;
import mx.ipn.cajeme.service.JwtService;
import mx.ipn.cajeme.service.UsuarioService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthService authService;
    private final UsuarioService usuarioService;
    private final JwtService jwtService;

    public AuthController(AuthService authService, UsuarioService usuarioService, JwtService jwtService) {
        this.authService = authService;
        this.usuarioService = usuarioService;
        this.jwtService = jwtService;
    }

    @PostMapping("/login")
    public LoginResponse login(@Valid @RequestBody LoginRequest request,
                               HttpServletRequest httpRequest,
                               HttpServletResponse httpResponse) {
        return authService.login(request, httpRequest, httpResponse);
    }

    @PostMapping("/logout")
    public void logout(HttpServletRequest request, HttpServletResponse response) throws Exception {
        authService.logout(request, response);
    }

    @PostMapping("/recuperar-password")
    public void recuperarPassword(@Valid @RequestBody PasswordRecoveryRequest request) {
        usuarioService.recuperarPassword(request.username());
    }

    @PostMapping("/registro")
    public UsuarioResponse registrar(@Valid @RequestBody UsuarioCreateRequest request) {
        return usuarioService.crearUsuario(request);
    }

    @GetMapping("/gerentes")
    public java.util.List<GerenteOptionResponse> listarGerentes(@RequestParam String token) {
        jwtService.validateToken(token);
        return usuarioService.listarGerentes();
    }

    @GetMapping("/admin-bridge")
    public void adminBridge(@RequestParam String token,
                            HttpServletRequest request,
                            HttpServletResponse response) throws Exception {
        authService.createSessionFromToken(token, request, response);
        response.sendRedirect("http://localhost:5173/admin-bridge?ssoToken=" + token + "&bridged=1");
    }
}
