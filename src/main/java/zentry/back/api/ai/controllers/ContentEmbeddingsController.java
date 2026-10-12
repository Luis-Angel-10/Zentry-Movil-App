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

import zentry.back.api.ai.dtos.ContentEmbeddingsRequest;
import zentry.back.api.ai.dtos.ContentEmbeddingsResponse;
import zentry.back.api.ai.services.ContentEmbeddingsService;

import java.util.UUID;

@RestController
@RequestMapping("/api/ai/content-embeddings")
@Tag(name = "Content Embeddings", description = "Gestión de vectores de embedding para publicaciones (posts)")
public class ContentEmbeddingsController {

    private final ContentEmbeddingsService service;

    public ContentEmbeddingsController(ContentEmbeddingsService service) {
        this.service = service;
    }

    @Operation(summary = "Listar todos los embeddings de contenido",
               description = "Devuelve lista paginada de embeddings vectoriales asociados a posts.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<ContentEmbeddingsResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener embedding de contenido por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Embedding encontrado"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Embedding no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<ContentEmbeddingsResponse> getById(
            @Parameter(description = "UUID del embedding") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Crear embedding de contenido",
               description = "Registra un nuevo vector de embedding para un post. postId debe existir.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Embedding creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<ContentEmbeddingsResponse> create(
            @Valid @RequestBody ContentEmbeddingsRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar embedding de contenido")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Embedding actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Embedding no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<ContentEmbeddingsResponse> update(
            @Parameter(description = "UUID del embedding") @PathVariable UUID id,
            @Valid @RequestBody ContentEmbeddingsRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar embedding de contenido")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Embedding eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Embedding no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "UUID del embedding a eliminar") @PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
