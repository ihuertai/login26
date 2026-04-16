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

    public void enviarPasswordTemporal(String correo, String username, String passwordTemporal) {

        SimpleMailMessage mensaje = new SimpleMailMessage();

        mensaje.setTo(correo);
        mensaje.setSubject("Recuperación de contraseña");

        mensaje.setText(
                "Hola " + username + ",\n\n" +
                        "Se solicitó recuperar tu contraseña.\n\n" +
                        "Tu contraseña temporal es: " + passwordTemporal + "\n\n" +
                        "Te recomendamos cambiarla después de iniciar sesión."
        );

        mailSender.send(mensaje);
    }
    public void enviarBienvenida(String correo, String username) {
        SimpleMailMessage mensaje = new SimpleMailMessage();
        mensaje.setTo(correo);
        mensaje.setSubject("Bienvenido al sistema");
        mensaje.setText(
                "Hola,\n\n" +
                        "Tu usuario fue dado de alta correctamente.\n" +
                        "Nombre de usuario registrado: " + username + "\n\n" +
                        "Por seguridad, la contrasena no se envia por correo."
        );
        mailSender.send(mensaje);
    }
}
