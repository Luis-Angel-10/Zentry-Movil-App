package zentry.back.api.core.controllers;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zentry.back.api.core.dtos.StreakResponse;
import zentry.back.api.core.services.StreakService;

import java.security.Principal;

@RestController
@RequestMapping({"/api/core/streaks", "/api/v1/streaks"})
@Tag(name = "Streaks", description = "Gestión de rachas de días activos de los usuarios")
public class StreakController {

    private final StreakService service;

    public StreakController(StreakService service) {
        this.service = service;
    }

    @GetMapping("/me")
    @Operation(summary = "Obtener racha activa del usuario autenticado")
    public ResponseEntity<StreakResponse> getMyStreak(Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(service.getStreak(principal.getName()));
    }

    @GetMapping("/user/{identifier}")
    @Operation(summary = "Obtener racha activa de un usuario por su nombre de usuario o correo")
    public ResponseEntity<StreakResponse> getUserStreak(@PathVariable String identifier) {
        return ResponseEntity.ok(service.getStreak(identifier));
    }
}
