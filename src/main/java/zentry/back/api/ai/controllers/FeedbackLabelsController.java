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

import zentry.back.api.ai.dtos.FeedbackLabelsRequest;
import zentry.back.api.ai.dtos.FeedbackLabelsResponse;
import zentry.back.api.ai.services.FeedbackLabelsService;

import java.util.UUID;

@RestController
@RequestMapping("/api/ai/feedback-labels")
@Tag(name = "Feedback Labels", description = "Etiquetas asociadas a registros de feedback de usuario")
public class FeedbackLabelsController {

    private final FeedbackLabelsService service;

    public FeedbackLabelsController(FeedbackLabelsService service) {
        this.service = service;
    }

    @Operation(summary = "Listar etiquetas de feedback",
               description = "Devuelve lista paginada de todas las etiquetas registradas.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<FeedbackLabelsResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener etiqueta de feedback por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Etiqueta encontrada"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Etiqueta no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<FeedbackLabelsResponse> getById(
            @Parameter(description = "UUID de la etiqueta") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Crear etiqueta de feedback",
               description = "Registra una nueva etiqueta. feedbackId debe ser positivo y etiqueta no puede estar vacía.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Etiqueta creada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<FeedbackLabelsResponse> create(
            @Valid @RequestBody FeedbackLabelsRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar etiqueta de feedback")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Etiqueta actualizada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Etiqueta no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<FeedbackLabelsResponse> update(
            @Parameter(description = "UUID de la etiqueta") @PathVariable UUID id,
            @Valid @RequestBody FeedbackLabelsRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar etiqueta de feedback")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Etiqueta eliminada exitosamente"),
        @ApiResponse(responseCode = "404", description = "Etiqueta no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "UUID de la etiqueta a eliminar") @PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
