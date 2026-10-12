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

import zentry.back.api.analytics.dtos.RecommendationLogRequest;
import zentry.back.api.analytics.dtos.RecommendationLogResponse;
import zentry.back.api.analytics.services.RecommendationLogService;

@RestController
@RequestMapping("/api/analytics/recommendation-logs")
@Tag(name = "Recommendation Logs", description = "Registro y log de recomendaciones generadas por la IA hacia los usuarios")
public class RecommendationLogController {

    private final RecommendationLogService service;

    public RecommendationLogController(RecommendationLogService service) {
        this.service = service;
    }

    // ─── GET /api/analytics/recommendation-logs ────────────────────────────────────────────
    @Operation(summary = "Listar recomendaciones generadas",
               description = "Obtiene una lista paginada del historial de recomendaciones servidas a los usuarios.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<RecommendationLogResponse>> list(
            @PageableDefault(size = 20, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    // ─── GET /api/analytics/recommendation-logs/{id} ───────────────────────────────────────
    @Operation(summary = "Obtener log de recomendación por ID",
               description = "Devuelve el detalle del conjunto de recomendaciones enviadas a un usuario en una petición.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro encontrado"),
        @ApiResponse(responseCode = "400", description = "ID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<RecommendationLogResponse> getById(
            @Parameter(description = "ID de la recomendación") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    // ─── POST /api/analytics/recommendation-logs ───────────────────────────────────────────
    @Operation(summary = "Registrar nueva recomendación",
               description = "Persiste un bloque de recomendaciones (JSON/Array de contenidos) generado para un usuario.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Registro creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos o faltantes", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<RecommendationLogResponse> create(@Valid @RequestBody RecommendationLogRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    // ─── PUT /api/analytics/recommendation-logs/{id} ───────────────────────────────────────
    @Operation(summary = "Actualizar recomendación generada",
               description = "Actualiza los datos persistidos en el log de recomendación.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<RecommendationLogResponse> update(
            @Parameter(description = "ID del registro a actualizar") @PathVariable Integer id,
            @Valid @RequestBody RecommendationLogRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    // ─── DELETE /api/analytics/recommendation-logs/{id} ────────────────────────────────────
    @Operation(summary = "Eliminar recomendación del log",
               description = "Elimina un evento de recomendación del sistema.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Registro eliminado exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del registro a eliminar") @PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
