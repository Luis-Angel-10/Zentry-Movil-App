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

import zentry.back.api.analytics.dtos.AbTestRequest;
import zentry.back.api.analytics.dtos.AbTestResponse;
import zentry.back.api.analytics.services.AbTestService;

@RestController
@RequestMapping("/api/analytics/ab-tests")
@Tag(name = "A/B Tests", description = "Configuración y metadatos de las pruebas A/B de la plataforma")
public class AbTestController {

    private final AbTestService service;

    public AbTestController(AbTestService service) {
        this.service = service;
    }

    // ─── GET /api/analytics/ab-tests ────────────────────────────────────────────
    @Operation(summary = "Listar pruebas A/B",
               description = "Obtiene una lista con la información base y nombres de todos los A/B tests creados.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<AbTestResponse>> list(
            @PageableDefault(size = 20, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    // ─── GET /api/analytics/ab-tests/{id} ───────────────────────────────────────
    @Operation(summary = "Obtener configuración de prueba A/B por ID",
               description = "Retorna la información base (nombre y descripción) del experimento.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro encontrado"),
        @ApiResponse(responseCode = "400", description = "ID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Prueba A/B no encontrada", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<AbTestResponse> getById(
            @Parameter(description = "ID del experimento") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    // ─── POST /api/analytics/ab-tests ───────────────────────────────────────────
    @Operation(summary = "Crear nueva prueba A/B",
               description = "Abre un nuevo registro que identifica y describe un experimento A/B.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Prueba A/B creada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos o faltantes", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<AbTestResponse> create(@Valid @RequestBody AbTestRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    // ─── PUT /api/analytics/ab-tests/{id} ───────────────────────────────────────
    @Operation(summary = "Actualizar prueba A/B",
               description = "Modifica los detalles (descripción, estado) de un experimento A/B ya registrado.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Prueba A/B no encontrada", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<AbTestResponse> update(
            @Parameter(description = "ID del experimento a actualizar") @PathVariable Integer id,
            @Valid @RequestBody AbTestRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    // ─── DELETE /api/analytics/ab-tests/{id} ────────────────────────────────────
    @Operation(summary = "Eliminar prueba A/B",
               description = "Borra el experimento del sistema (tener cuidado con dependencias).")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Registro eliminado exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Prueba A/B no encontrada", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del experimento a eliminar") @PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
