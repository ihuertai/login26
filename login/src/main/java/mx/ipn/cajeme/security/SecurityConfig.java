package mx.ipn.cajeme.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.*;

import java.util.List;

@Configuration
public class SecurityConfig {

    private final LoginFailureHandler loginFailureHandler;

    public SecurityConfig(LoginFailureHandler loginFailureHandler) {
        this.loginFailureHandler = loginFailureHandler;
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {

        http
                .cors(Customizer.withDefaults())
                .csrf(csrf -> csrf.disable())

                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/login").permitAll()
                        .requestMatchers("/usuarios/**").permitAll()
                        .anyRequest().authenticated()
                )

                .formLogin(form -> form
                        .loginProcessingUrl("/login")
                        .successHandler((request, response, authentication) -> {
                            response.setStatus(200);
                        })
                        .failureHandler(loginFailureHandler)
                        .permitAll()
                );
        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource(){

        CorsConfiguration config = new CorsConfiguration();

        config.setAllowedOrigins(List.of("http://localhost:5173"));
        config.setAllowedMethods(List.of("GET","POST","PUT","DELETE","OPTIONS"));
        config.setAllowedHeaders(List.of("*"));
        config.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source =
                new UrlBasedCorsConfigurationSource();

        source.registerCorsConfiguration("/**", config);

        return source;
    }
}