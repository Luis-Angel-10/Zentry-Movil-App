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

import zentry.back.api.realtime.dtos.EditingChangeRequest;
import zentry.back.api.realtime.dtos.EditingChangeResponse;
import zentry.back.api.realtime.service.EditingChangeService;

@RestController
@RequestMapping("/api/realtime/editing-changes")
@Tag(name = "Cambios de Edición", description = "Gestión del historial de cambios realizados en sesiones de edición colaborativa")
public class EditingChangeController {

    private final EditingChangeService service;

    public EditingChangeController(EditingChangeService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Listar cambios de edición",
               description = "Devuelve una lista paginada de todos los cambios registrados en sesiones de edición.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    public ResponseEntity<Page<EditingChangeResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener cambio de edición por ID",
               description = "Devuelve los datos de un cambio de edición específico.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Cambio encontrado"),
        @ApiResponse(responseCode = "404", description = "Cambio no encontrado", content = @Content)
    })
    public ResponseEntity<EditingChangeResponse> getById(
            @Parameter(description = "ID del cambio de edición") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @PostMapping
    @Operation(summary = "Registrar cambio de edición",
               description = "Registra un nuevo cambio realizado dentro de una sesión de edición colaborativa.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Cambio registrado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content)
    })
    public ResponseEntity<EditingChangeResponse> create(
            @Valid @RequestBody EditingChangeRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Actualizar cambio de edición",
               description = "Modifica los datos de un cambio de edición existente.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Cambio actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content),
        @ApiResponse(responseCode = "404", description = "Cambio no encontrado", content = @Content)
    })
    public ResponseEntity<EditingChangeResponse> update(
            @Parameter(description = "ID del cambio de edición") @PathVariable Integer id,
            @Valid @RequestBody EditingChangeRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar cambio de edición",
               description = "Elimina permanentemente un cambio de edición por su ID.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Cambio eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Cambio no encontrado", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del cambio de edición") @PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
