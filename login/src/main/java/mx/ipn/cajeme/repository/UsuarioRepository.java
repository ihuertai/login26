package mx.ipn.cajeme.repository;

import mx.ipn.cajeme.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    Optional<Usuario> findByIdAndEliminadoFalse(Long id);

    Optional<Usuario> findByUsernameAndEliminadoFalse(String username);

    Optional<Usuario> findByUsernameIgnoreCase(String username);

    Optional<Usuario> findByEmailAndEliminadoFalse(String email);

    Optional<Usuario> findByEmailIgnoreCase(String email);

    List<Usuario> findAllByEliminadoFalseOrderByUsernameAsc();
}
