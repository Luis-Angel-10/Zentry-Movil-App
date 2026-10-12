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

import zentry.back.api.realtime.dtos.TypingStatusRequest;
import zentry.back.api.realtime.dtos.TypingStatusResponse;
import zentry.back.api.realtime.service.TypingStatusService;

@RestController
@RequestMapping("/api/realtime/typing-statuses")
@Tag(name = "Estado de Escritura", description = "Gestión del indicador de escritura de usuarios en conversaciones — clave compuesta (userId + conversationId)")
public class TypingStatusController {

    private final TypingStatusService service;

    public TypingStatusController(TypingStatusService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Listar estados de escritura",
               description = "Devuelve una lista paginada de todos los indicadores de escritura activos.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    public ResponseEntity<Page<TypingStatusResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @GetMapping("/{userId}/{conversationId}")
    @Operation(summary = "Obtener estado de escritura por clave compuesta",
               description = "Requiere userId y conversationId para consultar si un usuario está escribiendo en una conversación.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Estado de escritura encontrado"),
        @ApiResponse(responseCode = "400", description = "IDs inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Estado de escritura no encontrado", content = @Content)
    })
    public ResponseEntity<TypingStatusResponse> getById(
            @Parameter(description = "ID del usuario") @PathVariable Integer userId,
            @Parameter(description = "ID de la conversación") @PathVariable Integer conversationId) {
        return ResponseEntity.ok(service.getById(userId, conversationId));
    }

    @PostMapping
    @Operation(summary = "Registrar estado de escritura",
               description = "Indica que un usuario comenzó a escribir en una conversación. No puede existir ya la combinación userId + conversationId.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Estado registrado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Estado ya existente o datos inválidos", content = @Content)
    })
    public ResponseEntity<TypingStatusResponse> create(
            @Valid @RequestBody TypingStatusRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @DeleteMapping("/{userId}/{conversationId}")
    @Operation(summary = "Eliminar estado de escritura",
               description = "Indica que un usuario dejó de escribir. Elimina el indicador usando la clave compuesta.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Estado eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Estado de escritura no encontrado", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del usuario") @PathVariable Integer userId,
            @Parameter(description = "ID de la conversación") @PathVariable Integer conversationId) {
        service.delete(userId, conversationId);
        return ResponseEntity.noContent().build();
    }
}
