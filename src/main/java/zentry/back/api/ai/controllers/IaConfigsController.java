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

import zentry.back.api.ai.dtos.IaConfigsRequest;
import zentry.back.api.ai.dtos.IaConfigsResponse;
import zentry.back.api.ai.services.IaConfigsService;

import java.util.UUID;

@RestController
@RequestMapping("/api/ai/configs")
@Tag(name = "IA Configs", description = "Configuraciones de parámetros para los modelos de IA")
public class IaConfigsController {

    private final IaConfigsService service;

    public IaConfigsController(IaConfigsService service) {
        this.service = service;
    }

    @Operation(summary = "Listar configuraciones de IA",
               description = "Devuelve lista paginada de configuraciones de parámetros registradas.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<IaConfigsResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener configuración de IA por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Configuración encontrada"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Configuración no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<IaConfigsResponse> getById(
            @Parameter(description = "UUID de la configuración") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Crear configuración de IA",
               description = "Registra una configuración de parámetros para un modelo. El campo 'parametros' es obligatorio.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Configuración creada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<IaConfigsResponse> create(
            @Valid @RequestBody IaConfigsRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar configuración de IA")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Configuración actualizada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Configuración no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<IaConfigsResponse> update(
            @Parameter(description = "UUID de la configuración") @PathVariable UUID id,
            @Valid @RequestBody IaConfigsRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar configuración de IA")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Configuración eliminada exitosamente"),
        @ApiResponse(responseCode = "404", description = "Configuración no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "UUID de la configuración a eliminar") @PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
