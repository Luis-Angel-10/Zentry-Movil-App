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

import zentry.back.api.ai.dtos.CommunityEmbeddingsRequest;
import zentry.back.api.ai.dtos.CommunityEmbeddingsResponse;
import zentry.back.api.ai.services.CommunityEmbeddingsService;

import java.util.UUID;

@RestController
@RequestMapping("/api/ai/community-embeddings")
@Tag(name = "Community Embeddings", description = "Gestión de vectores de embedding para comunidades")
public class CommunityEmbeddingsController {

    private final CommunityEmbeddingsService service;

    public CommunityEmbeddingsController(CommunityEmbeddingsService service) {
        this.service = service;
    }

    @Operation(summary = "Listar todos los embeddings de comunidades",
               description = "Devuelve lista paginada de embeddings vectoriales asociados a comunidades.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<CommunityEmbeddingsResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener embedding de comunidad por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Embedding encontrado"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Embedding no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<CommunityEmbeddingsResponse> getById(
            @Parameter(description = "UUID del embedding") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Crear embedding de comunidad",
               description = "Registra un nuevo vector de embedding para una comunidad. communityId debe existir.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Embedding creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<CommunityEmbeddingsResponse> create(
            @Valid @RequestBody CommunityEmbeddingsRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar embedding de comunidad")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Embedding actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Embedding no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<CommunityEmbeddingsResponse> update(
            @Parameter(description = "UUID del embedding") @PathVariable UUID id,
            @Valid @RequestBody CommunityEmbeddingsRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar embedding de comunidad")
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
