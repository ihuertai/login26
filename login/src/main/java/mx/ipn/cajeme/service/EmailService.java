package mx.ipn.cajeme.service;

import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    private final JavaMailSender mailSender;

    public EmailService(JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }

    public void enviarPasswordTemporal(String correo, String passwordTemporal) {

        SimpleMailMessage mensaje = new SimpleMailMessage();

        mensaje.setTo(correo);
        mensaje.setSubject("Recuperación de contraseña");

        mensaje.setText(
                "Hola,\n\n" +
                        "Se solicitó recuperar tu contraseña.\n\n" +
                        "Tu contraseña temporal es: " + passwordTemporal + "\n\n" +
                        "Te recomendamos cambiarla después de iniciar sesión."
        );

        mailSender.send(mensaje);
    }
}