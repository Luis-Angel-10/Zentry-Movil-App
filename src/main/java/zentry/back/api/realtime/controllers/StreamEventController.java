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

import zentry.back.api.realtime.dtos.StreamEventRequest;
import zentry.back.api.realtime.dtos.StreamEventResponse;
import zentry.back.api.realtime.service.StreamEventService;

@RestController
@RequestMapping("/api/realtime/stream-events")
@Tag(name = "Eventos de Stream", description = "Gestión de eventos técnicos generados durante transmisiones de stream")
public class StreamEventController {

    private final StreamEventService service;

    public StreamEventController(StreamEventService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Listar eventos de stream",
               description = "Devuelve una lista paginada de todos los eventos técnicos de stream registrados.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    public ResponseEntity<Page<StreamEventResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener evento de stream por ID",
               description = "Devuelve los datos de un evento de stream específico.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Evento de stream encontrado"),
        @ApiResponse(responseCode = "404", description = "Evento de stream no encontrado", content = @Content)
    })
    public ResponseEntity<StreamEventResponse> getById(
            @Parameter(description = "ID del evento de stream") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @PostMapping
    @Operation(summary = "Registrar evento de stream",
               description = "Registra un nuevo evento técnico ocurrido durante una transmisión de stream.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Evento registrado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content)
    })
    public ResponseEntity<StreamEventResponse> create(
            @Valid @RequestBody StreamEventRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Actualizar evento de stream",
               description = "Modifica los datos de un evento de stream existente.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Evento actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content),
        @ApiResponse(responseCode = "404", description = "Evento de stream no encontrado", content = @Content)
    })
    public ResponseEntity<StreamEventResponse> update(
            @Parameter(description = "ID del evento de stream") @PathVariable Integer id,
            @Valid @RequestBody StreamEventRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar evento de stream",
               description = "Elimina permanentemente un evento de stream por su ID.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Evento eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Evento de stream no encontrado", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del evento de stream") @PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
