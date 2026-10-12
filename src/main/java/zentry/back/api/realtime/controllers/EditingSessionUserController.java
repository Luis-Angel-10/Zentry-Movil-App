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
import org.springframework.web.bind.annotation.*;

import zentry.back.api.realtime.dtos.EditingSessionUserRequest;
import zentry.back.api.realtime.dtos.EditingSessionUserResponse;
import zentry.back.api.realtime.service.EditingSessionUserService;

@RestController
@RequestMapping("/api/realtime/editing-session-users")
@Tag(name = "Usuarios en Sesión de Edición", description = "Gestión de usuarios participantes en sesiones de edición colaborativa — clave compuesta (sessionId + userId)")
public class EditingSessionUserController {

    private final EditingSessionUserService service;

    public EditingSessionUserController(EditingSessionUserService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Listar usuarios en sesiones de edición",
               description = "Devuelve una lista paginada de todos los usuarios participantes en sesiones de edición.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    public ResponseEntity<Page<EditingSessionUserResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @GetMapping("/{sessionId}/{userId}")
    @Operation(summary = "Obtener usuario de sesión de edición por clave compuesta",
               description = "Requiere sessionId y userId para identificar la participación en la sesión de edición.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Participación encontrada"),
        @ApiResponse(responseCode = "400", description = "IDs inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Participación no encontrada", content = @Content)
    })
    public ResponseEntity<EditingSessionUserResponse> getById(
            @Parameter(description = "ID de la sesión de edición") @PathVariable Integer sessionId,
            @Parameter(description = "ID del usuario participante") @PathVariable Integer userId) {
        return ResponseEntity.ok(service.getById(sessionId, userId));
    }

    @PostMapping
    @Operation(summary = "Agregar usuario a sesión de edición",
               description = "Registra un usuario como participante de una sesión de edición colaborativa. No puede existir ya la combinación sessionId + userId.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Usuario agregado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Participación ya existente o datos inválidos", content = @Content)
    })
    public ResponseEntity<EditingSessionUserResponse> create(
            @Valid @RequestBody EditingSessionUserRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @DeleteMapping("/{sessionId}/{userId}")
    @Operation(summary = "Eliminar usuario de sesión de edición",
               description = "Elimina la participación de un usuario en una sesión de edición usando la clave compuesta.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Participación eliminada exitosamente"),
        @ApiResponse(responseCode = "404", description = "Participación no encontrada", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID de la sesión de edición") @PathVariable Integer sessionId,
            @Parameter(description = "ID del usuario participante") @PathVariable Integer userId) {
        service.delete(sessionId, userId);
        return ResponseEntity.noContent().build();
    }
}
