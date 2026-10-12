package zentry.back.api.core.controllers;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zentry.back.api.core.dtos.FriendUserResponse;
import zentry.back.api.core.dtos.SendFriendRequestDTO;
import zentry.back.api.core.services.FriendsService;

import java.security.Principal;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping({"/api/core/friends", "/api/v1/friends"})
@Tag(name = "Friends & Social Network", description = "Gestión de amigos, solicitudes de amistad y presencia en línea en tiempo real")
public class FriendsController {

    private final FriendsService service;

    public FriendsController(FriendsService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Obtener lista de amigos del usuario autenticado")
    public ResponseEntity<List<FriendUserResponse>> getFriends(
            @RequestParam(required = false, defaultValue = "false") boolean onlineOnly,
            Principal principal) {
        String username = principal != null ? principal.getName() : "anonimo";
        return ResponseEntity.ok(service.getFriends(username, onlineOnly));
    }

    @GetMapping("/online")
    @Operation(summary = "Obtener amigos conectados en línea en tiempo real")
    public ResponseEntity<List<FriendUserResponse>> getOnlineFriends(Principal principal) {
        String username = principal != null ? principal.getName() : "anonimo";
        return ResponseEntity.ok(service.getFriends(username, true));
    }

    @GetMapping("/requests/pending")
    @Operation(summary = "Obtener solicitudes de amistad recibidas pendientes")
    public ResponseEntity<List<FriendUserResponse>> getPendingRequests(Principal principal) {
        String username = principal != null ? principal.getName() : "anonimo";
        return ResponseEntity.ok(service.getPendingRequests(username));
    }

    @GetMapping("/suggestions")
    @Operation(summary = "Personas que quizás conozcas", description = "Usuarios reales sin amistad ni solicitud pendiente con el usuario autenticado.")
    public ResponseEntity<List<FriendUserResponse>> getSuggestions(
            @RequestParam(required = false, defaultValue = "12") int limit,
            Principal principal) {
        String username = principal != null ? principal.getName() : "anonimo";
        return ResponseEntity.ok(service.getSuggestions(username, limit));
    }

    @GetMapping("/requests/sent")
    @Operation(summary = "Obtener solicitudes de amistad enviadas y aún pendientes de respuesta")
    public ResponseEntity<List<FriendUserResponse>> getSentRequests(Principal principal) {
        String username = principal != null ? principal.getName() : "anonimo";
        return ResponseEntity.ok(service.getSentRequests(username));
    }

    @PostMapping("/requests/send")
    @Operation(summary = "Enviar solicitud de amistad o colaboración")
    public ResponseEntity<Map<String, Object>> sendRequest(
            @Valid @RequestBody SendFriendRequestDTO dto,
            Principal principal) {
        String username = principal != null ? principal.getName() : "anonimo";
        return ResponseEntity.ok(service.sendRequest(username, dto));
    }

    @PostMapping("/requests/{id}/accept")
    @Operation(summary = "Aceptar solicitud de amistad")
    public ResponseEntity<Map<String, Object>> acceptRequest(
            @PathVariable Integer id,
            Principal principal) {
        String username = principal != null ? principal.getName() : "anonimo";
        return ResponseEntity.ok(service.acceptRequest(id, username));
    }

    @PostMapping("/requests/{id}/reject")
    @Operation(summary = "Rechazar o ignorar solicitud de amistad")
    public ResponseEntity<Map<String, Object>> rejectRequest(
            @PathVariable Integer id,
            Principal principal) {
        String username = principal != null ? principal.getName() : "anonimo";
        return ResponseEntity.ok(service.rejectRequest(id, username));
    }

    @DeleteMapping("/{friendId}")
    @Operation(summary = "Eliminar amigo de la red")
    public ResponseEntity<Map<String, Object>> removeFriend(
            @PathVariable Integer friendId,
            Principal principal) {
        String username = principal != null ? principal.getName() : "anonimo";
        return ResponseEntity.ok(service.removeFriend(friendId, username));
    }

    @PostMapping("/presence/ping")
    @Operation(summary = "Actualizar estado de presencia en línea del usuario")
    public ResponseEntity<Map<String, Object>> updatePresence(
            @RequestParam(required = false, defaultValue = "online") String status,
            Principal principal) {
        String username = principal != null ? principal.getName() : "anonimo";
        return ResponseEntity.ok(service.updatePresence(username, status));
    }

    @GetMapping("/stats")
    @Operation(summary = "Obtener estadísticas sociales del usuario (obras, seguidores, seguidos, monedas)")
    public ResponseEntity<zentry.back.api.core.dtos.UserStatsResponse> getStats(Principal principal) {
        String username = principal != null ? principal.getName() : "anonimo";
        return ResponseEntity.ok(service.getUserStats(username));
    }
}
