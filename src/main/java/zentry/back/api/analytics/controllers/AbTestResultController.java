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

import zentry.back.api.analytics.dtos.AbTestResultRequest;
import zentry.back.api.analytics.dtos.AbTestResultResponse;
import zentry.back.api.analytics.services.AbTestResultService;

@RestController
@RequestMapping("/api/analytics/ab-test-results")
@Tag(name = "A/B Test Results", description = "Resultados y variaciones aplicadas por usuario en un A/B Test")
public class AbTestResultController {

    private final AbTestResultService service;

    public AbTestResultController(AbTestResultService service) {
        this.service = service;
    }

    // ─── GET /api/analytics/ab-test-results ────────────────────────────────────────────
    @Operation(summary = "Listar resultados de pruebas A/B",
               description = "Devuelve los registros que mapean a los usuarios con la variante asignada y los resultados.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<AbTestResultResponse>> list(
            @PageableDefault(size = 20, sort = "recordedAt", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    // ─── GET /api/analytics/ab-test-results/{id} ───────────────────────────────────────
    @Operation(summary = "Obtener resultado específico por ID",
               description = "Obtiene la asignación o el resultado de un usuario para una prueba A/B dada.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro encontrado"),
        @ApiResponse(responseCode = "400", description = "ID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<AbTestResultResponse> getById(
            @Parameter(description = "ID del resultado") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    // ─── POST /api/analytics/ab-test-results ───────────────────────────────────────────
    @Operation(summary = "Registrar un resultado en prueba A/B",
               description = "Crea un registro de asignación de variante y/o conversión (resultado) del test.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Registro creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos o faltantes", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<AbTestResultResponse> create(@Valid @RequestBody AbTestResultRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    // ─── PUT /api/analytics/ab-test-results/{id} ───────────────────────────────────────
    @Operation(summary = "Actualizar el resultado del test",
               description = "Permite agregar o cambiar el estado del resultado a 'completado' o métricas obtenidas.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<AbTestResultResponse> update(
            @Parameter(description = "ID del registro a actualizar") @PathVariable Integer id,
            @Valid @RequestBody AbTestResultRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    // ─── DELETE /api/analytics/ab-test-results/{id} ────────────────────────────────────
    @Operation(summary = "Eliminar registro del test",
               description = "Remueve un registro de usuario en una prueba A/B específica.")
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
