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

import zentry.back.api.ai.dtos.IaPredictionsRequest;
import zentry.back.api.ai.dtos.IaPredictionsResponse;
import zentry.back.api.ai.services.IaPredictionsService;

import java.util.UUID;

@RestController
@RequestMapping("/api/ai/predictions")
@Tag(name = "IA Predictions", description = "Predicciones generadas por los modelos de IA")
public class IaPredictionsController {

    private final IaPredictionsService service;

    public IaPredictionsController(IaPredictionsService service) {
        this.service = service;
    }

    @Operation(summary = "Listar predicciones de IA",
               description = "Devuelve lista paginada de todas las predicciones generadas por modelos.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<IaPredictionsResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener predicción por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Predicción encontrada"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Predicción no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<IaPredictionsResponse> getById(
            @Parameter(description = "UUID de la predicción") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Crear predicción",
               description = "Registra una predicción del modelo. modelId y resultado son obligatorios.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Predicción creada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<IaPredictionsResponse> create(
            @Valid @RequestBody IaPredictionsRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar predicción")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Predicción actualizada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Predicción no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<IaPredictionsResponse> update(
            @Parameter(description = "UUID de la predicción") @PathVariable UUID id,
            @Valid @RequestBody IaPredictionsRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar predicción")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Predicción eliminada exitosamente"),
        @ApiResponse(responseCode = "404", description = "Predicción no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "UUID de la predicción a eliminar") @PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
