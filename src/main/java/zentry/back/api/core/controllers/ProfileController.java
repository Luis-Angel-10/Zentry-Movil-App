package zentry.back.api.core.controllers;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;

import java.security.Principal;
import java.util.List;
import java.util.Map;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import zentry.back.api.core.dtos.ProfileRequest;
import zentry.back.api.core.dtos.ProfileResponse;
import zentry.back.api.core.services.ProfileService;

@RestController
@RequestMapping({"/api/core/profiles", "/api/v1/profiles"})
@Tag(name = "Profiles", description = "Gestión de perfiles de usuario")
public class ProfileController {

    private final ProfileService service;

    public ProfileController(ProfileService service) {
        this.service = service;
    }
    
    @GetMapping("/search")
    @Operation(summary = "Buscar perfiles por nombre")
    public ResponseEntity<List<ProfileResponse>> searchProfiles(@RequestParam("q") String query) {
        return ResponseEntity.ok(service.searchProfiles(query));
    }

    @GetMapping("/me")
    @Operation(summary = "Obtener mi propio perfil (usuario autenticado)")
    public ResponseEntity<ProfileResponse> getMyProfile(Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(service.getProfileByUsername(principal.getName(), principal.getName()));
    }

    @GetMapping("/by-user-id/{userId}")
    @Operation(summary = "Obtener perfil por ID numérico de usuario",
               description = "Lectura pública de perfil a partir del ID interno del usuario (útil para resolver participantes de una conversación).")
    public ResponseEntity<ProfileResponse> getProfileByUserId(
            @PathVariable Integer userId,
            Principal principal) {
        String currentUsername = principal != null ? principal.getName() : null;
        ProfileResponse profile = service.getProfileByUserId(userId, currentUsername);
        return ResponseEntity.ok(profile);
    }

    @GetMapping("/{identifier}")
    @Operation(summary = "Obtener perfil por identificador (username o email)",
               description = "Lectura pública de perfil. Retorna la información del creador y booleano isFollowing si el cliente está autenticado.")
    public ResponseEntity<ProfileResponse> getProfile(
            @PathVariable String identifier,
            Principal principal) {
        String currentUsername = principal != null ? principal.getName() : null;
        ProfileResponse profile = service.getProfileByUsername(identifier, currentUsername);
        if (profile == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(profile);
    }

    // 1. JSON
    @RequestMapping(
        value = {"/me", "/onboarding"}, 
        method = {RequestMethod.PUT, RequestMethod.POST}, 
        consumes = MediaType.APPLICATION_JSON_VALUE
    )
    @Operation(summary = "Actualizar mi propio perfil o hacer onboarding vía JSON (Solo el usuario autenticado)")
    public ResponseEntity<ProfileResponse> updateJson(
            @RequestBody ProfileRequest request,
            Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(service.updateMyProfile(principal.getName(), request));
    }

    // 2. MULTIPART (Archivos + Formulario) permitiendo tanto PUT como POST
    @RequestMapping(
        value = "/me", 
        method = { RequestMethod.PUT, RequestMethod.POST }, 
        consumes = { MediaType.MULTIPART_FORM_DATA_VALUE, MediaType.APPLICATION_FORM_URLENCODED_VALUE }
    )
    @Operation(summary = "Actualizar mi propio perfil vía Multipart/FormData (Solo el usuario autenticado)")
    public ResponseEntity<ProfileResponse> updateMultipart(
            @ModelAttribute ProfileRequest request,
            Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(service.updateMyProfile(principal.getName(), request));
    }

    @PostMapping("/{identifier}/follow")
    @Operation(summary = "Seguir o dejar de seguir a otro creador",
               description = "Acción social que requiere autenticación. Alterna el estado de seguimiento.")
    public ResponseEntity<?> toggleFollow(
            @PathVariable String identifier,
            Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Debes iniciar sesión"));
        }

        String currentUsername = principal.getName();
        if (currentUsername.equalsIgnoreCase(identifier)) {
            return ResponseEntity.badRequest().body(Map.of("error", "No puedes seguirte a ti mismo"));
        }

        ProfileService.FollowResult result = service.toggleFollowUser(currentUsername, identifier);
        return ResponseEntity.ok(Map.of(
            "following", result.isFollowing(),
            "isFollowing", result.isFollowing(),
            "followersCount", result.getFollowersCount(),
            "message", result.isFollowing() ? "Siguiendo exitosamente" : "Has dejado de seguir"
        ));
    }
}

