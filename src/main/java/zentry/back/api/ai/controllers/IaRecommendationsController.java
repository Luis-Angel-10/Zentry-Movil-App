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

import zentry.back.api.ai.dtos.IaRecommendationsRequest;
import zentry.back.api.ai.dtos.IaRecommendationsResponse;
import zentry.back.api.ai.services.IaRecommendationsService;

import java.util.UUID;

@RestController
@RequestMapping("/api/ai/recommendations")
@Tag(name = "IA Recommendations", description = "Recomendaciones personalizadas de contenido generadas por IA para usuarios")
public class IaRecommendationsController {

    private final IaRecommendationsService service;

    public IaRecommendationsController(IaRecommendationsService service) {
        this.service = service;
    }

    @Operation(summary = "Listar recomendaciones de IA",
               description = "Devuelve lista paginada de recomendaciones generadas para usuarios.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<IaRecommendationsResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener recomendación por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Recomendación encontrada"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Recomendación no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<IaRecommendationsResponse> getById(
            @Parameter(description = "UUID de la recomendación") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Crear recomendación",
               description = "Registra una recomendación para un usuario. No puede existir ya una recomendación para el mismo usuario y contenido.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Recomendación creada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Recomendación duplicada u otros datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<IaRecommendationsResponse> create(
            @Valid @RequestBody IaRecommendationsRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar recomendación")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Recomendación actualizada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Recomendación no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<IaRecommendationsResponse> update(
            @Parameter(description = "UUID de la recomendación") @PathVariable UUID id,
            @Valid @RequestBody IaRecommendationsRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar recomendación")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Recomendación eliminada exitosamente"),
        @ApiResponse(responseCode = "404", description = "Recomendación no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "UUID de la recomendación a eliminar") @PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
