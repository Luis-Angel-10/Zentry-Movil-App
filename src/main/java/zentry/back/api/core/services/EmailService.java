package zentry.back.api.core.services;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.MailException;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

/**
 * Envío real de correos transaccionales de Zentry por SMTP (vía {@link JavaMailSender}).
 *
 * <p>Toda la lógica de email queda encapsulada aquí: el resto de la aplicación
 * (p. ej. {@code AuthController}) solo conoce {@link #sendVerificationCode}, nunca
 * construye mensajes ni toca {@code JavaMailSender} directamente.
 *
 * <p>Este servicio NUNCA registra el código OTP, la contraseña SMTP ni ningún otro
 * secreto en logs — solo el correo destinatario (necesario para diagnosticar fallos
 * de entrega) y la causa del error, cuando lo hay.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {

    private final JavaMailSender mailSender;

    private static final String SUBJECT = "Código de verificación de Zentry";

    /**
     * Envía el código OTP de verificación al correo indicado.
     *
     * @throws EmailDeliveryException si el envío falla (SMTP inalcanzable, credenciales
     *         inválidas, etc.). Nunca devuelve silenciosamente un "éxito" falso: quien
     *         llama (AuthController) es responsable de decidir la respuesta HTTP.
     */
    public void sendVerificationCode(String recipientEmail, String code) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            // multipart=true es obligatorio para poder usar setText(texto, html) más abajo
            // (la variante de dos argumentos construye un cuerpo multipart/alternative).
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setTo(recipientEmail);
            helper.setSubject(SUBJECT);
            // multipart/alternative: los clientes de correo sin soporte HTML muestran
            // automáticamente la versión en texto plano.
            helper.setText(buildPlainTextBody(code), buildHtmlBody(code));

            mailSender.send(message);
        } catch (MessagingException | MailException e) {
            log.error("No se pudo enviar el correo de verificación a {} ({}: {})",
                    recipientEmail, e.getClass().getSimpleName(), e.getMessage());
            throw new EmailDeliveryException("No fue posible enviar el código de verificación", e);
        }
    }

    private String buildPlainTextBody(String code) {
        return "Hola,\n\n"
                + "Tu código de verificación de Zentry es:\n\n"
                + code + "\n\n"
                + "Este código expirará en 10 minutos.\n\n"
                + "Si no solicitaste este registro, puedes ignorar este mensaje.\n\n"
                + "Zentry Community";
    }

    private String buildHtmlBody(String code) {
        return "<!DOCTYPE html>"
                + "<html><body style=\"font-family:Arial,Helvetica,sans-serif;background-color:#f4f4f5;padding:24px;margin:0;\">"
                + "<div style=\"max-width:480px;margin:0 auto;background-color:#ffffff;border-radius:8px;padding:32px;\">"
                + "<h2 style=\"color:#111827;margin-top:0;\">Hola,</h2>"
                + "<p style=\"color:#374151;font-size:15px;\">Tu código de verificación de Zentry es:</p>"
                + "<p style=\"font-size:36px;font-weight:bold;letter-spacing:6px;color:#4f46e5;text-align:center;margin:24px 0;\">"
                + code
                + "</p>"
                + "<p style=\"color:#374151;font-size:14px;\">Este código expirará en <strong>10 minutos</strong>.</p>"
                + "<p style=\"color:#6b7280;font-size:13px;\">Si no solicitaste este registro, puedes ignorar este mensaje.</p>"
                + "<p style=\"color:#9ca3af;font-size:12px;margin-top:32px;\">Zentry Community</p>"
                + "</div></body></html>";
    }
}
