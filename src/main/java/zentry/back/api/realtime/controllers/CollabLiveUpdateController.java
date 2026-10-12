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

import zentry.back.api.realtime.dtos.CollabLiveUpdateRequest;
import zentry.back.api.realtime.dtos.CollabLiveUpdateResponse;
import zentry.back.api.realtime.service.CollabLiveUpdateService;

@RestController
@RequestMapping("/api/realtime/collab-live-updates")
@Tag(name = "Actualizaciones de Colaboración en Vivo", description = "Gestión de actualizaciones en tiempo real de proyectos colaborativos")
public class CollabLiveUpdateController {

    private final CollabLiveUpdateService service;

    public CollabLiveUpdateController(CollabLiveUpdateService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Listar actualizaciones de colaboración",
               description = "Devuelve una lista paginada de todas las actualizaciones de colaboración en vivo.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    public ResponseEntity<Page<CollabLiveUpdateResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener actualización de colaboración por ID",
               description = "Devuelve los datos de una actualización de colaboración específica.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Actualización encontrada"),
        @ApiResponse(responseCode = "404", description = "Actualización no encontrada", content = @Content)
    })
    public ResponseEntity<CollabLiveUpdateResponse> getById(
            @Parameter(description = "ID de la actualización de colaboración") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @PostMapping
    @Operation(summary = "Registrar actualización de colaboración",
               description = "Crea un nuevo registro de actualización para un proyecto colaborativo en vivo.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Actualización registrada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content)
    })
    public ResponseEntity<CollabLiveUpdateResponse> create(
            @Valid @RequestBody CollabLiveUpdateRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Actualizar registro de colaboración",
               description = "Modifica los datos de una actualización de colaboración existente.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Actualización modificada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content),
        @ApiResponse(responseCode = "404", description = "Actualización no encontrada", content = @Content)
    })
    public ResponseEntity<CollabLiveUpdateResponse> update(
            @Parameter(description = "ID de la actualización de colaboración") @PathVariable Integer id,
            @Valid @RequestBody CollabLiveUpdateRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar actualización de colaboración",
               description = "Elimina permanentemente una actualización de colaboración por su ID.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Actualización eliminada exitosamente"),
        @ApiResponse(responseCode = "404", description = "Actualización no encontrada", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID de la actualización de colaboración") @PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
