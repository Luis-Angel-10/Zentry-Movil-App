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

import zentry.back.api.analytics.dtos.ConversionFunnelRequest;
import zentry.back.api.analytics.dtos.ConversionFunnelResponse;
import zentry.back.api.analytics.services.ConversionFunnelService;

@RestController
@RequestMapping("/api/analytics/conversion-funnels")
@Tag(name = "Conversion Funnels", description = "Análisis y métricas de los embudos de conversión (funnels)")
public class ConversionFunnelController {

    private final ConversionFunnelService service;

    public ConversionFunnelController(ConversionFunnelService service) {
        this.service = service;
    }

    // ─── GET /api/analytics/conversion-funnels ────────────────────────────────────────────
    @Operation(summary = "Listar funnels de conversión",
               description = "Devuelve todos los embudos de conversión y el progreso de los usuarios en cada etapa.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<ConversionFunnelResponse>> list(
            @PageableDefault(size = 20, sort = "recordedAt", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    // ─── GET /api/analytics/conversion-funnels/{id} ───────────────────────────────────────
    @Operation(summary = "Obtener funnel por ID",
               description = "Retorna el detalle completo de un embudo (steps, % conversión) por su identificador.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro encontrado"),
        @ApiResponse(responseCode = "400", description = "ID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<ConversionFunnelResponse> getById(
            @Parameter(description = "ID del funnel") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    // ─── POST /api/analytics/conversion-funnels ───────────────────────────────────────────
    @Operation(summary = "Crear registro de funnel",
               description = "Guarda las métricas (tasas, pasos, abandonos) de un nuevo embudo de conversión.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Registro creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos o faltantes", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<ConversionFunnelResponse> create(@Valid @RequestBody ConversionFunnelRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    // ─── PUT /api/analytics/conversion-funnels/{id} ───────────────────────────────────────
    @Operation(summary = "Actualizar embudo de conversión",
               description = "Actualiza las métricas y etapas de un funnel de conversión preexistente.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<ConversionFunnelResponse> update(
            @Parameter(description = "ID del registro a actualizar") @PathVariable Integer id,
            @Valid @RequestBody ConversionFunnelRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    // ─── DELETE /api/analytics/conversion-funnels/{id} ────────────────────────────────────
    @Operation(summary = "Eliminar funnel de conversión",
               description = "Elimina de la base de datos el registro del embudo de conversión.")
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
