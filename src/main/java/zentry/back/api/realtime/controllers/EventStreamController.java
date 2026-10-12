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

import zentry.back.api.realtime.dtos.EventStreamRequest;
import zentry.back.api.realtime.dtos.EventStreamResponse;
import zentry.back.api.realtime.service.EventStreamService;

@RestController
@RequestMapping("/api/realtime/event-streams")
@Tag(name = "Flujos de Eventos", description = "Gestión de flujos de eventos en tiempo real del sistema")
public class EventStreamController {

    private final EventStreamService service;

    public EventStreamController(EventStreamService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Listar flujos de eventos",
               description = "Devuelve una lista paginada de todos los flujos de eventos registrados.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    public ResponseEntity<Page<EventStreamResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener flujo de eventos por ID",
               description = "Devuelve los datos de un flujo de eventos específico.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Flujo de eventos encontrado"),
        @ApiResponse(responseCode = "404", description = "Flujo de eventos no encontrado", content = @Content)
    })
    public ResponseEntity<EventStreamResponse> getById(
            @Parameter(description = "ID del flujo de eventos") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @PostMapping
    @Operation(summary = "Crear flujo de eventos",
               description = "Registra un nuevo flujo de eventos en tiempo real.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Flujo de eventos creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content)
    })
    public ResponseEntity<EventStreamResponse> create(
            @Valid @RequestBody EventStreamRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Actualizar flujo de eventos",
               description = "Modifica los datos de un flujo de eventos existente.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Flujo de eventos actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content),
        @ApiResponse(responseCode = "404", description = "Flujo de eventos no encontrado", content = @Content)
    })
    public ResponseEntity<EventStreamResponse> update(
            @Parameter(description = "ID del flujo de eventos") @PathVariable Integer id,
            @Valid @RequestBody EventStreamRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar flujo de eventos",
               description = "Elimina permanentemente un flujo de eventos por su ID.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Flujo de eventos eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Flujo de eventos no encontrado", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del flujo de eventos") @PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
