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

import zentry.back.api.ai.dtos.RecommendationLogsRequest;
import zentry.back.api.ai.dtos.RecommendationLogsResponse;
import zentry.back.api.ai.services.RecommendationLogsService;

import java.util.UUID;

@RestController
@RequestMapping("/api/ai/recommendation-logs")
@Tag(name = "Recommendation Logs", description = "Logs de visualización/interacción de recomendaciones de IA")
public class RecommendationLogsController {

    private final RecommendationLogsService service;

    public RecommendationLogsController(RecommendationLogsService service) {
        this.service = service;
    }

    @Operation(summary = "Listar logs de recomendaciones",
               description = "Devuelve lista paginada de logs de interacción con recomendaciones generadas.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<RecommendationLogsResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener log de recomendación por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Log encontrado"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Log no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<RecommendationLogsResponse> getById(
            @Parameter(description = "UUID del log") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Crear log de recomendación",
               description = "Registra la interacción con una recomendación. recommendationId y timestamp son obligatorios.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Log creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<RecommendationLogsResponse> create(
            @Valid @RequestBody RecommendationLogsRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar log de recomendación")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Log actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Log no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<RecommendationLogsResponse> update(
            @Parameter(description = "UUID del log") @PathVariable UUID id,
            @Valid @RequestBody RecommendationLogsRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar log de recomendación")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Log eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Log no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "UUID del log a eliminar") @PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
