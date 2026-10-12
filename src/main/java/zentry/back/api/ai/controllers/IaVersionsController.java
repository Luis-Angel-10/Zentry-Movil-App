package zentry.back.api.ai.controllers;

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

import zentry.back.api.ai.dtos.IaVersionsRequest;
import zentry.back.api.ai.dtos.IaVersionsResponse;
import zentry.back.api.ai.services.IaVersionsService;

import java.util.UUID;

@RestController
@RequestMapping("/api/ai/versions")
@Tag(name = "IA Versions", description = "Versiones registradas de los modelos de IA")
public class IaVersionsController {

    private final IaVersionsService service;

    public IaVersionsController(IaVersionsService service) {
        this.service = service;
    }

    @Operation(summary = "Listar versiones de modelos de IA",
               description = "Devuelve lista paginada de versiones registradas para los modelos.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<IaVersionsResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener versión por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Versión encontrada"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Versión no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<IaVersionsResponse> getById(
            @Parameter(description = "UUID de la versión") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Crear versión de modelo",
               description = "Registra una nueva versión de un modelo. No puede existir ya la misma versión para el mismo modelId.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Versión creada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Versión duplicada u otros datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<IaVersionsResponse> create(
            @Valid @RequestBody IaVersionsRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar versión de modelo")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Versión actualizada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Versión no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<IaVersionsResponse> update(
            @Parameter(description = "UUID de la versión") @PathVariable UUID id,
            @Valid @RequestBody IaVersionsRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar versión de modelo")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Versión eliminada exitosamente"),
        @ApiResponse(responseCode = "404", description = "Versión no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "UUID de la versión a eliminar") @PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
