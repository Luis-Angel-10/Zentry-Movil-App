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
import zentry.back.api.realtime.dtos.MessageRequest;
import zentry.back.api.realtime.dtos.MessageResponse;
import zentry.back.api.realtime.service.MessageService;

import java.security.Principal;

@RestController
@RequestMapping("/api/realtime/messages")
@Tag(name = "Mensajes", description = "Gestión de mensajes enviados dentro de conversaciones en tiempo real")
public class MessageController {

    private final MessageService service;
    private final UserRepository userRepository;

    public MessageController(MessageService service, UserRepository userRepository) {
        this.service = service;
        this.userRepository = userRepository;
    }

    @org.springframework.messaging.handler.annotation.MessageMapping("/chat")
    public void processMessage(@org.springframework.messaging.handler.annotation.Payload MessageRequest request,
                                Principal principal) {
        Integer senderId = resolveUserId(principal.getName());
        service.create(request, senderId);
    }

    @GetMapping
    @Operation(summary = "Listar mensajes de una conversación",
               description = "Devuelve los mensajes de una conversación a la que pertenece el usuario autenticado, del más reciente al más antiguo.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "403", description = "No perteneces a esta conversación", content = @Content)
    })
    public ResponseEntity<Page<MessageResponse>> list(
            @Parameter(description = "ID de la conversación") @RequestParam Integer conversationId,
            @PageableDefault(size = 30, sort = "createdAt", direction = org.springframework.data.domain.Sort.Direction.DESC) Pageable pageable,
            Principal principal, Authentication authentication) {
        Integer userId = resolveUserId(extractUsername(principal, authentication));
        return ResponseEntity.ok(service.listByConversation(conversationId, userId, pageable));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener mensaje por ID",
               description = "Devuelve los datos de un mensaje específico, si el usuario pertenece a la conversación.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Mensaje encontrado"),
        @ApiResponse(responseCode = "403", description = "No perteneces a esta conversación", content = @Content),
        @ApiResponse(responseCode = "404", description = "Mensaje no encontrado", content = @Content)
    })
    public ResponseEntity<MessageResponse> getById(
            @Parameter(description = "ID del mensaje") @PathVariable Integer id,
            Principal principal, Authentication authentication) {
        Integer userId = resolveUserId(extractUsername(principal, authentication));
        return ResponseEntity.ok(service.getById(id, userId));
    }

    @PostMapping
    @Operation(summary = "Enviar mensaje",
               description = "Envía un nuevo mensaje dentro de una conversación en tiempo real, en nombre del usuario autenticado.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Mensaje enviado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content),
        @ApiResponse(responseCode = "403", description = "No perteneces a esta conversación", content = @Content)
    })
    public ResponseEntity<MessageResponse> create(
            @Valid @RequestBody MessageRequest request,
            Principal principal, Authentication authentication) {
        Integer userId = resolveUserId(extractUsername(principal, authentication));
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request, userId));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Editar mensaje",
               description = "Modifica el contenido de un mensaje existente. Solo el autor del mensaje puede editarlo.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Mensaje actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content),
        @ApiResponse(responseCode = "403", description = "No puedes modificar un mensaje de otro usuario", content = @Content),
        @ApiResponse(responseCode = "404", description = "Mensaje no encontrado", content = @Content)
    })
    public ResponseEntity<MessageResponse> update(
            @Parameter(description = "ID del mensaje") @PathVariable Integer id,
            @Valid @RequestBody MessageRequest request,
            Principal principal, Authentication authentication) {
        Integer userId = resolveUserId(extractUsername(principal, authentication));
        return ResponseEntity.ok(service.update(id, request, userId));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar mensaje",
               description = "Elimina permanentemente un mensaje por su ID. Solo el autor del mensaje puede eliminarlo.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Mensaje eliminado exitosamente"),
        @ApiResponse(responseCode = "403", description = "No puedes eliminar un mensaje de otro usuario", content = @Content),
        @ApiResponse(responseCode = "404", description = "Mensaje no encontrado", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del mensaje") @PathVariable Integer id,
            Principal principal, Authentication authentication) {
        Integer userId = resolveUserId(extractUsername(principal, authentication));
        service.delete(id, userId);
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
