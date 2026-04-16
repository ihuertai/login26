package mx.ipn.cajeme.repository;

import mx.ipn.cajeme.model.Rol;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface RolRepository extends JpaRepository<Rol, Long> {

    Optional<Rol> findByIdAndEliminadoFalse(Long id);

    Optional<Rol> findByNombreIgnoreCaseAndEliminadoFalse(String nombre);

    List<Rol> findAllByEliminadoFalseOrderByNombreAsc();
}
