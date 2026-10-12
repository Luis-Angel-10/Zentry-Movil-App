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

import zentry.back.api.core.dtos.ForumReplyRequest;
import zentry.back.api.core.dtos.ForumReplyResponse;
import zentry.back.api.core.services.ForumReplyService;

import java.security.Principal;
import java.util.List;

@RestController
@Tag(name = "Forum Replies", description = "Gestión de respuestas en hilos de foro")
public class ForumReplyController {

    private final ForumReplyService service;

    public ForumReplyController(ForumReplyService service) {
        this.service = service;
    }

    @GetMapping("/api/core/forum-threads/{threadId}/replies")
    @Operation(summary = "Listar respuestas de un hilo", description = "Devuelve las respuestas de un hilo ordenadas cronológicamente.")
    public ResponseEntity<List<ForumReplyResponse>> listByThread(
            @Parameter(description = "ID del hilo") @PathVariable Integer threadId) {
        return ResponseEntity.ok(service.listByThread(threadId));
    }

    @PostMapping("/api/core/forum-threads/{threadId}/replies")
    @Operation(summary = "Responder en un hilo de foro")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Creada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Hilo no encontrado", content = @Content)
    })
    public ResponseEntity<ForumReplyResponse> create(
            @Parameter(description = "ID del hilo") @PathVariable Integer threadId,
            @Valid @RequestBody ForumReplyRequest request,
            Principal principal) {
        String username = requireUsername(principal);
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(threadId, username, request));
    }

    @DeleteMapping("/api/core/forum-replies/{id}")
    @Operation(summary = "Eliminar respuesta propia")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Eliminada exitosamente"),
        @ApiResponse(responseCode = "403", description = "No es el autor de la respuesta", content = @Content),
        @ApiResponse(responseCode = "404", description = "No encontrada", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID de la respuesta") @PathVariable Integer id,
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
