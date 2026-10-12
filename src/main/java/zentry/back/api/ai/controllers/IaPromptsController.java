package zentry.back.api.ai.controllers;

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

import zentry.back.api.ai.dtos.IaPromptsRequest;
import zentry.back.api.ai.dtos.IaPromptsResponse;
import zentry.back.api.ai.services.IaPromptsService;

import java.util.UUID;

@RestController
@RequestMapping("/api/ai/prompts")
@Tag(name = "IA Prompts", description = "Prompts enviados por usuarios a los modelos de IA")
public class IaPromptsController {

    private final IaPromptsService service;

    public IaPromptsController(IaPromptsService service) {
        this.service = service;
    }

    @Operation(summary = "Listar prompts de IA",
               description = "Devuelve lista paginada de todos los prompts registrados por usuarios.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<IaPromptsResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener prompt por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Prompt encontrado"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Prompt no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<IaPromptsResponse> getById(
            @Parameter(description = "UUID del prompt") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Crear prompt",
               description = "Registra un nuevo prompt de usuario. El campo 'prompt' no puede estar vacío.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Prompt creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Prompt vacío u otros datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<IaPromptsResponse> create(
            @Valid @RequestBody IaPromptsRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar prompt")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Prompt actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Prompt no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<IaPromptsResponse> update(
            @Parameter(description = "UUID del prompt") @PathVariable UUID id,
            @Valid @RequestBody IaPromptsRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar prompt")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Prompt eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Prompt no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "UUID del prompt a eliminar") @PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
