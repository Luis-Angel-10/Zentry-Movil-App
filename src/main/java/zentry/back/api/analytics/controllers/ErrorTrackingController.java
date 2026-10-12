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

import zentry.back.api.analytics.dtos.ErrorTrackingRequest;
import zentry.back.api.analytics.dtos.ErrorTrackingResponse;
import zentry.back.api.analytics.services.ErrorTrackingService;

@RestController
@RequestMapping("/api/analytics/error-tracking")
@Tag(name = "Error Tracking", description = "Recolección y análisis de errores o crashes (frontend/backend)")
public class ErrorTrackingController {

    private final ErrorTrackingService service;

    public ErrorTrackingController(ErrorTrackingService service) {
        this.service = service;
    }

    // ─── GET /api/analytics/error-tracking ────────────────────────────────────────────
    @Operation(summary = "Listar errores reportados",
               description = "Devuelve una lista paginada de todos los errores reportados (stack traces, issues) por el sistema.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<ErrorTrackingResponse>> list(
            @PageableDefault(size = 20, sort = "timestamp", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    // ─── GET /api/analytics/error-tracking/{id} ───────────────────────────────────────
    @Operation(summary = "Obtener error por ID",
               description = "Retorna el detalle completo de un crash o error incluyendo su stack trace.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro encontrado"),
        @ApiResponse(responseCode = "400", description = "ID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<ErrorTrackingResponse> getById(
            @Parameter(description = "ID del error") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    // ─── POST /api/analytics/error-tracking ───────────────────────────────────────────
    @Operation(summary = "Registrar nuevo error",
               description = "Guarda en la base de datos el error ocurrido (ej. en el cliente) con toda su información relevante.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Registro creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos o faltantes", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<ErrorTrackingResponse> create(@Valid @RequestBody ErrorTrackingRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    // ─── PUT /api/analytics/error-tracking/{id} ───────────────────────────────────────
    @Operation(summary = "Actualizar reporte de error",
               description = "Modifica los datos de un error registrado (ej. cambiar su estado, marcar resuelto).")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<ErrorTrackingResponse> update(
            @Parameter(description = "ID del error a actualizar") @PathVariable Integer id,
            @Valid @RequestBody ErrorTrackingRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    // ─── DELETE /api/analytics/error-tracking/{id} ────────────────────────────────────
    @Operation(summary = "Eliminar reporte de error",
               description = "Borra el reporte de error de los registros del sistema.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Registro eliminado exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del error a eliminar") @PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
