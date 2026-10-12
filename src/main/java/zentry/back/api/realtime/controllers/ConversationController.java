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
import zentry.back.api.realtime.dtos.ConversationResponse;
import zentry.back.api.realtime.dtos.ConversationSummaryResponse;
import zentry.back.api.realtime.dtos.GroupConversationRequest;
import zentry.back.api.realtime.service.ConversationService;

import java.security.Principal;
import java.util.Map;

@RestController
@RequestMapping("/api/realtime/conversations")
@Tag(name = "Conversaciones", description = "Gestión de conversaciones directas y grupales entre usuarios")
public class ConversationController {

    private final ConversationService service;
    private final UserRepository userRepository;

    public ConversationController(ConversationService service, UserRepository userRepository) {
        this.service = service;
        this.userRepository = userRepository;
    }

    @GetMapping("/mine")
    @Operation(summary = "Listar mis conversaciones",
               description = "Devuelve la bandeja de entrada del usuario autenticado: último mensaje y no leídos por conversación, ordenada por actividad reciente.")
    @ApiResponses({ @ApiResponse(responseCode = "200", description = "Bandeja obtenida exitosamente") })
    public ResponseEntity<Page<ConversationSummaryResponse>> listMine(
            @PageableDefault(size = 20) Pageable pageable,
            Principal principal, Authentication authentication) {
        Integer userId = resolveUserId(extractUsername(principal, authentication));
        return ResponseEntity.ok(service.listMine(userId, pageable));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener conversación por ID",
               description = "Devuelve los datos de una conversación, si el usuario autenticado pertenece a ella.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Conversación encontrada"),
        @ApiResponse(responseCode = "403", description = "No perteneces a esta conversación", content = @Content),
        @ApiResponse(responseCode = "404", description = "Conversación no encontrada", content = @Content)
    })
    public ResponseEntity<ConversationResponse> getById(
            @Parameter(description = "ID de la conversación") @PathVariable Integer id,
            Principal principal, Authentication authentication) {
        Integer userId = resolveUserId(extractUsername(principal, authentication));
        return ResponseEntity.ok(service.getById(id, userId));
    }

    @PostMapping("/direct/{otherUserId}")
    @Operation(summary = "Iniciar o reanudar conversación directa",
               description = "Devuelve la conversación 1 a 1 existente con ese usuario, o crea una nueva si no existe.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Conversación obtenida o creada exitosamente"),
        @ApiResponse(responseCode = "404", description = "Usuario destino no encontrado", content = @Content)
    })
    public ResponseEntity<ConversationResponse> startDirect(
            @Parameter(description = "ID del otro usuario") @PathVariable Integer otherUserId,
            Principal principal, Authentication authentication) {
        Integer userId = resolveUserId(extractUsername(principal, authentication));
        return ResponseEntity.status(HttpStatus.CREATED).body(service.startDirect(userId, otherUserId));
    }

    @PostMapping("/group")
    @Operation(summary = "Crear conversación grupal",
               description = "Crea un grupo con el usuario autenticado como administrador y los participantes indicados como miembros.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Grupo creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content)
    })
    public ResponseEntity<ConversationResponse> createGroup(
            @Valid @RequestBody GroupConversationRequest request,
            Principal principal, Authentication authentication) {
        Integer userId = resolveUserId(extractUsername(principal, authentication));
        return ResponseEntity.status(HttpStatus.CREATED).body(service.createGroup(userId, request));
    }

    @PutMapping("/{id}/name")
    @Operation(summary = "Renombrar grupo",
               description = "Cambia el nombre de una conversación grupal. Solo un administrador del grupo puede hacerlo.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Grupo renombrado exitosamente"),
        @ApiResponse(responseCode = "403", description = "No eres administrador del grupo", content = @Content)
    })
    public ResponseEntity<ConversationResponse> renameGroup(
            @PathVariable Integer id,
            @RequestBody Map<String, String> body,
            Principal principal, Authentication authentication) {
        Integer userId = resolveUserId(extractUsername(principal, authentication));
        return ResponseEntity.ok(service.renameGroup(id, userId, body.get("name")));
    }

    @PostMapping("/{id}/read")
    @Operation(summary = "Marcar conversación como leída",
               description = "Actualiza la marca de lectura del usuario autenticado para esta conversación.")
    @ApiResponses({ @ApiResponse(responseCode = "204", description = "Marcado como leído") })
    public ResponseEntity<Void> markRead(
            @PathVariable Integer id,
            Principal principal, Authentication authentication) {
        Integer userId = resolveUserId(extractUsername(principal, authentication));
        service.markRead(id, userId);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar grupo",
               description = "Elimina permanentemente un grupo y sus mensajes. Solo un administrador puede hacerlo. Para conversaciones directas, usa el endpoint de participantes para abandonarla.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Grupo eliminado exitosamente"),
        @ApiResponse(responseCode = "403", description = "No eres administrador del grupo", content = @Content),
        @ApiResponse(responseCode = "404", description = "Conversación no encontrada", content = @Content)
    })
    public ResponseEntity<Void> deleteGroup(
            @Parameter(description = "ID de la conversación") @PathVariable Integer id,
            Principal principal, Authentication authentication) {
        Integer userId = resolveUserId(extractUsername(principal, authentication));
        service.deleteGroup(id, userId);
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
