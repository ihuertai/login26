package mx.ipn.cajeme.security;

import mx.ipn.cajeme.model.Usuario;
import mx.ipn.cajeme.repository.UsuarioRepository;
import org.springframework.security.core.userdetails.*;
import org.springframework.stereotype.Service;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    private final UsuarioRepository usuarioRepository;

    public CustomUserDetailsService(UsuarioRepository usuarioRepository){
        this.usuarioRepository = usuarioRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {

        Usuario usuario = usuarioRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado"));

        if(!usuario.getActivo()){
            throw new RuntimeException("Usuario bloqueado");
        }

        return User
                .withUsername(usuario.getUsername())
                .password(usuario.getPassword())
                .roles(
                        usuario.getRoles()
                                .stream()
                                .map(rol -> rol.getNombre())
                                .toArray(String[]::new)
                )
                .build();
    }
}