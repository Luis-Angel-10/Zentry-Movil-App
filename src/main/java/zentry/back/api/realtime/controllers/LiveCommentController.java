package zentry.back.api.realtime.controllers;

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

import zentry.back.api.realtime.dtos.LiveCommentRequest;
import zentry.back.api.realtime.dtos.LiveCommentResponse;
import zentry.back.api.realtime.service.LiveCommentService;

@RestController
@RequestMapping("/api/realtime/live-comments")
@Tag(name = "Comentarios en Vivo", description = "Gestión de comentarios en tiempo real durante transmisiones o eventos en vivo")
public class LiveCommentController {

    private final LiveCommentService service;

    public LiveCommentController(LiveCommentService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Listar comentarios en vivo",
               description = "Devuelve una lista paginada de todos los comentarios realizados en eventos en vivo.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    public ResponseEntity<Page<LiveCommentResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener comentario en vivo por ID",
               description = "Devuelve los datos de un comentario en vivo específico.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Comentario encontrado"),
        @ApiResponse(responseCode = "404", description = "Comentario no encontrado", content = @Content)
    })
    public ResponseEntity<LiveCommentResponse> getById(
            @Parameter(description = "ID del comentario en vivo") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @PostMapping
    @Operation(summary = "Publicar comentario en vivo",
               description = "Publica un nuevo comentario en tiempo real asociado a un evento en vivo.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Comentario publicado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content)
    })
    public ResponseEntity<LiveCommentResponse> create(
            @Valid @RequestBody LiveCommentRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Editar comentario en vivo",
               description = "Modifica el contenido de un comentario en vivo existente.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Comentario actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content),
        @ApiResponse(responseCode = "404", description = "Comentario no encontrado", content = @Content)
    })
    public ResponseEntity<LiveCommentResponse> update(
            @Parameter(description = "ID del comentario en vivo") @PathVariable Integer id,
            @Valid @RequestBody LiveCommentRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar comentario en vivo",
               description = "Elimina permanentemente un comentario en vivo por su ID.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Comentario eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Comentario no encontrado", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del comentario en vivo") @PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
