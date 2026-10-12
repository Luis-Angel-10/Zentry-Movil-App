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
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.ForumThreadRequest;
import zentry.back.api.core.dtos.ForumThreadResponse;
import zentry.back.api.core.services.ForumThreadService;

import java.security.Principal;

@RestController
@RequestMapping("/api/core/forum-threads")
@Tag(name = "Forum Threads", description = "Gestión de hilos de foro dentro de una comunidad")
public class ForumThreadController {

    private final ForumThreadService service;

    public ForumThreadController(ForumThreadService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Listar hilos de foro de una comunidad", description = "Devuelve los hilos de una comunidad ordenados por actividad reciente.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno", content = @Content)
    })
    public ResponseEntity<Page<ForumThreadResponse>> listByCommunity(
            @RequestParam Integer communityId,
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.listByCommunity(communityId, pageable));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener hilo de foro por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Hilo encontrado"),
        @ApiResponse(responseCode = "404", description = "No encontrado", content = @Content)
    })
    public ResponseEntity<ForumThreadResponse> getById(
            @Parameter(description = "ID del hilo") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @PostMapping
    @Operation(summary = "Crear hilo de foro", description = "Abre un nuevo hilo de discusión en una comunidad.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Comunidad no encontrada", content = @Content)
    })
    public ResponseEntity<ForumThreadResponse> create(@Valid @RequestBody ForumThreadRequest request, Principal principal) {
        String username = requireUsername(principal);
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(username, request));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar hilo de foro propio")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Eliminado exitosamente"),
        @ApiResponse(responseCode = "403", description = "No es el autor del hilo", content = @Content),
        @ApiResponse(responseCode = "404", description = "No encontrado", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del hilo") @PathVariable Integer id,
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
