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

import zentry.back.api.realtime.dtos.PushQueueRequest;
import zentry.back.api.realtime.dtos.PushQueueResponse;
import zentry.back.api.realtime.service.PushQueueService;

@RestController
@RequestMapping("/api/realtime/push-queues")
@Tag(name = "Cola de Notificaciones Push", description = "Gestión de la cola de mensajes push pendientes de entrega a dispositivos")
public class PushQueueController {

    private final PushQueueService service;

    public PushQueueController(PushQueueService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Listar cola de notificaciones push",
               description = "Devuelve una lista paginada de todos los mensajes push en cola.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    public ResponseEntity<Page<PushQueueResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener elemento de cola push por ID",
               description = "Devuelve los datos de un mensaje push en cola específico.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Elemento encontrado"),
        @ApiResponse(responseCode = "404", description = "Elemento no encontrado", content = @Content)
    })
    public ResponseEntity<PushQueueResponse> getById(
            @Parameter(description = "ID del elemento en cola push") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @PostMapping
    @Operation(summary = "Encolar notificación push",
               description = "Agrega un nuevo mensaje push a la cola de entrega.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Notificación encolada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content)
    })
    public ResponseEntity<PushQueueResponse> create(
            @Valid @RequestBody PushQueueRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Actualizar elemento de cola push",
               description = "Modifica los datos de un elemento en la cola push (por ejemplo, cambiar estado de entrega).")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Elemento actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content),
        @ApiResponse(responseCode = "404", description = "Elemento no encontrado", content = @Content)
    })
    public ResponseEntity<PushQueueResponse> update(
            @Parameter(description = "ID del elemento en cola push") @PathVariable Integer id,
            @Valid @RequestBody PushQueueRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar elemento de cola push",
               description = "Elimina permanentemente un elemento de la cola push por su ID.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Elemento eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Elemento no encontrado", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del elemento en cola push") @PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
