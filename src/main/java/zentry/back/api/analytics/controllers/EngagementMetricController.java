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

import zentry.back.api.analytics.dtos.EngagementMetricRequest;
import zentry.back.api.analytics.dtos.EngagementMetricResponse;
import zentry.back.api.analytics.services.EngagementMetricService;

@RestController
@RequestMapping("/api/analytics/engagement-metrics")
@Tag(name = "Engagement Metrics", description = "Cálculo y seguimiento del puntaje de engagement de los usuarios")
public class EngagementMetricController {

    private final EngagementMetricService service;

    public EngagementMetricController(EngagementMetricService service) {
        this.service = service;
    }

    // ─── GET /api/analytics/engagement-metrics ────────────────────────────────────────────
    @Operation(summary = "Listar métricas de engagement",
               description = "Devuelve una lista paginada de todos los cálculos de engagement registrados.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<EngagementMetricResponse>> list(
            @PageableDefault(size = 20, sort = "recordedAt", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    // ─── GET /api/analytics/engagement-metrics/{id} ───────────────────────────────────────
    @Operation(summary = "Obtener métrica de engagement por ID",
               description = "Retorna un puntaje de engagement de usuario específico registrado en el historial.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro encontrado"),
        @ApiResponse(responseCode = "400", description = "ID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<EngagementMetricResponse> getById(
            @Parameter(description = "ID de la métrica") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    // ─── POST /api/analytics/engagement-metrics ───────────────────────────────────────────
    @Operation(summary = "Registrar métrica de engagement",
               description = "Agrega un nuevo puntaje calculado del compromiso y uso de un usuario en un momento dado.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Registro creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos o faltantes", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<EngagementMetricResponse> create(@Valid @RequestBody EngagementMetricRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    // ─── PUT /api/analytics/engagement-metrics/{id} ───────────────────────────────────────
    @Operation(summary = "Actualizar métrica de engagement",
               description = "Actualiza los datos del puntaje de engagement registrado.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<EngagementMetricResponse> update(
            @Parameter(description = "ID del registro a actualizar") @PathVariable Integer id,
            @Valid @RequestBody EngagementMetricRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    // ─── DELETE /api/analytics/engagement-metrics/{id} ────────────────────────────────────
    @Operation(summary = "Eliminar métrica de engagement",
               description = "Elimina permanentemente una métrica de engagement calculada.")
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
