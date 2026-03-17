package mx.ipn.cajeme.security;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import mx.ipn.cajeme.model.Usuario;
import mx.ipn.cajeme.repository.UsuarioRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
public class LoginSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {

    private final UsuarioRepository usuarioRepository;

    public LoginSuccessHandler(UsuarioRepository usuarioRepository){
        this.usuarioRepository = usuarioRepository;
    }

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request,
                                        HttpServletResponse response,
                                        Authentication authentication)
            throws IOException, ServletException {

        String username = authentication.getName();

        Usuario usuario = usuarioRepository
                .findByUsername(username)
                .orElseThrow();

        usuario.setIntentosFallidos(0);

        usuarioRepository.save(usuario);

        super.onAuthenticationSuccess(request, response, authentication);
    }
}
