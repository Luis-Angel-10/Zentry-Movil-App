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

import zentry.back.api.ai.dtos.UserEmbeddingsRequest;
import zentry.back.api.ai.dtos.UserEmbeddingsResponse;
import zentry.back.api.ai.services.UserEmbeddingsService;

@RestController
@RequestMapping("/api/ai/user-embeddings")
@Tag(name = "User Embeddings", description = "Vectores de embedding para perfiles de usuario")
public class UserEmbeddingsController {

    private final UserEmbeddingsService service;

    public UserEmbeddingsController(UserEmbeddingsService service) {
        this.service = service;
    }

    @Operation(summary = "Listar embeddings de usuarios",
               description = "Devuelve lista paginada de embeddings vectoriales de perfiles de usuario.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<UserEmbeddingsResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener embedding de usuario por userId",
               description = "Busca el embedding del usuario por su ID entero (no UUID).")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Embedding encontrado"),
        @ApiResponse(responseCode = "400", description = "userId debe ser un entero positivo", content = @Content),
        @ApiResponse(responseCode = "404", description = "Embedding no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{userId}")
    public ResponseEntity<UserEmbeddingsResponse> getById(
            @Parameter(description = "ID entero del usuario") @PathVariable Integer userId) {
        return ResponseEntity.ok(service.getById(userId));
    }

    @Operation(summary = "Crear embedding de usuario",
               description = "Registra el vector de embedding de un usuario. Solo puede existir uno por userId.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Embedding creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Embedding ya existe para ese userId u otros datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<UserEmbeddingsResponse> create(
            @Valid @RequestBody UserEmbeddingsRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar embedding de usuario",
               description = "Actualiza el vector de embedding para un userId existente.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Embedding actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Embedding no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{userId}")
    public ResponseEntity<UserEmbeddingsResponse> update(
            @Parameter(description = "ID entero del usuario") @PathVariable Integer userId,
            @Valid @RequestBody UserEmbeddingsRequest request) {
        return ResponseEntity.ok(service.update(userId, request));
    }

    @Operation(summary = "Eliminar embedding de usuario")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Embedding eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Embedding no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{userId}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID entero del usuario") @PathVariable Integer userId) {
        service.delete(userId);
        return ResponseEntity.noContent().build();
    }
}
