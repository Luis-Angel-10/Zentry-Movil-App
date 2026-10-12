package zentry.back.api.core.controllers;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import jakarta.validation.Valid;
import zentry.back.api.core.dtos.StoryGroupResponse;
import zentry.back.api.core.dtos.StoryReplyRequest;
import zentry.back.api.core.dtos.StoryRequest;
import zentry.back.api.core.dtos.StoryResponse;
import zentry.back.api.core.models.User;
import zentry.back.api.core.repositories.UserRepository;
import zentry.back.api.core.services.StoryService;

import java.security.Principal;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping({"/api/core/stories", "/api/v1/stories"})
@Tag(name = "Stories", description = "Gestión de Historias estilo Instagram (ciclo de 24h, vistas, likes y contenido interactivo)")
public class StoryController {

    private final StoryService service;
    private final UserRepository userRepo;

    public StoryController(StoryService service, UserRepository userRepo) {
        this.service = service;
        this.userRepo = userRepo;
    }

    @GetMapping("/feed")
    @Operation(summary = "Obtener el feed de historias activas agrupadas por usuario (Estilo Instagram)")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Feed de historias obtenido correctamente")
    })
    public ResponseEntity<List<StoryGroupResponse>> getFeed(Principal principal) {
        Integer currentUserId = resolveUserId(principal);
        return ResponseEntity.ok(service.getActiveFeed(currentUserId));
    }

    @GetMapping("/user/{userId}")
    @Operation(summary = "Obtener las historias activas de un usuario específico")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Historias del usuario obtenidas correctamente")
    })
    public ResponseEntity<List<StoryResponse>> getUserStories(
            @PathVariable Integer userId,
            Principal principal) {
        Integer currentUserId = resolveUserId(principal);
        return ResponseEntity.ok(service.getUserStories(userId, currentUserId));
    }

    @PostMapping(consumes = {MediaType.MULTIPART_FORM_DATA_VALUE})
    @Operation(summary = "Publicar una nueva historia (con archivo multimedia)")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Historia creada exitosamente")
    })
    public ResponseEntity<StoryResponse> createStoryMultipart(
            @RequestPart("story") StoryRequest request,
            @RequestPart(value = "file", required = false) MultipartFile file,
            Principal principal) {
        Integer currentUserId = resolveUserId(principal);
        StoryResponse created = service.createStory(request, file, currentUserId);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PostMapping(consumes = {MediaType.APPLICATION_JSON_VALUE})
    @Operation(summary = "Publicar una nueva historia (formato JSON / Modo Texto o URL multimedia)")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Historia creada exitosamente")
    })
    public ResponseEntity<StoryResponse> createStoryJson(
            @RequestBody StoryRequest request,
            Principal principal) {
        Integer currentUserId = resolveUserId(principal);
        StoryResponse created = service.createStory(request, null, currentUserId);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @PostMapping("/{id}/view")
    @Operation(summary = "Registrar la visualización de una historia")
    public ResponseEntity<?> viewStory(
            @PathVariable Integer id,
            Principal principal) {
        Integer currentUserId = resolveUserId(principal);
        boolean isNewView = service.viewStory(id, currentUserId);
        return ResponseEntity.ok(Map.of("success", true, "new_view", isNewView));
    }

    @PostMapping("/{id}/like")
    @Operation(summary = "Dar o quitar me gusta (toggle) a una historia")
    public ResponseEntity<?> toggleLike(
            @PathVariable Integer id,
            Principal principal) {
        Integer currentUserId = resolveUserId(principal);
        boolean isLiked = service.toggleLike(id, currentUserId);
        return ResponseEntity.ok(Map.of("success", true, "is_liked", isLiked));
    }

    @PostMapping("/{id}/reply")
    @Operation(summary = "Responder a una historia", description = "Envía un mensaje directo real al dueño de la historia, igual que un DM de respuesta en Instagram.")
    public ResponseEntity<?> replyToStory(
            @PathVariable Integer id,
            @Valid @RequestBody StoryReplyRequest request,
            Principal principal) {
        Integer currentUserId = resolveUserId(principal);
        service.replyToStory(id, currentUserId, request);
        return ResponseEntity.ok(Map.of("success", true));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Archivar o eliminar una historia")
    public ResponseEntity<?> deleteStory(
            @PathVariable Integer id,
            Principal principal) {
        Integer currentUserId = resolveUserId(principal);
        service.deleteStory(id, currentUserId);
        return ResponseEntity.noContent().build();
    }

    private Integer resolveUserId(Principal principal) {
        if (principal != null && principal.getName() != null) {
            String name = principal.getName();
            return userRepo.findByUsername(name)
                    .or(() -> userRepo.findByEmail(name))
                    .map(User::getId)
                    .orElse(null);
        }
        return null;
    }
}
