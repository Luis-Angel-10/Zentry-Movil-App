package zentry.back.api.core.controllers;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import zentry.back.api.core.dtos.AchievementResponse;
import zentry.back.api.core.models.User;
import zentry.back.api.core.repositories.UserRepository;
import zentry.back.api.core.services.AchievementService;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping({"/api/core/achievements", "/api/v1/achievements"})
@Tag(name = "Logros", description = "Endpoints para ver los logros disponibles y desbloqueados por el usuario")
public class AchievementController {

    private final AchievementService achievementService;
    private final UserRepository userRepository;

    public AchievementController(AchievementService achievementService, UserRepository userRepository) {
        this.achievementService = achievementService;
        this.userRepository = userRepository;
    }

    @GetMapping
    @Operation(summary = "Listar todos los logros", description = "Devuelve el catálogo completo de logros disponibles.")
    public ResponseEntity<List<AchievementResponse>> listAll() {
        return ResponseEntity.ok(achievementService.listAll());
    }

    @GetMapping("/me")
    @Operation(summary = "Mis logros", description = "Devuelve el catálogo de logros indicando cuáles ha desbloqueado el usuario autenticado.")
    public ResponseEntity<List<AchievementResponse>> listMine(Principal principal, Authentication authentication) {
        Integer userId = resolveUserId(extractUsername(principal, authentication));
        return ResponseEntity.ok(achievementService.listForUser(userId));
    }

    private String extractUsername(Principal principal, Authentication authentication) {
        if (principal != null) {
            return principal.getName();
        }
        if (authentication != null) {
            return authentication.getName();
        }
        throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Debes iniciar sesión");
    }

    private Integer resolveUserId(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Usuario no encontrado"));
        return user.getId();
    }
}
