package zentry.back.api.core.services;

/**
 * Señala que el envío de un correo (p. ej. el código OTP de verificación) falló.
 *
 * <p>Se lanza únicamente desde {@link EmailService}, que ya se encarga de loguear
 * el fallo sin exponer credenciales SMTP ni el contenido del mensaje. El mensaje de
 * esta excepción es siempre genérico y seguro para propagarse hasta el controlador,
 * que lo traduce en una respuesta HTTP controlada (nunca el stacktrace crudo).
 */
public class EmailDeliveryException extends RuntimeException {

    public EmailDeliveryException(String message, Throwable cause) {
        super(message, cause);
    }
}
