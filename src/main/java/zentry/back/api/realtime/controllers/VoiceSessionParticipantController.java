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

import zentry.back.api.realtime.dtos.VoiceSessionParticipantRequest;
import zentry.back.api.realtime.dtos.VoiceSessionParticipantResponse;
import zentry.back.api.realtime.service.VoiceSessionParticipantService;

@RestController
@RequestMapping("/api/realtime/voice-session-participants")
@Tag(name = "Participantes de Sesión de Voz", description = "Gestión de participantes en sesiones de llamada de voz — clave compuesta (sessionId + userId)")
public class VoiceSessionParticipantController {

    private final VoiceSessionParticipantService service;

    public VoiceSessionParticipantController(VoiceSessionParticipantService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Listar participantes de sesiones de voz",
               description = "Devuelve una lista paginada de todos los participantes en sesiones de llamada de voz.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    public ResponseEntity<Page<VoiceSessionParticipantResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @GetMapping("/{sessionId}/{userId}")
    @Operation(summary = "Obtener participante de sesión de voz por clave compuesta",
               description = "Requiere sessionId y userId para identificar la participación en la sesión de voz.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Participante encontrado"),
        @ApiResponse(responseCode = "400", description = "IDs inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Participante no encontrado", content = @Content)
    })
    public ResponseEntity<VoiceSessionParticipantResponse> getById(
            @Parameter(description = "ID de la sesión de voz") @PathVariable Integer sessionId,
            @Parameter(description = "ID del usuario participante") @PathVariable Integer userId) {
        return ResponseEntity.ok(service.getById(sessionId, userId));
    }

    @PostMapping
    @Operation(summary = "Agregar participante a sesión de voz",
               description = "Registra un usuario como participante de una sesión de llamada de voz. No puede existir ya la combinación sessionId + userId.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Participante agregado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Participante ya existente o datos inválidos", content = @Content)
    })
    public ResponseEntity<VoiceSessionParticipantResponse> create(
            @Valid @RequestBody VoiceSessionParticipantRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @DeleteMapping("/{sessionId}/{userId}")
    @Operation(summary = "Eliminar participante de sesión de voz",
               description = "Elimina la participación de un usuario en una sesión de voz usando la clave compuesta.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Participante eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Participante no encontrado", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID de la sesión de voz") @PathVariable Integer sessionId,
            @Parameter(description = "ID del usuario participante") @PathVariable Integer userId) {
        service.delete(sessionId, userId);
        return ResponseEntity.noContent().build();
    }
}
