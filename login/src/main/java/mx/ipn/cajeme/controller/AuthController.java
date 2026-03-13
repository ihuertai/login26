package mx.ipn.cajeme.controller;

import mx.ipn.cajeme.dto.LoginRequest;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
public class AuthController {

    @PostMapping("/login")
    public String login(@RequestBody LoginRequest request){

        return "Login recibido para usuario: " + request.getUsername();

    }

}