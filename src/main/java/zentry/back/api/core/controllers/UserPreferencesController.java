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

import zentry.back.api.core.dtos.UserPreferencesRequest;
import zentry.back.api.core.dtos.UserPreferencesResponse;
import zentry.back.api.core.services.UserPreferencesService;

@RestController
@RequestMapping("/api/core/user-preferences")
@Tag(name = "User Preferences", description = "Gestión de preferencias de usuario — PK = userId (singleton)")
public class UserPreferencesController {

    private final UserPreferencesService service;

    public UserPreferencesController(UserPreferencesService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Listar preferencias de usuarios")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno", content = @Content)
    })
    public ResponseEntity<Page<UserPreferencesResponse>> list(@PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @GetMapping("/{userId}")
    @Operation(summary = "Obtener preferencias de usuario por userId")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Preferencias encontradas"),
        @ApiResponse(responseCode = "404", description = "No encontradas", content = @Content)
    })
    public ResponseEntity<UserPreferencesResponse> getById(
            @Parameter(description = "ID del usuario") @PathVariable Integer userId) {
        return ResponseEntity.ok(service.getById(userId));
    }

    @PostMapping
    @Operation(summary = "Crear preferencias de usuario",
               description = "Solo puede existir un registro por userId.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Creadas exitosamente"),
        @ApiResponse(responseCode = "400", description = "Preferencias ya existentes o datos inválidos", content = @Content)
    })
    public ResponseEntity<UserPreferencesResponse> create(@Valid @RequestBody UserPreferencesRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @PutMapping("/{userId}")
    @Operation(summary = "Actualizar preferencias de usuario")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Actualizadas exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "No encontradas", content = @Content)
    })
    public ResponseEntity<UserPreferencesResponse> update(
            @Parameter(description = "ID del usuario") @PathVariable Integer userId,
            @Valid @RequestBody UserPreferencesRequest request) {
        return ResponseEntity.ok(service.update(userId, request));
    }

    @DeleteMapping("/{userId}")
    @Operation(summary = "Eliminar preferencias de usuario")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Eliminadas exitosamente"),
        @ApiResponse(responseCode = "404", description = "No encontradas", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del usuario") @PathVariable Integer userId) {
        service.delete(userId);
        return ResponseEntity.noContent().build();
    }
}
