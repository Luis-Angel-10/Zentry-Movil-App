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

import zentry.back.api.realtime.dtos.OnlineUserRequest;
import zentry.back.api.realtime.dtos.OnlineUserResponse;
import zentry.back.api.realtime.service.OnlineUserService;

@RestController
@RequestMapping("/api/realtime/online-users")
@Tag(name = "Usuarios en Línea", description = "Gestión del estado de presencia de usuarios conectados en tiempo real")
public class OnlineUserController {

    private final OnlineUserService service;

    public OnlineUserController(OnlineUserService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Listar usuarios en línea",
               description = "Devuelve una lista paginada de todos los registros de presencia de usuarios.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    public ResponseEntity<Page<OnlineUserResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @GetMapping("/{userId}")
    @Operation(summary = "Obtener estado de presencia por ID de usuario",
               description = "Devuelve el estado de conexión actual de un usuario específico.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Estado de presencia encontrado"),
        @ApiResponse(responseCode = "404", description = "Usuario en línea no encontrado", content = @Content)
    })
    public ResponseEntity<OnlineUserResponse> getById(
            @Parameter(description = "ID del usuario") @PathVariable Integer userId) {
        return ResponseEntity.ok(service.getById(userId));
    }

    @PostMapping
    @Operation(summary = "Registrar usuario en línea",
               description = "Registra la presencia de un usuario cuando se conecta a la plataforma.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Presencia registrada exitosamente"),
        @ApiResponse(responseCode = "400", description = "El usuario ya está registrado como en línea o datos inválidos", content = @Content)
    })
    public ResponseEntity<OnlineUserResponse> create(
            @Valid @RequestBody OnlineUserRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @PutMapping("/{userId}")
    @Operation(summary = "Actualizar estado de usuario en línea",
               description = "Actualiza el estado de conexión de un usuario (por ejemplo, activo, inactivo, ausente).")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Estado actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content),
        @ApiResponse(responseCode = "404", description = "Usuario en línea no encontrado", content = @Content)
    })
    public ResponseEntity<OnlineUserResponse> update(
            @Parameter(description = "ID del usuario") @PathVariable Integer userId,
            @Valid @RequestBody OnlineUserRequest request) {
        return ResponseEntity.ok(service.update(userId, request));
    }

    @DeleteMapping("/{userId}")
    @Operation(summary = "Eliminar registro de usuario en línea",
               description = "Elimina el registro de presencia de un usuario cuando se desconecta.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Registro eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Usuario en línea no encontrado", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del usuario") @PathVariable Integer userId) {
        service.delete(userId);
        return ResponseEntity.noContent().build();
    }
}
