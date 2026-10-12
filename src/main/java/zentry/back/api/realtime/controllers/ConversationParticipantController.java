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
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.models.User;
import zentry.back.api.core.repositories.UserRepository;
import zentry.back.api.realtime.dtos.ConversationParticipantRequest;
import zentry.back.api.realtime.dtos.ConversationParticipantResponse;
import zentry.back.api.realtime.service.ConversationParticipantService;

import java.security.Principal;

@RestController
@RequestMapping("/api/realtime/conversation-participants")
@Tag(name = "Participantes de Conversación", description = "Gestión de miembros dentro de conversaciones grupales")
public class ConversationParticipantController {

    private final ConversationParticipantService service;
    private final UserRepository userRepository;

    public ConversationParticipantController(ConversationParticipantService service, UserRepository userRepository) {
        this.service = service;
        this.userRepository = userRepository;
    }

    @GetMapping
    @Operation(summary = "Listar participantes de una conversación",
               description = "Devuelve los participantes de una conversación a la que pertenece el usuario autenticado.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "403", description = "No perteneces a esta conversación", content = @Content)
    })
    public ResponseEntity<Page<ConversationParticipantResponse>> list(
            @Parameter(description = "ID de la conversación") @RequestParam Integer conversationId,
            @PageableDefault(size = 20) Pageable pageable,
            Principal principal, Authentication authentication) {
        Integer requesterId = resolveUserId(extractUsername(principal, authentication));
        return ResponseEntity.ok(service.listByConversation(conversationId, requesterId, pageable));
    }

    @GetMapping("/{conversationId}/{userId}")
    @Operation(summary = "Obtener participante por clave compuesta",
               description = "Requiere pertenecer a la conversación para consultar a un participante.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Participante encontrado"),
        @ApiResponse(responseCode = "403", description = "No perteneces a esta conversación", content = @Content),
        @ApiResponse(responseCode = "404", description = "Participante no encontrado", content = @Content)
    })
    public ResponseEntity<ConversationParticipantResponse> getById(
            @Parameter(description = "ID de la conversación") @PathVariable Integer conversationId,
            @Parameter(description = "ID del usuario participante") @PathVariable Integer userId,
            Principal principal, Authentication authentication) {
        Integer requesterId = resolveUserId(extractUsername(principal, authentication));
        return ResponseEntity.ok(service.getById(conversationId, userId, requesterId));
    }

    @PostMapping
    @Operation(summary = "Agregar participante a un grupo",
               description = "Agrega un usuario a una conversación grupal. Requiere pertenecer al grupo; no aplica a conversaciones directas.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Participante agregado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Participante ya existente, conversación directa o datos inválidos", content = @Content),
        @ApiResponse(responseCode = "403", description = "No perteneces a esta conversación", content = @Content)
    })
    public ResponseEntity<ConversationParticipantResponse> create(
            @Valid @RequestBody ConversationParticipantRequest request,
            Principal principal, Authentication authentication) {
        Integer requesterId = resolveUserId(extractUsername(principal, authentication));
        return ResponseEntity.status(HttpStatus.CREATED).body(service.addParticipant(request, requesterId));
    }

    @DeleteMapping("/{conversationId}/{userId}")
    @Operation(summary = "Quitar participante o abandonar conversación",
               description = "Un usuario puede quitarse a sí mismo (abandonar). Solo un administrador puede quitar a otros.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Participante eliminado exitosamente"),
        @ApiResponse(responseCode = "403", description = "No autorizado para quitar a este participante", content = @Content),
        @ApiResponse(responseCode = "404", description = "Participante no encontrado", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID de la conversación") @PathVariable Integer conversationId,
            @Parameter(description = "ID del usuario participante") @PathVariable Integer userId,
            Principal principal, Authentication authentication) {
        Integer requesterId = resolveUserId(extractUsername(principal, authentication));
        service.removeParticipant(conversationId, userId, requesterId);
        return ResponseEntity.noContent().build();
    }

    private String extractUsername(Principal principal, Authentication authentication) {
        if (principal != null) {
            return principal.getName();
        }
        if (authentication != null) {
            return authentication.getName();
        }
        throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Debes iniciar sesión");
    }

    private Integer resolveUserId(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Usuario no encontrado"));
        return user.getId();
    }
}
