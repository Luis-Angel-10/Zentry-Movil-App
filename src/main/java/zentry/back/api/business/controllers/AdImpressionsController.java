package zentry.back.api.business.controllers;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import zentry.back.api.business.dtos.AdImpressionsRequest;
import zentry.back.api.business.dtos.AdImpressionsResponse;
import zentry.back.api.business.services.AdImpressionsService;

import java.util.UUID;

@RestController
@RequestMapping("/api/business/ad-impressions")
@Tag(name = "Ad Impressions", description = "Registro de impresiones de campañas publicitarias")
public class AdImpressionsController {

    private final AdImpressionsService service;

    public AdImpressionsController(AdImpressionsService service) {
        this.service = service;
    }

    @Operation(summary = "Listar impresiones de anuncios")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<AdImpressionsResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener impresión por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Impresión encontrada"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Impresión no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<AdImpressionsResponse> getById(
            @Parameter(description = "UUID del registro de impresión") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Registrar impresión de anuncio")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Impresión registrada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<AdImpressionsResponse> create(
            @Valid @RequestBody AdImpressionsRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar impresión de anuncio")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Impresión actualizada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Impresión no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<AdImpressionsResponse> update(
            @Parameter(description = "UUID de la impresión") @PathVariable UUID id,
            @Valid @RequestBody AdImpressionsRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar registro de impresión")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Impresión eliminada exitosamente"),
        @ApiResponse(responseCode = "404", description = "Impresión no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "UUID de la impresión") @PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
