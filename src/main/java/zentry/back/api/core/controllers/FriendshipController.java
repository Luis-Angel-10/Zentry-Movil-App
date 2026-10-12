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

import zentry.back.api.core.dtos.FriendshipRequest;
import zentry.back.api.core.dtos.FriendshipResponse;
import zentry.back.api.core.services.FriendshipService;

@RestController
@RequestMapping("/api/core/friendships")
@Tag(name = "Friendships", description = "Gestión de amistades entre usuarios — clave compuesta (user1 + user2)")
public class FriendshipController {

    private final FriendshipService service;

    public FriendshipController(FriendshipService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Listar amistades")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno", content = @Content)
    })
    public ResponseEntity<Page<FriendshipResponse>> list(@PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @GetMapping("/{user1}/{user2}")
    @Operation(summary = "Obtener amistad por clave compuesta",
               description = "Requiere user1 y user2 para identificar el registro.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Amistad encontrada"),
        @ApiResponse(responseCode = "400", description = "IDs inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "No encontrada", content = @Content)
    })
    public ResponseEntity<FriendshipResponse> getById(
            @Parameter(description = "ID del primer usuario") @PathVariable Integer user1,
            @Parameter(description = "ID del segundo usuario") @PathVariable Integer user2) {
        return ResponseEntity.ok(service.getById(user1, user2));
    }

    @PostMapping
    @Operation(summary = "Crear amistad entre usuarios",
               description = "No puede existir ya una amistad con el mismo par de usuarios.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Amistad creada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Amistad duplicada o datos inválidos", content = @Content)
    })
    public ResponseEntity<FriendshipResponse> create(@Valid @RequestBody FriendshipRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @DeleteMapping("/{user1}/{user2}")
    @Operation(summary = "Eliminar amistad entre usuarios")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Amistad eliminada exitosamente"),
        @ApiResponse(responseCode = "404", description = "No encontrada", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del primer usuario") @PathVariable Integer user1,
            @Parameter(description = "ID del segundo usuario") @PathVariable Integer user2) {
        service.delete(user1, user2);
        return ResponseEntity.noContent().build();
    }
}
