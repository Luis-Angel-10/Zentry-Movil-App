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

import zentry.back.api.realtime.dtos.VideoSessionRequest;
import zentry.back.api.realtime.dtos.VideoSessionResponse;
import zentry.back.api.realtime.service.VideoSessionService;

@RestController
@RequestMapping("/api/realtime/video-sessions")
@Tag(name = "Sesiones de Video", description = "Gestión de sesiones de videollamada en tiempo real entre usuarios")
public class VideoSessionController {

    private final VideoSessionService service;

    public VideoSessionController(VideoSessionService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Listar sesiones de video",
               description = "Devuelve una lista paginada de todas las sesiones de video registradas.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    public ResponseEntity<Page<VideoSessionResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener sesión de video por ID",
               description = "Devuelve los datos de una sesión de video específica.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Sesión de video encontrada"),
        @ApiResponse(responseCode = "404", description = "Sesión de video no encontrada", content = @Content)
    })
    public ResponseEntity<VideoSessionResponse> getById(
            @Parameter(description = "ID de la sesión de video") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @PostMapping
    @Operation(summary = "Crear sesión de video",
               description = "Inicia una nueva sesión de videollamada en tiempo real.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Sesión de video creada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content)
    })
    public ResponseEntity<VideoSessionResponse> create(
            @Valid @RequestBody VideoSessionRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Actualizar sesión de video",
               description = "Modifica los datos de una sesión de video existente (calidad, estado, etc.).")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Sesión de video actualizada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos en la solicitud", content = @Content),
        @ApiResponse(responseCode = "404", description = "Sesión de video no encontrada", content = @Content)
    })
    public ResponseEntity<VideoSessionResponse> update(
            @Parameter(description = "ID de la sesión de video") @PathVariable Integer id,
            @Valid @RequestBody VideoSessionRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Finalizar y eliminar sesión de video",
               description = "Finaliza y elimina permanentemente una sesión de video por su ID.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Sesión de video eliminada exitosamente"),
        @ApiResponse(responseCode = "404", description = "Sesión de video no encontrada", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID de la sesión de video") @PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
