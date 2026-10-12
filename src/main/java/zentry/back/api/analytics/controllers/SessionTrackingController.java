package zentry.back.api.analytics.controllers;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import zentry.back.api.analytics.dtos.SessionTrackingRequest;
import zentry.back.api.analytics.dtos.SessionTrackingResponse;
import zentry.back.api.analytics.services.SessionTrackingService;

@RestController
@RequestMapping("/api/analytics/session-tracking")
@Tag(name = "Session Tracking", description = "Registro y seguimiento de sesiones de usuario en la plataforma")
public class SessionTrackingController {

    private final SessionTrackingService service;

    public SessionTrackingController(SessionTrackingService service) {
        this.service = service;
    }

    // ─── GET /api/analytics/session-tracking ────────────────────────────────────────────
    @Operation(summary = "Listar sesiones de usuario",
               description = "Devuelve una lista paginada de todas las sesiones registradas.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<SessionTrackingResponse>> list(
            @PageableDefault(size = 20, sort = "sessionStart", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    // ─── GET /api/analytics/session-tracking/{id} ───────────────────────────────────────
    @Operation(summary = "Obtener sesión por ID",
               description = "Retorna los detalles de una sesión específica de usuario mediante su ID.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Sesión encontrada"),
        @ApiResponse(responseCode = "400", description = "ID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Sesión no encontrada", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<SessionTrackingResponse> getById(
            @Parameter(description = "ID de la sesión") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    // ─── POST /api/analytics/session-tracking ───────────────────────────────────────────
    @Operation(summary = "Registrar sesión",
               description = "Crea un nuevo registro de sesión indicando su inicio y fin. La duración se calcula automáticamente en base de datos.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Sesión creada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos o faltantes", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<SessionTrackingResponse> create(@Valid @RequestBody SessionTrackingRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    // ─── PUT /api/analytics/session-tracking/{id} ───────────────────────────────────────
    @Operation(summary = "Actualizar sesión",
               description = "Modifica los tiempos de inicio y fin de una sesión existente.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Sesión actualizada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Sesión no encontrada", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<SessionTrackingResponse> update(
            @Parameter(description = "ID de la sesión a actualizar") @PathVariable Integer id,
            @Valid @RequestBody SessionTrackingRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    // ─── DELETE /api/analytics/session-tracking/{id} ────────────────────────────────────
    @Operation(summary = "Eliminar sesión",
               description = "Elimina permanentemente una sesión del historial de analíticas.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Sesión eliminada exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Sesión no encontrada", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID de la sesión a eliminar") @PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
