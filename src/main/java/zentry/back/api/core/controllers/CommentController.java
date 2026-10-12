package zentry.back.api.core.controllers;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.CommentRequest;
import zentry.back.api.core.dtos.CommentResponse;
import zentry.back.api.core.services.CommentService;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/core/comments")
@Tag(name = "Comments", description = "Gestión de comentarios en publicaciones")
public class CommentController {

    private final CommentService service;

    public CommentController(CommentService service) {
        this.service = service;
    }

    @Operation(summary = "Listar comentarios de una publicación", description = "Devuelve los comentarios de un post ordenados cronológicamente.")
    @GetMapping("/post/{postId}")
    public ResponseEntity<List<CommentResponse>> listByPost(
            @Parameter(description = "ID de la publicación") @PathVariable Integer postId) {
        return ResponseEntity.ok(service.listByPost(postId));
    }

    @Operation(summary = "Crear comentario en una publicación")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Comentario creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Publicación no encontrada", content = @Content)
    })
    @PostMapping("/post/{postId}")
    public ResponseEntity<CommentResponse> create(
            @Parameter(description = "ID de la publicación") @PathVariable Integer postId,
            @Valid @RequestBody CommentRequest request,
            Principal principal) {
        String username = requireUsername(principal);
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(postId, username, request));
    }

    @Operation(summary = "Eliminar comentario propio")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Comentario eliminado exitosamente"),
        @ApiResponse(responseCode = "403", description = "No es el autor del comentario", content = @Content),
        @ApiResponse(responseCode = "404", description = "Comentario no encontrado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del comentario") @PathVariable Integer id,
            Principal principal) {
        String username = requireUsername(principal);
        service.delete(id, username);
        return ResponseEntity.noContent().build();
    }

    private String requireUsername(Principal principal) {
        if (principal == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Debes iniciar sesión");
        }
        return principal.getName();
    }
}
