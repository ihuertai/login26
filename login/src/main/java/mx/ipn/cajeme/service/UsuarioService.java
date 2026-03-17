package mx.ipn.cajeme.service;

import mx.ipn.cajeme.model.Usuario;
import mx.ipn.cajeme.repository.UsuarioRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;

    public UsuarioService(UsuarioRepository usuarioRepository,
                          PasswordEncoder passwordEncoder,
                          EmailService emailService) {

        this.usuarioRepository = usuarioRepository;
        this.passwordEncoder = passwordEncoder;
        this.emailService = emailService;
    }


    public Usuario crearUsuario(Usuario usuario){

        if(usuarioRepository.findByUsername(usuario.getUsername()).isPresent()){
            throw new RuntimeException("El usuario ya existe");
        }

        usuario.setPassword(passwordEncoder.encode(usuario.getPassword()));
        usuario.setIntentosFallidos(0);
        usuario.setActivo(true);

        return usuarioRepository.save(usuario);
    }


    public void registrarIntentoFallido(String username){

        usuarioRepository.findByUsername(username).ifPresent(usuario -> {

            int intentos = usuario.getIntentosFallidos() + 1;
            usuario.setIntentosFallidos(intentos);

            if(intentos >= 3){
                usuario.setActivo(false);
            }

            usuarioRepository.save(usuario);

        });

    }


    public void resetIntentos(String username){

        usuarioRepository.findByUsername(username).ifPresent(usuario -> {

            usuario.setIntentosFallidos(0);
            usuarioRepository.save(usuario);

        });

    }



    public void recuperarPassword(String username){

        Usuario usuario = usuarioRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        String passwordTemporal = UUID.randomUUID().toString().substring(0,8);

        usuario.setPassword(passwordEncoder.encode(passwordTemporal));

        usuarioRepository.save(usuario);

        emailService.enviarPasswordTemporal(usuario.getEmail(), passwordTemporal);
    }

}