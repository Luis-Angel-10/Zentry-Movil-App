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

import zentry.back.api.analytics.dtos.ContentPerformanceRequest;
import zentry.back.api.analytics.dtos.ContentPerformanceResponse;
import zentry.back.api.analytics.services.ContentPerformanceService;

@RestController
@RequestMapping("/api/analytics/content-performance")
@Tag(name = "Content Performance", description = "Monitoreo del rendimiento de publicaciones (vistas y likes)")
public class ContentPerformanceController {

    private final ContentPerformanceService service;

    public ContentPerformanceController(ContentPerformanceService service) {
        this.service = service;
    }

    // ─── GET /api/analytics/content-performance ────────────────────────────────────────────
    @Operation(summary = "Listar rendimiento de contenidos",
               description = "Devuelve una lista paginada del desempeño recolectado para los contenidos de la plataforma.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<ContentPerformanceResponse>> list(
            @PageableDefault(size = 20, sort = "recordedAt", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    // ─── GET /api/analytics/content-performance/{id} ───────────────────────────────────────
    @Operation(summary = "Obtener rendimiento por ID",
               description = "Retorna el registro de métricas de un post específico.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro encontrado"),
        @ApiResponse(responseCode = "400", description = "ID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<ContentPerformanceResponse> getById(
            @Parameter(description = "ID del registro de rendimiento") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    // ─── POST /api/analytics/content-performance ───────────────────────────────────────────
    @Operation(summary = "Registrar métrica de rendimiento",
               description = "Inserta un nuevo corte de las métricas que tiene un post (views y likes).")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Registro creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos o faltantes", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<ContentPerformanceResponse> create(@Valid @RequestBody ContentPerformanceRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    // ─── PUT /api/analytics/content-performance/{id} ───────────────────────────────────────
    @Operation(summary = "Actualizar métrica de contenido",
               description = "Modifica los indicadores almacenados para un evento de rendimiento.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<ContentPerformanceResponse> update(
            @Parameter(description = "ID del registro a actualizar") @PathVariable Integer id,
            @Valid @RequestBody ContentPerformanceRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    // ─── DELETE /api/analytics/content-performance/{id} ────────────────────────────────────
    @Operation(summary = "Eliminar métrica de rendimiento",
               description = "Borra permanentemente el corte de rendimiento de un contenido.")
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
