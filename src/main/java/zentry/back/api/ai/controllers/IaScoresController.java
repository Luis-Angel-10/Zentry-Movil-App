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

import zentry.back.api.ai.dtos.IaScoresRequest;
import zentry.back.api.ai.dtos.IaScoresResponse;
import zentry.back.api.ai.services.IaScoresService;

import java.util.UUID;

@RestController
@RequestMapping("/api/ai/scores")
@Tag(name = "IA Scores", description = "Puntuaciones de relevancia calculadas por IA para publicaciones")
public class IaScoresController {

    private final IaScoresService service;

    public IaScoresController(IaScoresService service) {
        this.service = service;
    }

    @Operation(summary = "Listar puntuaciones de IA",
               description = "Devuelve lista paginada de puntuaciones de relevancia por publicación.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<IaScoresResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener puntuación por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Puntuación encontrada"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Puntuación no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<IaScoresResponse> getById(
            @Parameter(description = "UUID de la puntuación") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Crear puntuación de IA",
               description = "Registra la puntuación de relevancia de un post. Score debe estar entre 0.0000 y 1.0000.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Puntuación creada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Score fuera de rango u otros datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<IaScoresResponse> create(
            @Valid @RequestBody IaScoresRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar puntuación de IA")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Puntuación actualizada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Puntuación no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<IaScoresResponse> update(
            @Parameter(description = "UUID de la puntuación") @PathVariable UUID id,
            @Valid @RequestBody IaScoresRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar puntuación de IA")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Puntuación eliminada exitosamente"),
        @ApiResponse(responseCode = "404", description = "Puntuación no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "UUID de la puntuación a eliminar") @PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
