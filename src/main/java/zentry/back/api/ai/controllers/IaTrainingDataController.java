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

import zentry.back.api.ai.dtos.IaTrainingDataRequest;
import zentry.back.api.ai.dtos.IaTrainingDataResponse;
import zentry.back.api.ai.services.IaTrainingDataService;

import java.util.UUID;

@RestController
@RequestMapping("/api/ai/training-data")
@Tag(name = "IA Training Data", description = "Datos de entrenamiento utilizados para ajustar los modelos de IA")
public class IaTrainingDataController {

    private final IaTrainingDataService service;

    public IaTrainingDataController(IaTrainingDataService service) {
        this.service = service;
    }

    @Operation(summary = "Listar datos de entrenamiento",
               description = "Devuelve lista paginada de todos los datos de entrenamiento registrados.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<IaTrainingDataResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener dato de entrenamiento por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Dato encontrado"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Dato no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<IaTrainingDataResponse> getById(
            @Parameter(description = "UUID del dato de entrenamiento") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Crear dato de entrenamiento",
               description = "Registra un par input/output de entrenamiento. dataInput debe ser único.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Dato creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "dataInput duplicado u otros datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<IaTrainingDataResponse> create(
            @Valid @RequestBody IaTrainingDataRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar dato de entrenamiento")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Dato actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Dato no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<IaTrainingDataResponse> update(
            @Parameter(description = "UUID del dato de entrenamiento") @PathVariable UUID id,
            @Valid @RequestBody IaTrainingDataRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar dato de entrenamiento")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Dato eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Dato no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "UUID del dato de entrenamiento a eliminar") @PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
