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

import zentry.back.api.ai.dtos.IaTrainingLogsRequest;
import zentry.back.api.ai.dtos.IaTrainingLogsResponse;
import zentry.back.api.ai.services.IaTrainingLogsService;

import java.util.UUID;

@RestController
@RequestMapping("/api/ai/training-logs")
@Tag(name = "IA Training Logs", description = "Logs del proceso de entrenamiento de modelos de IA")
public class IaTrainingLogsController {

    private final IaTrainingLogsService service;

    public IaTrainingLogsController(IaTrainingLogsService service) {
        this.service = service;
    }

    @Operation(summary = "Listar logs de entrenamiento",
               description = "Devuelve lista paginada de registros del proceso de entrenamiento.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<IaTrainingLogsResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener log de entrenamiento por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Log encontrado"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Log no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<IaTrainingLogsResponse> getById(
            @Parameter(description = "UUID del log de entrenamiento") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Crear log de entrenamiento",
               description = "Registra un nuevo log del proceso de entrenamiento. estado y fecha son obligatorios.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Log creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos (estado vacío, fecha nula, etc.)", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<IaTrainingLogsResponse> create(
            @Valid @RequestBody IaTrainingLogsRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar log de entrenamiento")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Log actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Log no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<IaTrainingLogsResponse> update(
            @Parameter(description = "UUID del log de entrenamiento") @PathVariable UUID id,
            @Valid @RequestBody IaTrainingLogsRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar log de entrenamiento")
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
