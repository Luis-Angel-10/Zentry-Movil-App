package zentry.back.api.core.controllers;

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

import zentry.back.api.core.dtos.BlockRequest;
import zentry.back.api.core.dtos.BlockResponse;
import zentry.back.api.core.services.BlockService;

@RestController
@RequestMapping("/api/core/blocks")
@Tag(name = "Blocks", description = "Gestión de bloqueos entre usuarios — clave compuesta (userId + blockedId)")
public class BlockController {

    private final BlockService service;

    public BlockController(BlockService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Listar bloqueos")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "500", description = "Error interno", content = @Content)
    })
    public ResponseEntity<Page<BlockResponse>> list(@PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @GetMapping("/{userId}/{blockedId}")
    @Operation(summary = "Obtener bloqueo por clave compuesta",
               description = "Requiere userId y blockedId para identificar el registro.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Bloqueo encontrado"),
        @ApiResponse(responseCode = "400", description = "IDs inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "No encontrado", content = @Content)
    })
    public ResponseEntity<BlockResponse> getById(
            @Parameter(description = "ID del usuario que bloquea") @PathVariable Integer userId,
            @Parameter(description = "ID del usuario bloqueado") @PathVariable Integer blockedId) {
        return ResponseEntity.ok(service.getById(userId, blockedId));
    }

    @PostMapping
    @Operation(summary = "Crear bloqueo entre usuarios",
               description = "No puede existir ya un bloqueo con el mismo userId y blockedId.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Bloqueo creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Bloqueo duplicado o datos inválidos", content = @Content)
    })
    public ResponseEntity<BlockResponse> create(@Valid @RequestBody BlockRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @DeleteMapping("/{userId}/{blockedId}")
    @Operation(summary = "Eliminar bloqueo entre usuarios")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Bloqueo eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "No encontrado", content = @Content)
    })
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del usuario que bloquea") @PathVariable Integer userId,
            @Parameter(description = "ID del usuario bloqueado") @PathVariable Integer blockedId) {
        service.delete(userId, blockedId);
        return ResponseEntity.noContent().build();
    }
}
