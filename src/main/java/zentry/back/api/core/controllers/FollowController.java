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

import zentry.back.api.core.dtos.FollowRequest;
import zentry.back.api.core.dtos.FollowResponse;
import zentry.back.api.core.services.FollowService;

@RestController
@RequestMapping("/api/core/follows")
@Tag(name = "Follows", description = "Gestión de seguimientos entre usuarios — clave compuesta (follower + following)")
public class FollowController {

    private final FollowService service;

    public FollowController(FollowService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Listar seguimientos")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno", content = @Content)
    })
    public ResponseEntity<Page<FollowResponse>> list(@PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @GetMapping("/followers/{username}")
    @Operation(summary = "Obtener lista de seguidores de un usuario", description = "Retorna una lista de perfiles que siguen al usuario.")
    public ResponseEntity<java.util.List<zentry.back.api.core.dtos.ProfileResponse>> getFollowers(
            @Parameter(description = "Username del usuario") @PathVariable String username) {
        return ResponseEntity.ok(service.getFollowers(username));
    }

    @GetMapping("/following/{username}")
    @Operation(summary = "Obtener lista de usuarios seguidos por un usuario", description = "Retorna una lista de perfiles a los que el usuario sigue.")
    public ResponseEntity<java.util.List<zentry.back.api.core.dtos.ProfileResponse>> getFollowing(
            @Parameter(description = "Username del usuario") @PathVariable String username) {
        return ResponseEntity.ok(service.getFollowing(username));
    }

    @GetMapping("/{follower}/{following}")
    @Operation(summary = "Obtener seguimiento por clave compuesta",
               description = "Requiere follower y following para identificar el registro.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Seguimiento encontrado"),
        @ApiResponse(responseCode = "400", description = "IDs inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "No encontrado", content = @Content)
    })
    public ResponseEntity<FollowResponse> getById(
            @Parameter(description = "ID del usuario seguidor") @PathVariable Integer follower,
            @Parameter(description = "ID del usuario seguido") @PathVariable Integer following) {
        return ResponseEntity.ok(service.getById(follower, following));
    }

    @PostMapping
    @Operation(summary = "Crear seguimiento entre usuarios",
               description = "No puede existir ya un seguimiento con el mismo follower y following.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Seguimiento creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Seguimiento duplicado o datos inválidos", content = @Content)
    })
    public ResponseEntity<FollowResponse> create(@Valid @RequestBody FollowRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @DeleteMapping("/{follower}/{following}")
    @Operation(summary = "Eliminar seguimiento entre usuarios")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Seguimiento eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "No encontrado", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del usuario seguidor") @PathVariable Integer follower,
            @Parameter(description = "ID del usuario seguido") @PathVariable Integer following) {
        service.delete(follower, following);
        return ResponseEntity.noContent().build();
    }
}
