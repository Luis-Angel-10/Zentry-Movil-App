package zentry.back.api.core.controllers;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import zentry.back.api.config.SecurityConfig;
import zentry.back.api.core.dtos.LoginRequest;
import zentry.back.api.core.dtos.RegisterRequest;
import zentry.back.api.core.dtos.VerifyLoginRequest;
import zentry.back.api.core.models.User;
import zentry.back.api.core.models.UserOTP;
import zentry.back.api.core.repositories.UserOTPRepository;
import zentry.back.api.core.repositories.UserRepository;
import zentry.back.api.core.services.EmailDeliveryException;
import zentry.back.api.core.services.EmailService;
import zentry.back.api.core.services.GamificationEventService;
import zentry.back.api.core.services.JwtService;

import java.time.LocalDateTime;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Cubre el Problema B (verified=true sin OTP: el login ya no debe marcar verificado
 * a nadie, verify-login sigue siendo el único camino válido) y el envío real de OTP
 * por correo (register/resend-otp delegan en EmailService, mockeado aquí — ningún
 * test de esta clase toca SMTP real).
 */
@Import(SecurityConfig.class)
@WebMvcTest(AuthController.class)
@AutoConfigureMockMvc(addFilters = false)
@DisplayName("AuthController")
class AuthControllerTest {

    @Autowired MockMvc mvc;
    @Autowired ObjectMapper json;

    @MockitoBean AuthenticationManager authenticationManager;
    @MockitoBean AuthenticationProvider authenticationProvider;
    @MockitoBean UserDetailsService userDetailsService;
    @MockitoBean JwtService jwtService;
    @MockitoBean PasswordEncoder passwordEncoder;
    @MockitoBean UserRepository userRepository;
    @MockitoBean UserOTPRepository userOTPRepository;
    @MockitoBean GamificationEventService gamificationEventService;
    @MockitoBean EmailService emailService;

    private static final String EMAIL = "user@zentry.com";
    private static final String PASSWORD = "Password123!";

    private User user(Integer id, boolean verified) {
        return User.builder().id(id).username("tester").email(EMAIL).password("hash").verified(verified).build();
    }

    @Nested
    @DisplayName("POST /api/auth/login")
    class LoginTests {

        @Test
        @DisplayName("verified=false + password correcto -> 403, sin JWT, sin marcar verificado")
        void login_unverifiedUser_rejected() throws Exception {
            when(userRepository.findByEmail(EMAIL)).thenReturn(Optional.of(user(1, false)));

            LoginRequest req = LoginRequest.builder().email(EMAIL).password(PASSWORD).build();

            mvc.perform(post("/api/auth/login").contentType(MediaType.APPLICATION_JSON)
                            .content(json.writeValueAsString(req)))
                    .andExpect(status().isForbidden())
                    .andExpect(jsonPath("$.message").value("Debes verificar tu correo antes de iniciar sesión."))
                    .andExpect(jsonPath("$.requiresVerification").value(true))
                    .andExpect(jsonPath("$.token").doesNotExist());

            verify(jwtService, never()).generateToken(any());
            verify(userRepository, never()).save(any(User.class));
        }

        @Test
        @DisplayName("verified=true + password correcto -> 200, con JWT")
        void login_verifiedUser_succeeds() throws Exception {
            User verifiedUser = user(2, true);
            when(userRepository.findByEmail(EMAIL)).thenReturn(Optional.of(verifiedUser));
            when(userDetailsService.loadUserByUsername(EMAIL)).thenReturn(verifiedUser);
            when(jwtService.generateToken(verifiedUser)).thenReturn("fake-jwt-token");

            LoginRequest req = LoginRequest.builder().email(EMAIL).password(PASSWORD).build();

            mvc.perform(post("/api/auth/login").contentType(MediaType.APPLICATION_JSON)
                            .content(json.writeValueAsString(req)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.token").value("fake-jwt-token"))
                    .andExpect(jsonPath("$.message").value("Login exitoso"));

            verify(jwtService).generateToken(verifiedUser);
            // El login nunca escribe en la base: la verificación solo ocurre en verify-login.
            verify(userRepository, never()).save(any(User.class));
        }
    }

    @Nested
    @DisplayName("POST /api/auth/verify-login")
    class VerifyLoginTests {

        @Test
        @DisplayName("OTP correcto -> verified pasa de false a true y devuelve JWT")
        void verifyLogin_correctCode_marksVerifiedAndReturnsJwt() throws Exception {
            User unverified = user(3, false);
            UserOTP otp = UserOTP.builder().id(1L).userId(3).code("123456")
                    .expirationTime(LocalDateTime.now().plusMinutes(5)).attempts(0).build();

            when(userRepository.findByEmail(EMAIL)).thenReturn(Optional.of(unverified));
            when(userOTPRepository.findByUserId(3)).thenReturn(Optional.of(otp));
            when(userDetailsService.loadUserByUsername(EMAIL)).thenReturn(unverified);
            when(jwtService.generateToken(unverified)).thenReturn("verified-jwt-token");

            VerifyLoginRequest req = new VerifyLoginRequest();
            req.setEmail(EMAIL);
            req.setCode("123456");

            mvc.perform(post("/api/auth/verify-login").contentType(MediaType.APPLICATION_JSON)
                            .content(json.writeValueAsString(req)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.token").value("verified-jwt-token"))
                    .andExpect(jsonPath("$.message").value("Cuenta verificada"));

            verify(userOTPRepository).deleteByUserId(3);
            verify(userRepository).save(argThat(u -> Boolean.TRUE.equals(u.getVerified())));
        }

        @Test
        @DisplayName("OTP incorrecto -> sigue false, 400, no se marca verificado")
        void verifyLogin_wrongCode_staysUnverified() throws Exception {
            User unverified = user(4, false);
            UserOTP otp = UserOTP.builder().id(2L).userId(4).code("111111")
                    .expirationTime(LocalDateTime.now().plusMinutes(5)).attempts(0).build();

            when(userRepository.findByEmail(EMAIL)).thenReturn(Optional.of(unverified));
            when(userOTPRepository.findByUserId(4)).thenReturn(Optional.of(otp));

            VerifyLoginRequest req = new VerifyLoginRequest();
            req.setEmail(EMAIL);
            req.setCode("999999");

            mvc.perform(post("/api/auth/verify-login").contentType(MediaType.APPLICATION_JSON)
                            .content(json.writeValueAsString(req)))
                    .andExpect(status().isBadRequest());

            verify(userRepository, never()).save(any(User.class));
            verify(jwtService, never()).generateToken(any());
        }

        @Test
        @DisplayName("OTP expirado -> sigue false, 410, no se marca verificado")
        void verifyLogin_expiredCode_staysUnverified() throws Exception {
            User unverified = user(5, false);
            UserOTP otp = UserOTP.builder().id(3L).userId(5).code("123456")
                    .expirationTime(LocalDateTime.now().minusMinutes(1)).attempts(0).build();

            when(userRepository.findByEmail(EMAIL)).thenReturn(Optional.of(unverified));
            when(userOTPRepository.findByUserId(5)).thenReturn(Optional.of(otp));

            VerifyLoginRequest req = new VerifyLoginRequest();
            req.setEmail(EMAIL);
            req.setCode("123456");

            mvc.perform(post("/api/auth/verify-login").contentType(MediaType.APPLICATION_JSON)
                            .content(json.writeValueAsString(req)))
                    .andExpect(status().isGone());

            verify(userOTPRepository).deleteByUserId(5);
            verify(userRepository, never()).save(any(User.class));
            verify(jwtService, never()).generateToken(any());
        }
    }

    @Nested
    @DisplayName("POST /api/auth/register")
    class RegisterTests {

        private RegisterRequest request() {
            return RegisterRequest.builder().username("nuevo").email(EMAIL).password(PASSWORD).build();
        }

        @Test
        @DisplayName("genera y guarda el OTP, y llama a EmailService.sendVerificationCode")
        void register_generatesOtpAndCallsEmailService() throws Exception {
            when(userRepository.findByEmail(EMAIL)).thenReturn(Optional.empty());
            when(passwordEncoder.encode(PASSWORD)).thenReturn("hashed");

            mvc.perform(post("/api/auth/register").contentType(MediaType.APPLICATION_JSON)
                            .content(json.writeValueAsString(request())))
                    .andExpect(status().isOk());

            verify(userOTPRepository).save(argThat(otp ->
                    otp.getCode() != null && otp.getCode().matches("\\d{6}")
                            && otp.getExpirationTime().isAfter(LocalDateTime.now().plusMinutes(9))
                            && otp.getExpirationTime().isBefore(LocalDateTime.now().plusMinutes(11))));
            verify(emailService).sendVerificationCode(eq(EMAIL), argThat(code -> code.matches("\\d{6}")));
        }

        @Test
        @DisplayName("si el envío funciona -> 200, requiresVerification=true")
        void register_emailSucceeds_returnsRequiresVerification() throws Exception {
            when(userRepository.findByEmail(EMAIL)).thenReturn(Optional.empty());
            when(passwordEncoder.encode(PASSWORD)).thenReturn("hashed");
            // emailService.sendVerificationCode(...) no lanza nada -> éxito

            mvc.perform(post("/api/auth/register").contentType(MediaType.APPLICATION_JSON)
                            .content(json.writeValueAsString(request())))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.message").value("Código de verificación enviado al correo"))
                    .andExpect(jsonPath("$.requiresVerification").value(true));
        }

        @Test
        @DisplayName("si el envío falla -> NO responde \"enviado\", 503 con mensaje controlado")
        void register_emailFails_returnsControlledError() throws Exception {
            when(userRepository.findByEmail(EMAIL)).thenReturn(Optional.empty());
            when(passwordEncoder.encode(PASSWORD)).thenReturn("hashed");
            doThrow(new EmailDeliveryException("boom", new RuntimeException("SMTP down")))
                    .when(emailService).sendVerificationCode(anyString(), anyString());

            mvc.perform(post("/api/auth/register").contentType(MediaType.APPLICATION_JSON)
                            .content(json.writeValueAsString(request())))
                    .andExpect(status().isServiceUnavailable())
                    .andExpect(jsonPath("$.message").value("No fue posible enviar el código de verificación. Inténtalo nuevamente."))
                    .andExpect(jsonPath("$.message", org.hamcrest.Matchers.not(
                            org.hamcrest.Matchers.containsString("Código de verificación enviado al correo"))));

            // El usuario y el OTP SÍ quedan guardados (decisión documentada: no se
            // borran automáticamente); lo único que cambia es la respuesta HTTP.
            verify(userRepository).save(any(User.class));
            verify(userOTPRepository).save(any(UserOTP.class));
        }
    }
}
