package zentry.back.api.core.controllers;

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

import zentry.back.api.core.dtos.CommentReplyRequest;
import zentry.back.api.core.dtos.CommentReplyResponse;
import zentry.back.api.core.services.CommentReplyService;

@RestController
@RequestMapping("/api/core/comment-replies")
@Tag(name = "Comment Replies", description = "Gestión de respuestas a comentarios")
public class CommentReplyController {

    private final CommentReplyService service;

    public CommentReplyController(CommentReplyService service) {
        this.service = service;
    }

    @Operation(summary = "Listar respuestas de comentarios", description = "Devuelve lista paginada de todas las respuestas.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<CommentReplyResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener respuesta por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Respuesta encontrada"),
        @ApiResponse(responseCode = "404", description = "Respuesta no encontrada", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<CommentReplyResponse> getById(
            @Parameter(description = "ID de la respuesta") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Crear respuesta a comentario")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Respuesta creada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content)
    })
    @PostMapping
    public ResponseEntity<CommentReplyResponse> create(
            @Valid @RequestBody CommentReplyRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar respuesta de comentario")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Respuesta actualizada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Respuesta no encontrada", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<CommentReplyResponse> update(
            @Parameter(description = "ID de la respuesta") @PathVariable Integer id,
            @Valid @RequestBody CommentReplyRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar respuesta de comentario")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Respuesta eliminada exitosamente"),
        @ApiResponse(responseCode = "404", description = "Respuesta no encontrada", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID de la respuesta") @PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
