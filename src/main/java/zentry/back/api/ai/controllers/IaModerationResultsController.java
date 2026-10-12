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

import zentry.back.api.ai.dtos.IaModerationResultsRequest;
import zentry.back.api.ai.dtos.IaModerationResultsResponse;
import zentry.back.api.ai.services.IaModerationResultsService;

import java.util.UUID;

@RestController
@RequestMapping("/api/ai/moderation-results")
@Tag(name = "IA Moderation Results", description = "Resultados de moderación automática de contenido por IA")
public class IaModerationResultsController {

    private final IaModerationResultsService service;

    public IaModerationResultsController(IaModerationResultsService service) {
        this.service = service;
    }

    @Operation(summary = "Listar resultados de moderación",
               description = "Devuelve lista paginada de resultados de moderación de contenido.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<IaModerationResultsResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener resultado de moderación por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Resultado encontrado"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Resultado no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<IaModerationResultsResponse> getById(
            @Parameter(description = "UUID del resultado de moderación") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Crear resultado de moderación",
               description = "Registra el resultado de una moderación automática sobre un post. postId debe ser positivo.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Resultado creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<IaModerationResultsResponse> create(
            @Valid @RequestBody IaModerationResultsRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar resultado de moderación")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Resultado actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Resultado no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<IaModerationResultsResponse> update(
            @Parameter(description = "UUID del resultado") @PathVariable UUID id,
            @Valid @RequestBody IaModerationResultsRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar resultado de moderación")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Resultado eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Resultado no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "UUID del resultado a eliminar") @PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
