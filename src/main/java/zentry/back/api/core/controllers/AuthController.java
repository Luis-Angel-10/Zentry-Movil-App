package zentry.back.api.core.controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;

import zentry.back.api.core.dtos.LoginRequest;
import zentry.back.api.core.dtos.RegisterRequest;
import zentry.back.api.core.dtos.UserResponse;
import zentry.back.api.core.services.EmailService;
import zentry.back.api.core.services.JwtService;
import zentry.back.api.core.models.User;
import zentry.back.api.core.models.UserOTP;
import zentry.back.api.core.repositories.UserRepository;
import zentry.back.api.core.repositories.UserOTPRepository;
import zentry.back.api.core.dtos.VerifyLoginRequest;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.Random;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final UserDetailsService userDetailsService;
    private final JwtService jwtService;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final UserOTPRepository userOTPRepository;
    private final zentry.back.api.core.services.GamificationEventService gamificationEventService;
    private final EmailService emailService;

    private static final int OTP_MAX_ATTEMPTS = 5;

    @PostMapping("/login")
    @Transactional
    public ResponseEntity<UserResponse> login(@Valid @RequestBody LoginRequest request) {

        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
            );
        } catch (org.springframework.security.authentication.BadCredentialsException e) {
            return ResponseEntity.status(401).body(UserResponse.builder().message("Credenciales incorrectas").build());
        }

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado en la base de datos"));

        // La ÚNICA forma válida de pasar de verified=false a verified=true es completar
        // el flujo de OTP en verifyLogin(). El login nunca marca al usuario como verificado
        // ni emite JWT si todavía no completó ese paso.
        if (!Boolean.TRUE.equals(user.getVerified())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(UserResponse.builder()
                            .message("Debes verificar tu correo antes de iniciar sesión.")
                            .requiresVerification(true)
                            .build());
        }

        UserDetails userDetails = userDetailsService.loadUserByUsername(request.getEmail());
        String jwtToken = jwtService.generateToken(userDetails);

        gamificationEventService.recordMissionProgress(user.getId(), "daily_login", 1);

        UserResponse response = UserResponse.builder()
                .message("Login exitoso")
                .token(jwtToken)
                .id(user.getId())
                .username(user.getHandle())
                .email(user.getEmail())
                .requiresVerification(false)
                .build();

        return ResponseEntity.ok(response);
    }

    @PutMapping("/change-password")
    @Transactional
    public ResponseEntity<?> changePassword(@Valid @RequestBody zentry.back.api.core.dtos.ChangePasswordRequest request,
                                             java.security.Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(401).build();
        }
        User user = userRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado"));

        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La contraseña actual no es correcta");
        }

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);

        return ResponseEntity.ok(java.util.Map.of("message", "Contraseña actualizada correctamente"));
    }

    @PostMapping("/verify-login")
    @Transactional
    public ResponseEntity<UserResponse> verifyLogin(@Valid @RequestBody VerifyLoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado"));

        UserOTP otp = userOTPRepository.findByUserId(user.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No hay un código de verificación pendiente, solicita uno nuevo"));

        if (otp.getExpirationTime().isBefore(LocalDateTime.now())) {
            userOTPRepository.deleteByUserId(user.getId());
            throw new ResponseStatusException(HttpStatus.GONE, "El código ha expirado, solicita uno nuevo");
        }

        if (!otp.getCode().equals(request.getCode())) {
            int attempts = otp.getAttempts() + 1;
            if (attempts >= OTP_MAX_ATTEMPTS) {
                userOTPRepository.deleteByUserId(user.getId());
                throw new ResponseStatusException(HttpStatus.TOO_MANY_REQUESTS, "Demasiados intentos fallidos, solicita un nuevo código");
            }
            otp.setAttempts(attempts);
            userOTPRepository.save(otp);
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Código incorrecto, intentos restantes: " + (OTP_MAX_ATTEMPTS - attempts));
        }

        userOTPRepository.deleteByUserId(user.getId());

        user.setVerified(true);
        userRepository.save(user);

        UserDetails userDetails = userDetailsService.loadUserByUsername(user.getEmail());
        String jwtToken = jwtService.generateToken(userDetails);

        UserResponse response = UserResponse.builder()
                .message("Cuenta verificada")
                .token(jwtToken)
                .id(user.getId())
                .username(user.getHandle())
                .email(user.getEmail())
                .requiresVerification(false)
                .build();

        return ResponseEntity.ok(response);
    }

    @PostMapping("/register")
    @Transactional
    public ResponseEntity<UserResponse> register(@Valid @RequestBody RegisterRequest request) {

        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "El correo ya está registrado");
        }

        User user = User.builder()
                .username(request.getUsername())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .verified(false)
                .build();

        userRepository.save(user);

        // Si el envío de correo falla, NO se borra el usuario ni el OTP ya guardados:
        // borrar aquí introduciría el riesgo de dejar filas a medias si ese borrado
        // también fallara, y el flujo de registro ya es idempotente por diseño
        // (generateAndSendOtp borra el OTP anterior antes de crear uno nuevo). El
        // usuario puede reintentar el envío con POST /api/auth/resend-otp una vez
        // resuelto el problema de correo, sin perder su cuenta ni tener que
        // registrarse de nuevo.
        try {
            generateAndSendOtp(user);
        } catch (zentry.back.api.core.services.EmailDeliveryException e) {
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body(UserResponse.builder()
                            .message("No fue posible enviar el código de verificación. Inténtalo nuevamente.")
                            .requiresVerification(true)
                            .build());
        }

        UserResponse response = UserResponse.builder()
                .message("Código de verificación enviado al correo")
                .requiresVerification(true)
                .build();

        return ResponseEntity.ok(response);
    }

    @PostMapping("/resend-otp")
    @Transactional
    public ResponseEntity<UserResponse> resendOTP(@Valid @RequestBody zentry.back.api.core.dtos.ResendOtpRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado en la base de datos"));

        try {
            generateAndSendOtp(user);
        } catch (zentry.back.api.core.services.EmailDeliveryException e) {
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body(UserResponse.builder()
                            .message("No fue posible enviar el código de verificación. Inténtalo nuevamente.")
                            .requiresVerification(true)
                            .build());
        }

        UserResponse response = UserResponse.builder()
                .message("Nuevo código de verificación enviado al correo")
                .requiresVerification(true)
                .build();

        return ResponseEntity.ok(response);
    }

    @PostMapping("/forgot-password")
    @Transactional
    public ResponseEntity<UserResponse> forgotPassword(@Valid @RequestBody zentry.back.api.core.dtos.ForgotPasswordRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No existe una cuenta registrada con este correo electrónico"));

        try {
            generateAndSendOtp(user);
        } catch (zentry.back.api.core.services.EmailDeliveryException e) {
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body(UserResponse.builder()
                            .message("No fue posible enviar el código de recuperación. Inténtalo nuevamente.")
                            .requiresVerification(true)
                            .build());
        }

        UserResponse response = UserResponse.builder()
                .message("Código de recuperación enviado al correo")
                .requiresVerification(true)
                .build();

        return ResponseEntity.ok(response);
    }

    @PostMapping("/reset-password")
    @Transactional
    public ResponseEntity<UserResponse> resetPassword(@Valid @RequestBody zentry.back.api.core.dtos.ResetPasswordRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado"));

        UserOTP otp = userOTPRepository.findByUserId(user.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No hay un código de recuperación pendiente, solicita uno nuevo"));

        if (otp.getExpirationTime().isBefore(LocalDateTime.now())) {
            userOTPRepository.deleteByUserId(user.getId());
            throw new ResponseStatusException(HttpStatus.GONE, "El código ha expirado, solicita uno nuevo");
        }

        if (!otp.getCode().equals(request.getCode())) {
            int attempts = otp.getAttempts() + 1;
            if (attempts >= OTP_MAX_ATTEMPTS) {
                userOTPRepository.deleteByUserId(user.getId());
                throw new ResponseStatusException(HttpStatus.TOO_MANY_REQUESTS, "Demasiados intentos fallidos, solicita un nuevo código");
            }
            otp.setAttempts(attempts);
            userOTPRepository.save(otp);
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Código incorrecto, intentos restantes: " + (OTP_MAX_ATTEMPTS - attempts));
        }

        userOTPRepository.deleteByUserId(user.getId());
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);

        UserResponse response = UserResponse.builder()
                .message("Contraseña restablecida correctamente. Ahora puedes iniciar sesión")
                .requiresVerification(false)
                .build();

        return ResponseEntity.ok(response);
    }

    /**
     * Genera un código de 6 dígitos, lo guarda en {@link UserOTP} con expiración a
     * 10 minutos (reemplazando cualquier código anterior del usuario) y lo envía por
     * correo real vía {@link zentry.back.api.core.services.EmailService}.
     *
     * <p>No captura errores de envío: los propaga como
     * {@link zentry.back.api.core.services.EmailDeliveryException} para que cada
     * endpoint que la llama (register, resend-otp, forgot-password) decida la
     * respuesta HTTP.
     */
    private void generateAndSendOtp(User user) {
        String code = String.format("%06d", new Random().nextInt(1000000));

        userOTPRepository.deleteByUserId(user.getId());
        UserOTP otp = UserOTP.builder()
                .userId(user.getId())
                .code(code)
                .expirationTime(LocalDateTime.now().plusMinutes(10))
                .build();
        userOTPRepository.save(otp);

        emailService.sendVerificationCode(user.getEmail(), code);
    }
}