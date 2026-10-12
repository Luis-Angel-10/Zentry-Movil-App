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

import zentry.back.api.realtime.dtos.VoiceSessionRequest;
import zentry.back.api.realtime.dtos.VoiceSessionResponse;
import zentry.back.api.realtime.service.VoiceSessionService;

@RestController
@RequestMapping("/api/realtime/voice-sessions")
@Tag(name = "Sesiones de Voz", description = "Gestión de sesiones de llamada de voz en tiempo real entre usuarios")
public class VoiceSessionController {

    private final VoiceSessionService service;

    public VoiceSessionController(VoiceSessionService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Listar sesiones de voz",
               description = "Devuelve una lista paginada de todas las sesiones de voz registradas.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    public ResponseEntity<Page<VoiceSessionResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener sesión de voz por ID",
               description = "Devuelve los datos de una sesión de voz específica.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Sesión de voz encontrada"),
        @ApiResponse(responseCode = "404", description = "Sesión de voz no encontrada", content = @Content)
    })
    public ResponseEntity<VoiceSessionResponse> getById(
            @Parameter(description = "ID de la sesión de voz") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @PostMapping
    @Operation(summary = "Crear sesión de voz",
               description = "Inicia una nueva sesión de llamada de voz en tiempo real.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Sesión de voz creada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content)
    })
    public ResponseEntity<VoiceSessionResponse> create(
            @Valid @RequestBody VoiceSessionRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Actualizar sesión de voz",
               description = "Modifica los datos de una sesión de voz existente.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Sesión de voz actualizada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content),
        @ApiResponse(responseCode = "404", description = "Sesión de voz no encontrada", content = @Content)
    })
    public ResponseEntity<VoiceSessionResponse> update(
            @Parameter(description = "ID de la sesión de voz") @PathVariable Integer id,
            @Valid @RequestBody VoiceSessionRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Finalizar y eliminar sesión de voz",
               description = "Finaliza y elimina permanentemente una sesión de voz por su ID.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Sesión de voz eliminada exitosamente"),
        @ApiResponse(responseCode = "404", description = "Sesión de voz no encontrada", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID de la sesión de voz") @PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
