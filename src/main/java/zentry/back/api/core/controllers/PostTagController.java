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

import zentry.back.api.core.dtos.PostTagRequest;
import zentry.back.api.core.dtos.PostTagResponse;
import zentry.back.api.core.services.PostTagService;

@RestController
@RequestMapping("/api/core/post-tags")
@Tag(name = "Post Tags", description = "Gestión de etiquetas asociadas a publicaciones — clave compuesta (postId + tagId)")
public class PostTagController {

    private final PostTagService service;

    public PostTagController(PostTagService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Listar etiquetas de publicaciones")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno", content = @Content)
    })
    public ResponseEntity<Page<PostTagResponse>> list(@PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @GetMapping("/{postId}/{tagId}")
    @Operation(summary = "Obtener etiqueta de publicación por clave compuesta",
               description = "Requiere postId y tagId para identificar el registro.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Relación encontrada"),
        @ApiResponse(responseCode = "400", description = "IDs inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "No encontrada", content = @Content)
    })
    public ResponseEntity<PostTagResponse> getById(
            @Parameter(description = "ID de la publicación") @PathVariable Integer postId,
            @Parameter(description = "ID de la etiqueta") @PathVariable Integer tagId) {
        return ResponseEntity.ok(service.getById(postId, tagId));
    }

    @PostMapping
    @Operation(summary = "Agregar etiqueta a publicación",
               description = "No puede existir ya la misma combinación de postId y tagId.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Etiqueta agregada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Relación duplicada o datos inválidos", content = @Content)
    })
    public ResponseEntity<PostTagResponse> create(@Valid @RequestBody PostTagRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @DeleteMapping("/{postId}/{tagId}")
    @Operation(summary = "Eliminar etiqueta de publicación")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Relación eliminada exitosamente"),
        @ApiResponse(responseCode = "404", description = "No encontrada", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID de la publicación") @PathVariable Integer postId,
            @Parameter(description = "ID de la etiqueta") @PathVariable Integer tagId) {
        service.delete(postId, tagId);
        return ResponseEntity.noContent().build();
    }
}
