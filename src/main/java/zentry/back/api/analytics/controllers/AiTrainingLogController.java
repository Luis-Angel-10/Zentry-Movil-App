package zentry.back.api.analytics.controllers;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import zentry.back.api.analytics.dtos.AiTrainingLogRequest;
import zentry.back.api.analytics.dtos.AiTrainingLogResponse;
import zentry.back.api.analytics.services.AiTrainingLogService;

@RestController
@RequestMapping("/api/analytics/ai-training-logs")
@Tag(name = "AI Training Logs", description = "Auditoría e historización de los entrenamientos de modelos IA")
public class AiTrainingLogController {

    private final AiTrainingLogService service;

    public AiTrainingLogController(AiTrainingLogService service) {
        this.service = service;
    }

    // ─── GET /api/analytics/ai-training-logs ────────────────────────────────────────────
    @Operation(summary = "Listar logs de entrenamiento IA",
               description = "Retorna una lista paginada de todos los entrenamientos de inteligencia artificial en base de datos.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<AiTrainingLogResponse>> list(
            @PageableDefault(size = 20, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    // ─── GET /api/analytics/ai-training-logs/{id} ───────────────────────────────────────
    @Operation(summary = "Obtener log de entrenamiento por ID",
               description = "Retorna los detalles completos de una corrida de entrenamiento.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro encontrado"),
        @ApiResponse(responseCode = "400", description = "ID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<AiTrainingLogResponse> getById(
            @Parameter(description = "ID del log de entrenamiento") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    // ─── POST /api/analytics/ai-training-logs ───────────────────────────────────────────
    @Operation(summary = "Registrar nuevo log de entrenamiento",
               description = "Registra un log con el input y output proporcionado hacia un modelo específico.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Registro creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos o faltantes", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<AiTrainingLogResponse> create(@Valid @RequestBody AiTrainingLogRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    // ─── PUT /api/analytics/ai-training-logs/{id} ───────────────────────────────────────
    @Operation(summary = "Actualizar log de entrenamiento",
               description = "Modifica la información almacenada en un log de modelo IA ya guardado.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<AiTrainingLogResponse> update(
            @Parameter(description = "ID del log a actualizar") @PathVariable Integer id,
            @Valid @RequestBody AiTrainingLogRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    // ─── DELETE /api/analytics/ai-training-logs/{id} ────────────────────────────────────
    @Operation(summary = "Eliminar log de entrenamiento",
               description = "Borra permanentemente un historial de entrenamiento de IA.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Registro eliminado exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del log a eliminar") @PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
