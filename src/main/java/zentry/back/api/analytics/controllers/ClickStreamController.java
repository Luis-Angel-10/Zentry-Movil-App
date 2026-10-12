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

import zentry.back.api.analytics.dtos.ClickStreamRequest;
import zentry.back.api.analytics.dtos.ClickStreamResponse;
import zentry.back.api.analytics.services.ClickStreamService;

@RestController
@RequestMapping("/api/analytics/click-stream")
@Tag(name = "Click Stream", description = "Seguimiento y flujo de clics por usuario")
public class ClickStreamController {

    private final ClickStreamService service;

    public ClickStreamController(ClickStreamService service) {
        this.service = service;
    }

    // ─── GET /api/analytics/click-stream ────────────────────────────────────────────
    @Operation(summary = "Listar flujo de clics",
               description = "Devuelve una lista paginada de los registros de clic de los usuarios, ordenados por fecha descendente.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<ClickStreamResponse>> list(
            @PageableDefault(size = 20, sort = "timestamp", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    // ─── GET /api/analytics/click-stream/{id} ───────────────────────────────────────
    @Operation(summary = "Obtener registro de clic por ID",
               description = "Retorna un evento de clic específico dado su ID.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro encontrado"),
        @ApiResponse(responseCode = "400", description = "ID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<ClickStreamResponse> getById(
            @Parameter(description = "ID del evento de clic") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    // ─── POST /api/analytics/click-stream ───────────────────────────────────────────
    @Operation(summary = "Registrar evento de clic",
               description = "Guarda la interacción de clic de un usuario sobre un elemento de la página.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Registro creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos o faltantes", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<ClickStreamResponse> create(@Valid @RequestBody ClickStreamRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    // ─── PUT /api/analytics/click-stream/{id} ───────────────────────────────────────
    @Operation(summary = "Actualizar evento de clic",
               description = "Modifica los datos de un evento de clic ya existente.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<ClickStreamResponse> update(
            @Parameter(description = "ID del evento a actualizar") @PathVariable Integer id,
            @Valid @RequestBody ClickStreamRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    // ─── DELETE /api/analytics/click-stream/{id} ────────────────────────────────────
    @Operation(summary = "Eliminar evento de clic",
               description = "Borra un registro de clic del sistema.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Registro eliminado exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del evento a eliminar") @PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
