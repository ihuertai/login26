package mx.ipn.cajeme.controller;

import mx.ipn.cajeme.model.Usuario;
import mx.ipn.cajeme.service.UsuarioService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/usuarios")
public class UsuarioController {

    private final UsuarioService usuarioService;

    public UsuarioController(UsuarioService usuarioService){
        this.usuarioService = usuarioService;
    }

    // Crear usuario
    @PostMapping
    public Usuario crearUsuario(@RequestBody Usuario usuario){
        return usuarioService.crearUsuario(usuario);
    }

    // 🔐 Recuperar contraseña
    @PostMapping("/recuperar-password")
    public String recuperarPassword(@RequestParam String username){

        usuarioService.recuperarPassword(username);

        return "Se envió una contraseña temporal a tu correo";
    }

}