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

import zentry.back.api.analytics.dtos.RetentionDataRequest;
import zentry.back.api.analytics.dtos.RetentionDataResponse;
import zentry.back.api.analytics.services.RetentionDataService;

@RestController
@RequestMapping("/api/analytics/retention-data")
@Tag(name = "Retention Data", description = "Seguimiento de las tasas de retención por cohortes de usuarios")
public class RetentionDataController {

    private final RetentionDataService service;

    public RetentionDataController(RetentionDataService service) {
        this.service = service;
    }

    // ─── GET /api/analytics/retention-data ────────────────────────────────────────────
    @Operation(summary = "Listar datos de retención",
               description = "Devuelve una lista paginada de todos los datos de retención organizados por cohorte.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<RetentionDataResponse>> list(
            @PageableDefault(size = 20, sort = "recordedAt", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    // ─── GET /api/analytics/retention-data/{id} ───────────────────────────────────────
    @Operation(summary = "Obtener dato de retención por ID",
               description = "Retorna el registro de retención específico de una cohorte mediante su ID.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro encontrado"),
        @ApiResponse(responseCode = "400", description = "ID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<RetentionDataResponse> getById(
            @Parameter(description = "ID del registro de retención") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    // ─── POST /api/analytics/retention-data ───────────────────────────────────────────
    @Operation(summary = "Registrar dato de retención",
               description = "Guarda la tasa de retención (ej. semanal, mensual) para una cohorte de usuarios determinada.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Registro creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos o faltantes", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<RetentionDataResponse> create(@Valid @RequestBody RetentionDataRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    // ─── PUT /api/analytics/retention-data/{id} ───────────────────────────────────────
    @Operation(summary = "Actualizar dato de retención",
               description = "Actualiza los porcentajes y métricas de una cohorte de retención existente.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<RetentionDataResponse> update(
            @Parameter(description = "ID del registro a actualizar") @PathVariable Integer id,
            @Valid @RequestBody RetentionDataRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    // ─── DELETE /api/analytics/retention-data/{id} ────────────────────────────────────
    @Operation(summary = "Eliminar dato de retención",
               description = "Borra el registro estadístico de retención del sistema.")
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
