package mx.ipn.cajeme.controller;

import jakarta.validation.Valid;
import mx.ipn.cajeme.dto.RolRequest;
import mx.ipn.cajeme.dto.RolResponse;
import mx.ipn.cajeme.service.RolService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/roles")
public class RolController {

    private final RolService rolService;

    public RolController(RolService rolService) {
        this.rolService = rolService;
    }

    @GetMapping
    public List<RolResponse> listarRoles() {
        return rolService.listarRoles();
    }

    @GetMapping("/{id}")
    public RolResponse obtenerRol(@PathVariable Long id) {
        return rolService.obtenerRol(id);
    }

    @PostMapping
    public RolResponse crearRol(@Valid @RequestBody RolRequest request) {
        return rolService.crearRol(request);
    }

    @PutMapping("/{id}")
    public RolResponse actualizarRol(@PathVariable Long id, @Valid @RequestBody RolRequest request) {
        return rolService.actualizarRol(id, request);
    }

    @DeleteMapping("/{id}")
    public void eliminarRol(@PathVariable Long id) {
        rolService.eliminarRol(id);
    }
}
