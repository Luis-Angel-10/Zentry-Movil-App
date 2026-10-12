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

import zentry.back.api.ai.dtos.IaClustersRequest;
import zentry.back.api.ai.dtos.IaClustersResponse;
import zentry.back.api.ai.services.IaClustersService;

import java.util.UUID;

@RestController
@RequestMapping("/api/ai/clusters")
@Tag(name = "IA Clusters", description = "Gestión de clusters de segmentación utilizados por los modelos de IA")
public class IaClustersController {

    private final IaClustersService service;

    public IaClustersController(IaClustersService service) {
        this.service = service;
    }

    @Operation(summary = "Listar clusters de IA",
               description = "Devuelve lista paginada de todos los clusters definidos.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<IaClustersResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener cluster de IA por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Cluster encontrado"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Cluster no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<IaClustersResponse> getById(
            @Parameter(description = "UUID del cluster") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Crear cluster de IA",
               description = "Crea un nuevo cluster. La descripción debe ser única y no exceder 100 caracteres.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Cluster creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Descripción duplicada o datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<IaClustersResponse> create(
            @Valid @RequestBody IaClustersRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar cluster de IA")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Cluster actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Cluster no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<IaClustersResponse> update(
            @Parameter(description = "UUID del cluster") @PathVariable UUID id,
            @Valid @RequestBody IaClustersRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar cluster de IA")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Cluster eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Cluster no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "UUID del cluster a eliminar") @PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
