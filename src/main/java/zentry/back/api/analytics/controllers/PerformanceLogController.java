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

import zentry.back.api.analytics.dtos.PerformanceLogRequest;
import zentry.back.api.analytics.dtos.PerformanceLogResponse;
import zentry.back.api.analytics.services.PerformanceLogService;

@RestController
@RequestMapping("/api/analytics/performance-logs")
@Tag(name = "Performance Logs", description = "Métricas core de rendimiento del sistema (CPU, Memoria, IO)")
public class PerformanceLogController {

    private final PerformanceLogService service;

    public PerformanceLogController(PerformanceLogService service) {
        this.service = service;
    }

    // ─── GET /api/analytics/performance-logs ────────────────────────────────────────────
    @Operation(summary = "Listar métricas de rendimiento",
               description = "Devuelve una lista de los logs de performance del servidor y el sistema.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<PerformanceLogResponse>> list(
            @PageableDefault(size = 20, sort = "timestamp", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    // ─── GET /api/analytics/performance-logs/{id} ───────────────────────────────────────
    @Operation(summary = "Obtener log de rendimiento por ID",
               description = "Obtiene los valores puntuales guardados en una métrica de rendimiento específica.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro encontrado"),
        @ApiResponse(responseCode = "400", description = "ID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<PerformanceLogResponse> getById(
            @Parameter(description = "ID del registro de performance") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    // ─── POST /api/analytics/performance-logs ───────────────────────────────────────────
    @Operation(summary = "Registrar log de rendimiento",
               description = "Guarda la toma (snapshot) del rendimiento del sistema (por ejemplo, memory usage).")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Registro creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos o faltantes", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<PerformanceLogResponse> create(@Valid @RequestBody PerformanceLogRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    // ─── PUT /api/analytics/performance-logs/{id} ───────────────────────────────────────
    @Operation(summary = "Actualizar log de rendimiento",
               description = "Actualiza los valores de la toma de métricas del servidor.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<PerformanceLogResponse> update(
            @Parameter(description = "ID del registro a actualizar") @PathVariable Integer id,
            @Valid @RequestBody PerformanceLogRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    // ─── DELETE /api/analytics/performance-logs/{id} ────────────────────────────────────
    @Operation(summary = "Eliminar log de rendimiento",
               description = "Remueve permanentemente el snapshot de performance.")
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
