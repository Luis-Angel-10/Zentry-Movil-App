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

import zentry.back.api.realtime.dtos.RealtimeReactionRequest;
import zentry.back.api.realtime.dtos.RealtimeReactionResponse;
import zentry.back.api.realtime.service.RealtimeReactionService;

@RestController
@RequestMapping("/api/realtime/realtime-reactions")
@Tag(name = "Reacciones en Tiempo Real", description = "Gestión de reacciones instantáneas emitidas durante eventos o transmisiones en vivo")
public class RealtimeReactionController {

    private final RealtimeReactionService service;

    public RealtimeReactionController(RealtimeReactionService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Listar reacciones en tiempo real",
               description = "Devuelve una lista paginada de todas las reacciones registradas en tiempo real.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    public ResponseEntity<Page<RealtimeReactionResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener reacción en tiempo real por ID",
               description = "Devuelve los datos de una reacción en tiempo real específica.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Reacción encontrada"),
        @ApiResponse(responseCode = "404", description = "Reacción no encontrada", content = @Content)
    })
    public ResponseEntity<RealtimeReactionResponse> getById(
            @Parameter(description = "ID de la reacción en tiempo real") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @PostMapping
    @Operation(summary = "Registrar reacción en tiempo real",
               description = "Registra una nueva reacción instantánea de un usuario durante un evento en vivo.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Reacción registrada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content)
    })
    public ResponseEntity<RealtimeReactionResponse> create(
            @Valid @RequestBody RealtimeReactionRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Actualizar reacción en tiempo real",
               description = "Modifica los datos de una reacción en tiempo real existente.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Reacción actualizada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content),
        @ApiResponse(responseCode = "404", description = "Reacción no encontrada", content = @Content)
    })
    public ResponseEntity<RealtimeReactionResponse> update(
            @Parameter(description = "ID de la reacción en tiempo real") @PathVariable Integer id,
            @Valid @RequestBody RealtimeReactionRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar reacción en tiempo real",
               description = "Elimina permanentemente una reacción en tiempo real por su ID.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Reacción eliminada exitosamente"),
        @ApiResponse(responseCode = "404", description = "Reacción no encontrada", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID de la reacción en tiempo real") @PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
