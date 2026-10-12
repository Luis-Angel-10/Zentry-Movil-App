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

import zentry.back.api.analytics.dtos.HeatmapRequest;
import zentry.back.api.analytics.dtos.HeatmapResponse;
import zentry.back.api.analytics.services.HeatmapService;

@RestController
@RequestMapping("/api/analytics/heatmaps")
@Tag(name = "Heatmaps", description = "Gestión de mapas de calor recopilados por página")
public class HeatmapController {

    private final HeatmapService service;

    public HeatmapController(HeatmapService service) {
        this.service = service;
    }

    // ─── GET /api/analytics/heatmaps ────────────────────────────────────────────
    @Operation(summary = "Listar mapas de calor",
               description = "Devuelve una lista paginada de todos los mapas de calor registrados.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<HeatmapResponse>> list(
            @PageableDefault(size = 20, sort = "recordedAt", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    // ─── GET /api/analytics/heatmaps/{id} ───────────────────────────────────────
    @Operation(summary = "Obtener mapa de calor por ID",
               description = "Retorna un mapa de calor específico a través de su ID.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro encontrado"),
        @ApiResponse(responseCode = "400", description = "ID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<HeatmapResponse> getById(
            @Parameter(description = "ID del mapa de calor") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    // ─── POST /api/analytics/heatmaps ───────────────────────────────────────────
    @Operation(summary = "Crear mapa de calor",
               description = "Registra un nuevo mapa de calor (agrupación de clics) para una página dada.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Registro creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos o faltantes", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<HeatmapResponse> create(@Valid @RequestBody HeatmapRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    // ─── PUT /api/analytics/heatmaps/{id} ───────────────────────────────────────
    @Operation(summary = "Actualizar mapa de calor",
               description = "Actualiza la información (datos de clics) de un mapa de calor existente.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<HeatmapResponse> update(
            @Parameter(description = "ID del registro a actualizar") @PathVariable Integer id,
            @Valid @RequestBody HeatmapRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    // ─── DELETE /api/analytics/heatmaps/{id} ────────────────────────────────────
    @Operation(summary = "Eliminar mapa de calor",
               description = "Borra un mapa de calor de forma permanente.")
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
