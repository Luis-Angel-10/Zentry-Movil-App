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

import zentry.back.api.core.dtos.CommunityMemberRequest;
import zentry.back.api.core.dtos.CommunityMemberResponse;
import zentry.back.api.core.services.CommunityMemberService;

@RestController
@RequestMapping("/api/core/community-members")
@Tag(name = "Community Members", description = "Gestión de miembros de comunidad — clave compuesta (communityId + userId)")
public class CommunityMemberController {

    private final CommunityMemberService service;

    public CommunityMemberController(CommunityMemberService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Listar miembros de comunidad")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno", content = @Content)
    })
    public ResponseEntity<Page<CommunityMemberResponse>> list(@PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @GetMapping("/{communityId}/{userId}")
    @Operation(summary = "Obtener miembro de comunidad por clave compuesta",
               description = "Requiere communityId y userId para identificar el registro.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Miembro encontrado"),
        @ApiResponse(responseCode = "400", description = "IDs inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "No encontrado", content = @Content)
    })
    public ResponseEntity<CommunityMemberResponse> getById(
            @Parameter(description = "ID de la comunidad") @PathVariable Integer communityId,
            @Parameter(description = "ID del usuario miembro") @PathVariable Integer userId) {
        return ResponseEntity.ok(service.getById(communityId, userId));
    }

    @PostMapping
    @Operation(summary = "Agregar miembro a comunidad",
               description = "No puede existir ya un miembro con el mismo communityId y userId.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Miembro agregado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Miembro duplicado o datos inválidos", content = @Content)
    })
    public ResponseEntity<CommunityMemberResponse> create(@Valid @RequestBody CommunityMemberRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @DeleteMapping("/{communityId}/{userId}")
    @Operation(summary = "Eliminar miembro de comunidad")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Miembro eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "No encontrado", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID de la comunidad") @PathVariable Integer communityId,
            @Parameter(description = "ID del usuario miembro") @PathVariable Integer userId) {
        service.delete(communityId, userId);
        return ResponseEntity.noContent().build();
    }
}
