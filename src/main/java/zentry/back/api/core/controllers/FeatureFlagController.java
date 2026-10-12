package zentry.back.api.core.controllers;

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

import zentry.back.api.core.dtos.FeatureFlagRequest;
import zentry.back.api.core.dtos.FeatureFlagResponse;
import zentry.back.api.core.services.FeatureFlagService;

@RestController
@RequestMapping("/api/core/feature-flags")
@Tag(name = "Feature Flags", description = "Gestión de banderas de funcionalidades del sistema")
public class FeatureFlagController {

    private final FeatureFlagService service;

    public FeatureFlagController(FeatureFlagService service) {
        this.service = service;
    }

    @Operation(summary = "Listar feature flags", description = "Devuelve lista paginada de todas las banderas de funcionalidades.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<FeatureFlagResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener feature flag por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Feature flag encontrado"),
        @ApiResponse(responseCode = "404", description = "Feature flag no encontrado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<FeatureFlagResponse> getById(
            @Parameter(description = "ID del feature flag") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Crear feature flag")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Feature flag creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content)
    })
    @PostMapping
    public ResponseEntity<FeatureFlagResponse> create(
            @Valid @RequestBody FeatureFlagRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar feature flag")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Feature flag actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Feature flag no encontrado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<FeatureFlagResponse> update(
            @Parameter(description = "ID del feature flag") @PathVariable Integer id,
            @Valid @RequestBody FeatureFlagRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar feature flag")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Feature flag eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Feature flag no encontrado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del feature flag") @PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
