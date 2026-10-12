package zentry.back.api.core.services;

import jakarta.mail.Session;
import jakarta.mail.internet.MimeMessage;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.mail.MailAuthenticationException;
import org.springframework.mail.javamail.JavaMailSender;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Prueba EmailService en aislamiento total: JavaMailSender está mockeado, así que
 * ningún test de esta clase abre una conexión SMTP real ni depende de red.
 */
@DisplayName("EmailService")
class EmailServiceTest {

    private JavaMailSender mailSender;
    private EmailService emailService;

    @BeforeEach
    void setUp() {
        mailSender = mock(JavaMailSender.class);
        emailService = new EmailService(mailSender);
        // MimeMessageHelper necesita un MimeMessage real (no se puede mockear
        // fácilmente); se construye en memoria, sin ninguna conexión de red.
        when(mailSender.createMimeMessage()).thenReturn(new MimeMessage((Session) null));
    }

    @Test
    @DisplayName("envío correcto -> delega en JavaMailSender.send(...) con el MimeMessage construido")
    void sendVerificationCode_success_delegatesToMailSender() {
        emailService.sendVerificationCode("alice@zentry.com", "123456");

        verify(mailSender).send(any(MimeMessage.class));
    }

    @Test
    @DisplayName("el asunto y destinatario del correo son los esperados")
    void sendVerificationCode_setsExpectedSubjectAndRecipient() throws Exception {
        emailService.sendVerificationCode("alice@zentry.com", "654321");

        var captor = org.mockito.ArgumentCaptor.forClass(MimeMessage.class);
        verify(mailSender).send(captor.capture());
        MimeMessage sent = captor.getValue();

        assertThat(sent.getSubject()).isEqualTo("Código de verificación de Zentry");
        assertThat(sent.getAllRecipients()[0].toString()).isEqualTo("alice@zentry.com");
    }

    @Test
    @DisplayName("si JavaMailSender falla -> lanza EmailDeliveryException (sin exponer la causa al cliente)")
    void sendVerificationCode_mailSenderThrows_wrapsInEmailDeliveryException() {
        doThrow(new MailAuthenticationException("credenciales SMTP inválidas"))
                .when(mailSender).send(any(MimeMessage.class));

        assertThatThrownBy(() -> emailService.sendVerificationCode("bob@zentry.com", "111111"))
                .isInstanceOf(EmailDeliveryException.class)
                .hasMessage("No fue posible enviar el código de verificación");
    }
}
