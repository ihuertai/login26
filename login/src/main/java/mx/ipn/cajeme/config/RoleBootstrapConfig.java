package mx.ipn.cajeme.config;

import mx.ipn.cajeme.service.RolService;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RoleBootstrapConfig {

    @Bean
    public ApplicationRunner roleBootstrapRunner(RolService rolService) {
        return args -> rolService.ensureDefaultRoles();
    }
}
