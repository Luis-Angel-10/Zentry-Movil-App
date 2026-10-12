package zentry.back.api.core.controllers;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import zentry.back.api.core.dtos.NotificationResponse;
import zentry.back.api.core.services.NotificationService;

import java.security.Principal;

@RestController
@RequestMapping({"/api/core/notifications", "/api/v1/notifications"})
@Tag(name = "Notifications", description = "Notificaciones del usuario autenticado (likes, comentarios, seguidores, solicitudes de amistad)")
public class NotificationController {

    private final NotificationService service;

    public NotificationController(NotificationService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Listar mis notificaciones", description = "Devuelve únicamente las notificaciones del usuario autenticado, nunca las de otros usuarios.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    public ResponseEntity<Page<NotificationResponse>> list(
            @PageableDefault(size = 30) Pageable pageable,
            Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(service.list(principal.getName(), pageable));
    }

    @PutMapping("/{id}/read")
    @Operation(summary = "Marcar una notificación como leída")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Marcada como leída"),
        @ApiResponse(responseCode = "404", description = "No encontrada o no pertenece al usuario", content = @Content)
    })
    public ResponseEntity<Void> markAsRead(@PathVariable Integer id, Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(401).build();
        }
        service.markAsRead(id, principal.getName());
        return ResponseEntity.ok().build();
    }

    @PutMapping("/read-all")
    @Operation(summary = "Marcar todas mis notificaciones como leídas")
    public ResponseEntity<Void> markAllAsRead(Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(401).build();
        }
        service.markAllAsRead(principal.getName());
        return ResponseEntity.ok().build();
    }

    @DeleteMapping
    @Operation(summary = "Vaciar mi bandeja de notificaciones")
    public ResponseEntity<Void> clearAll(Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(401).build();
        }
        service.clearAll(principal.getName());
        return ResponseEntity.noContent().build();
    }
}
