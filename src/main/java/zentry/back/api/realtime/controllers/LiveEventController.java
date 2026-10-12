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

import zentry.back.api.realtime.dtos.LiveEventRequest;
import zentry.back.api.realtime.dtos.LiveEventResponse;
import zentry.back.api.realtime.service.LiveEventService;

@RestController
@RequestMapping("/api/realtime/live-events")
@Tag(name = "Eventos en Vivo", description = "Gestión de eventos que se transmiten en tiempo real en la plataforma")
public class LiveEventController {

    private final LiveEventService service;

    public LiveEventController(LiveEventService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Listar eventos en vivo",
               description = "Devuelve una lista paginada de todos los eventos en vivo registrados.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    public ResponseEntity<Page<LiveEventResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener evento en vivo por ID",
               description = "Devuelve los datos de un evento en vivo específico.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Evento encontrado"),
        @ApiResponse(responseCode = "404", description = "Evento no encontrado", content = @Content)
    })
    public ResponseEntity<LiveEventResponse> getById(
            @Parameter(description = "ID del evento en vivo") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @PostMapping
    @Operation(summary = "Crear evento en vivo",
               description = "Registra un nuevo evento que será transmitido en tiempo real.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Evento creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content)
    })
    public ResponseEntity<LiveEventResponse> create(
            @Valid @RequestBody LiveEventRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Actualizar evento en vivo",
               description = "Modifica los datos de un evento en vivo existente.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Evento actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content),
        @ApiResponse(responseCode = "404", description = "Evento no encontrado", content = @Content)
    })
    public ResponseEntity<LiveEventResponse> update(
            @Parameter(description = "ID del evento en vivo") @PathVariable Integer id,
            @Valid @RequestBody LiveEventRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar evento en vivo",
               description = "Elimina permanentemente un evento en vivo por su ID.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Evento eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Evento no encontrado", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del evento en vivo") @PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
