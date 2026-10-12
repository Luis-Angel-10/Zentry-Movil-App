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

import zentry.back.api.realtime.dtos.SocketConnectionRequest;
import zentry.back.api.realtime.dtos.SocketConnectionResponse;
import zentry.back.api.realtime.service.SocketConnectionService;

@RestController
@RequestMapping("/api/realtime/socket-connections")
@Tag(name = "Conexiones de Socket", description = "Gestión y registro de conexiones WebSocket activas de usuarios")
public class SocketConnectionController {

    private final SocketConnectionService service;

    public SocketConnectionController(SocketConnectionService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Listar conexiones de socket",
               description = "Devuelve una lista paginada de todas las conexiones WebSocket registradas.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    public ResponseEntity<Page<SocketConnectionResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener conexión de socket por ID",
               description = "Devuelve los datos de una conexión WebSocket específica.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Conexión encontrada"),
        @ApiResponse(responseCode = "404", description = "Conexión no encontrada", content = @Content)
    })
    public ResponseEntity<SocketConnectionResponse> getById(
            @Parameter(description = "ID de la conexión de socket") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @PostMapping
    @Operation(summary = "Registrar conexión de socket",
               description = "Registra una nueva conexión WebSocket cuando un usuario se conecta.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Conexión registrada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content)
    })
    public ResponseEntity<SocketConnectionResponse> create(
            @Valid @RequestBody SocketConnectionRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Actualizar conexión de socket",
               description = "Modifica los datos de una conexión WebSocket existente (por ejemplo, cambiar estado).")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Conexión actualizada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content),
        @ApiResponse(responseCode = "404", description = "Conexión no encontrada", content = @Content)
    })
    public ResponseEntity<SocketConnectionResponse> update(
            @Parameter(description = "ID de la conexión de socket") @PathVariable Integer id,
            @Valid @RequestBody SocketConnectionRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar conexión de socket",
               description = "Elimina el registro de una conexión WebSocket cuando el usuario se desconecta.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Conexión eliminada exitosamente"),
        @ApiResponse(responseCode = "404", description = "Conexión no encontrada", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID de la conexión de socket") @PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
