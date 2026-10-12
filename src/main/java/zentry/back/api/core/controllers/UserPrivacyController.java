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

import zentry.back.api.core.dtos.UserPrivacyRequest;
import zentry.back.api.core.dtos.UserPrivacyResponse;
import zentry.back.api.core.services.UserPrivacyService;

@RestController
@RequestMapping("/api/core/user-privacy")
@Tag(name = "User Privacy", description = "Gestión de configuración de privacidad del usuario — PK = userId (singleton)")
public class UserPrivacyController {

    private final UserPrivacyService service;

    public UserPrivacyController(UserPrivacyService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Listar configuraciones de privacidad")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno", content = @Content)
    })
    public ResponseEntity<Page<UserPrivacyResponse>> list(@PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @GetMapping("/{userId}")
    @Operation(summary = "Obtener privacidad de usuario por userId")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Configuración encontrada"),
        @ApiResponse(responseCode = "404", description = "No encontrada", content = @Content)
    })
    public ResponseEntity<UserPrivacyResponse> getById(
            @Parameter(description = "ID del usuario") @PathVariable Integer userId) {
        return ResponseEntity.ok(service.getById(userId));
    }

    @PostMapping
    @Operation(summary = "Crear configuración de privacidad",
               description = "Solo puede existir un registro por userId.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Creada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Configuración ya existente o datos inválidos", content = @Content)
    })
    public ResponseEntity<UserPrivacyResponse> create(@Valid @RequestBody UserPrivacyRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @PutMapping("/{userId}")
    @Operation(summary = "Actualizar configuración de privacidad de usuario")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Actualizada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "No encontrada", content = @Content)
    })
    public ResponseEntity<UserPrivacyResponse> update(
            @Parameter(description = "ID del usuario") @PathVariable Integer userId,
            @Valid @RequestBody UserPrivacyRequest request) {
        return ResponseEntity.ok(service.update(userId, request));
    }

    @DeleteMapping("/{userId}")
    @Operation(summary = "Eliminar configuración de privacidad de usuario")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Eliminada exitosamente"),
        @ApiResponse(responseCode = "404", description = "No encontrada", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del usuario") @PathVariable Integer userId) {
        service.delete(userId);
        return ResponseEntity.noContent().build();
    }
}
