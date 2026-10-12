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

import zentry.back.api.ai.dtos.IaModelsRequest;
import zentry.back.api.ai.dtos.IaModelsResponse;
import zentry.back.api.ai.services.IaModelsService;

import java.util.UUID;

@RestController
@RequestMapping("/api/ai/models")
@Tag(name = "IA Models", description = "CRUD de modelos de inteligencia artificial registrados en el sistema")
public class IaModelsController {

    private final IaModelsService service;

    public IaModelsController(IaModelsService service) {
        this.service = service;
    }

    // ─── GET /api/ai/models ────────────────────────────────────────────────────
    @Operation(summary = "Listar todos los modelos de IA",
               description = "Devuelve una lista paginada de todos los modelos de IA registrados.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<IaModelsResponse>> list(
            @PageableDefault(size = 20, sort = "nombre") Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    // ─── GET /api/ai/models/{id} ───────────────────────────────────────────────
    @Operation(summary = "Obtener modelo de IA por ID",
               description = "Retorna un modelo específico dado su UUID.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Modelo encontrado"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Modelo no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<IaModelsResponse> getById(
            @Parameter(description = "UUID del modelo de IA") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    // ─── POST /api/ai/models ───────────────────────────────────────────────────
    @Operation(summary = "Crear nuevo modelo de IA",
               description = "Registra un nuevo modelo. El nombre debe ser único y no puede estar vacío.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Modelo creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos o nombre ya existe", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<IaModelsResponse> create(@Valid @RequestBody IaModelsRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    // ─── PUT /api/ai/models/{id} ───────────────────────────────────────────────
    @Operation(summary = "Actualizar modelo de IA",
               description = "Actualiza el nombre de un modelo existente.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Modelo actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos o UUID malformado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Modelo no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<IaModelsResponse> update(
            @Parameter(description = "UUID del modelo a actualizar") @PathVariable UUID id,
            @Valid @RequestBody IaModelsRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    // ─── DELETE /api/ai/models/{id} ────────────────────────────────────────────
    @Operation(summary = "Eliminar modelo de IA",
               description = "Elimina permanentemente un modelo de IA por su UUID.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Modelo eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Modelo no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "UUID del modelo a eliminar") @PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
