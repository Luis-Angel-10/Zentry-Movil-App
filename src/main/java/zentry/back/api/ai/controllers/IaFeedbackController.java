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

import zentry.back.api.ai.dtos.IaFeedbackRequest;
import zentry.back.api.ai.dtos.IaFeedbackResponse;
import zentry.back.api.ai.services.IaFeedbackService;

import java.util.UUID;

@RestController
@RequestMapping("/api/ai/feedback")
@Tag(name = "IA Feedback", description = "Feedback de usuarios hacia los resultados generados por la IA")
public class IaFeedbackController {

    private final IaFeedbackService service;

    public IaFeedbackController(IaFeedbackService service) {
        this.service = service;
    }

    @Operation(summary = "Listar registros de feedback",
               description = "Devuelve lista paginada de todos los feedbacks de usuario.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<IaFeedbackResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener feedback por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Feedback encontrado"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Feedback no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<IaFeedbackResponse> getById(
            @Parameter(description = "UUID del feedback") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Crear feedback de usuario",
               description = "Registra comentario de un usuario sobre un resultado de IA. El comentario no puede estar vacío.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Feedback creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Comentario vacío u otros datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<IaFeedbackResponse> create(
            @Valid @RequestBody IaFeedbackRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar feedback de usuario")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Feedback actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Feedback no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<IaFeedbackResponse> update(
            @Parameter(description = "UUID del feedback") @PathVariable UUID id,
            @Valid @RequestBody IaFeedbackRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar feedback de usuario")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Feedback eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Feedback no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "UUID del feedback a eliminar") @PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
