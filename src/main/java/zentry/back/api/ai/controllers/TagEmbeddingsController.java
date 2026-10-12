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

import zentry.back.api.ai.dtos.TagEmbeddingsRequest;
import zentry.back.api.ai.dtos.TagEmbeddingsResponse;
import zentry.back.api.ai.services.TagEmbeddingsService;

import java.util.UUID;

@RestController
@RequestMapping("/api/ai/tag-embeddings")
@Tag(name = "Tag Embeddings", description = "Vectores de embedding para etiquetas/tags del sistema")
public class TagEmbeddingsController {

    private final TagEmbeddingsService service;

    public TagEmbeddingsController(TagEmbeddingsService service) {
        this.service = service;
    }

    @Operation(summary = "Listar embeddings de tags",
               description = "Devuelve lista paginada de vectores de embedding para tags.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<TagEmbeddingsResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener embedding de tag por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Embedding encontrado"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Embedding no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<TagEmbeddingsResponse> getById(
            @Parameter(description = "UUID del embedding de tag") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Crear embedding de tag",
               description = "Registra un nuevo vector de embedding para un tag. tagId debe ser positivo.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Embedding creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<TagEmbeddingsResponse> create(
            @Valid @RequestBody TagEmbeddingsRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar embedding de tag")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Embedding actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Embedding no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<TagEmbeddingsResponse> update(
            @Parameter(description = "UUID del embedding") @PathVariable UUID id,
            @Valid @RequestBody TagEmbeddingsRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar embedding de tag")
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
