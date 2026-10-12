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

import zentry.back.api.realtime.dtos.PresenceLogRequest;
import zentry.back.api.realtime.dtos.PresenceLogResponse;
import zentry.back.api.realtime.service.PresenceLogService;

@RestController
@RequestMapping("/api/realtime/presence-logs")
@Tag(name = "Registros de Presencia", description = "Historial de conexiones y desconexiones de usuarios en la plataforma")
public class PresenceLogController {

    private final PresenceLogService service;

    public PresenceLogController(PresenceLogService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Listar registros de presencia",
               description = "Devuelve una lista paginada del historial completo de presencia de usuarios.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    public ResponseEntity<Page<PresenceLogResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener registro de presencia por ID",
               description = "Devuelve los datos de un registro de presencia específico.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro encontrado"),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    public ResponseEntity<PresenceLogResponse> getById(
            @Parameter(description = "ID del registro de presencia") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @PostMapping
    @Operation(summary = "Crear registro de presencia",
               description = "Registra un nuevo evento de conexión o desconexión de un usuario.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Registro creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content)
    })
    public ResponseEntity<PresenceLogResponse> create(
            @Valid @RequestBody PresenceLogRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Actualizar registro de presencia",
               description = "Modifica los datos de un registro de presencia existente.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    public ResponseEntity<PresenceLogResponse> update(
            @Parameter(description = "ID del registro de presencia") @PathVariable Integer id,
            @Valid @RequestBody PresenceLogRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar registro de presencia",
               description = "Elimina permanentemente un registro de presencia por su ID.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Registro eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del registro de presencia") @PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
