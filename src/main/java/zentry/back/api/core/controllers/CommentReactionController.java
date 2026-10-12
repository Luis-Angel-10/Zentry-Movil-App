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

import zentry.back.api.core.dtos.CommentReactionRequest;
import zentry.back.api.core.dtos.CommentReactionResponse;
import zentry.back.api.core.services.CommentReactionService;

@RestController
@RequestMapping("/api/core/comment-reactions")
@Tag(name = "Comment Reactions", description = "Gestión de reacciones a comentarios")
public class CommentReactionController {

    private final CommentReactionService service;

    public CommentReactionController(CommentReactionService service) {
        this.service = service;
    }

    @Operation(summary = "Listar reacciones de comentarios", description = "Devuelve lista paginada de todas las reacciones.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<CommentReactionResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener reacción de comentario por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Reacción encontrada"),
        @ApiResponse(responseCode = "404", description = "Reacción no encontrada", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<CommentReactionResponse> getById(
            @Parameter(description = "ID de la reacción") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Crear reacción a comentario")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Reacción creada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content)
    })
    @PostMapping
    public ResponseEntity<CommentReactionResponse> create(
            @Valid @RequestBody CommentReactionRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar reacción de comentario")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Reacción actualizada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Reacción no encontrada", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<CommentReactionResponse> update(
            @Parameter(description = "ID de la reacción") @PathVariable Integer id,
            @Valid @RequestBody CommentReactionRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar reacción de comentario")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Reacción eliminada exitosamente"),
        @ApiResponse(responseCode = "404", description = "Reacción no encontrada", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID de la reacción") @PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
