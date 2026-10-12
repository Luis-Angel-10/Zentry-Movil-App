package zentry.back.api.core.controllers;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import zentry.back.api.core.dtos.MissionResponse;
import zentry.back.api.core.models.User;
import zentry.back.api.core.repositories.UserRepository;
import zentry.back.api.core.services.MissionService;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping({"/api/core/missions", "/api/v1/missions"})
@Tag(name = "Misiones y Recompensas", description = "Endpoints para ver y reclamar recompensas de misiones")
public class MissionController {

    private final MissionService missionService;
    private final UserRepository userRepository;

    public MissionController(MissionService missionService, UserRepository userRepository) {
        this.missionService = missionService;
        this.userRepository = userRepository;
    }

    @GetMapping
    @Operation(summary = "Listar mis misiones", description = "Devuelve el catálogo de misiones con el progreso del usuario autenticado.")
    public ResponseEntity<List<MissionResponse>> getUserMissions(Principal principal, Authentication authentication) {
        User user = resolveUser(extractUsername(principal, authentication));
        return ResponseEntity.ok(missionService.getUserMissions(user.getId()));
    }

    @Operation(summary = "Reclamar recompensa de misión",
               description = "Otorga las Zentry Coins de recompensa de la misión al usuario autenticado. Cada misión solo puede reclamarse una vez.")
    @PostMapping("/{id}/claim")
    public ResponseEntity<MissionResponse> claimMission(
            @Parameter(description = "ID de la misión") @PathVariable Integer id,
            Principal principal, Authentication authentication) {
        User user = resolveUser(extractUsername(principal, authentication));
        return ResponseEntity.ok(missionService.claimMission(user.getId(), user.getUsername(), id));
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

    private User resolveUser(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Usuario no encontrado"));
    }
}
