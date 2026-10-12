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

import zentry.back.api.analytics.dtos.FeatureUsageRequest;
import zentry.back.api.analytics.dtos.FeatureUsageResponse;
import zentry.back.api.analytics.services.FeatureUsageService;

@RestController
@RequestMapping("/api/analytics/feature-usage")
@Tag(name = "Feature Usage", description = "Monitoreo del uso e impacto de las distintas features del sistema")
public class FeatureUsageController {

    private final FeatureUsageService service;

    public FeatureUsageController(FeatureUsageService service) {
        this.service = service;
    }

    // ─── GET /api/analytics/feature-usage ────────────────────────────────────────────
    @Operation(summary = "Listar uso de features",
               description = "Devuelve una lista de la utilización de las diferentes funcionalidades de la plataforma.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<FeatureUsageResponse>> list(
            @PageableDefault(size = 20, sort = "recordedAt", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    // ─── GET /api/analytics/feature-usage/{id} ───────────────────────────────────────
    @Operation(summary = "Obtener uso de feature por ID",
               description = "Retorna el contador y metadata de uso de una feature dada por ID.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro encontrado"),
        @ApiResponse(responseCode = "400", description = "ID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<FeatureUsageResponse> getById(
            @Parameter(description = "ID del registro de feature") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    // ─── POST /api/analytics/feature-usage ───────────────────────────────────────────
    @Operation(summary = "Registrar uso de feature",
               description = "Almacena la métrica o incremento del uso de una funcionalidad de la app.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Registro creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos o faltantes", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<FeatureUsageResponse> create(@Valid @RequestBody FeatureUsageRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    // ─── PUT /api/analytics/feature-usage/{id} ───────────────────────────────────────
    @Operation(summary = "Actualizar uso de feature",
               description = "Modifica los datos guardados para el uso de una funcionalidad específica.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<FeatureUsageResponse> update(
            @Parameter(description = "ID del registro a actualizar") @PathVariable Integer id,
            @Valid @RequestBody FeatureUsageRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    // ─── DELETE /api/analytics/feature-usage/{id} ────────────────────────────────────
    @Operation(summary = "Eliminar uso de feature",
               description = "Remueve de la base de datos el contador de uso de esa feature.")
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
