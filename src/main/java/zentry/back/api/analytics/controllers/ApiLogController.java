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

import zentry.back.api.analytics.dtos.ApiLogRequest;
import zentry.back.api.analytics.dtos.ApiLogResponse;
import zentry.back.api.analytics.services.ApiLogService;

@RestController
@RequestMapping("/api/analytics/api-logs")
@Tag(name = "API Logs", description = "Auditoría, tiempos de respuesta y peticiones hacia la API")
public class ApiLogController {

    private final ApiLogService service;

    public ApiLogController(ApiLogService service) {
        this.service = service;
    }

    // ─── GET /api/analytics/api-logs ────────────────────────────────────────────
    @Operation(summary = "Listar logs de API",
               description = "Devuelve una lista paginada con el detalle de las llamadas HTTP realizadas, incluyendo latencia y estado.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<ApiLogResponse>> list(
            @PageableDefault(size = 20, sort = "timestamp", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    // ─── GET /api/analytics/api-logs/{id} ───────────────────────────────────────
    @Operation(summary = "Obtener log de API por ID",
               description = "Retorna toda la información de una petición HTTP registrada mediante su ID.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro encontrado"),
        @ApiResponse(responseCode = "400", description = "ID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<ApiLogResponse> getById(
            @Parameter(description = "ID del log HTTP") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    // ─── POST /api/analytics/api-logs ───────────────────────────────────────────
    @Operation(summary = "Registrar log de API",
               description = "Inserta los metadatos de una petición de red entrante o saliente (endpoint, método, tiempo, etc.).")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Registro creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos o faltantes", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<ApiLogResponse> create(@Valid @RequestBody ApiLogRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    // ─── PUT /api/analytics/api-logs/{id} ───────────────────────────────────────
    @Operation(summary = "Actualizar log de API",
               description = "Sobrescribe la información de una petición de API.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<ApiLogResponse> update(
            @Parameter(description = "ID del log a actualizar") @PathVariable Integer id,
            @Valid @RequestBody ApiLogRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    // ─── DELETE /api/analytics/api-logs/{id} ────────────────────────────────────
    @Operation(summary = "Eliminar log de API",
               description = "Elimina permanentemente el rastro de una llamada HTTP.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Registro eliminado exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del log a eliminar") @PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
