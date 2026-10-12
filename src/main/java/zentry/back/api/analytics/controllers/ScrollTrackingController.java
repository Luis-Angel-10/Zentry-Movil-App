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

import zentry.back.api.analytics.dtos.ScrollTrackingRequest;
import zentry.back.api.analytics.dtos.ScrollTrackingResponse;
import zentry.back.api.analytics.services.ScrollTrackingService;

@RestController
@RequestMapping("/api/analytics/scroll-tracking")
@Tag(name = "Scroll Tracking", description = "Análisis de profundidad de scroll por usuario y página")
public class ScrollTrackingController {

    private final ScrollTrackingService service;

    public ScrollTrackingController(ScrollTrackingService service) {
        this.service = service;
    }

    // ─── GET /api/analytics/scroll-tracking ────────────────────────────────────────────
    @Operation(summary = "Listar registros de scroll",
               description = "Devuelve una lista paginada de la profundidad de scroll de los usuarios, ordenados por fecha.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<ScrollTrackingResponse>> list(
            @PageableDefault(size = 20, sort = "timestamp", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    // ─── GET /api/analytics/scroll-tracking/{id} ───────────────────────────────────────
    @Operation(summary = "Obtener registro de scroll por ID",
               description = "Retorna un evento de scroll específico usando su identificador.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro encontrado"),
        @ApiResponse(responseCode = "400", description = "ID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<ScrollTrackingResponse> getById(
            @Parameter(description = "ID del registro") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    // ─── POST /api/analytics/scroll-tracking ───────────────────────────────────────────
    @Operation(summary = "Registrar profundidad de scroll",
               description = "Guarda un nuevo evento de profundidad de scroll alcanzada por un usuario.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Registro creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos o faltantes", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<ScrollTrackingResponse> create(@Valid @RequestBody ScrollTrackingRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    // ─── PUT /api/analytics/scroll-tracking/{id} ───────────────────────────────────────
    @Operation(summary = "Actualizar registro de scroll",
               description = "Modifica los detalles de un registro de scroll existente.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<ScrollTrackingResponse> update(
            @Parameter(description = "ID del registro a actualizar") @PathVariable Integer id,
            @Valid @RequestBody ScrollTrackingRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    // ─── DELETE /api/analytics/scroll-tracking/{id} ────────────────────────────────────
    @Operation(summary = "Eliminar registro de scroll",
               description = "Elimina permanentemente un evento de scroll del sistema.")
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
