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

import zentry.back.api.ai.dtos.IaSimilarityUsersRequest;
import zentry.back.api.ai.dtos.IaSimilarityUsersResponse;
import zentry.back.api.ai.services.IaSimilarityUsersService;

@RestController
@RequestMapping("/api/ai/similarity-users")
@Tag(name = "IA Similarity Users", description = "Similitud semántica calculada entre pares de usuarios")
public class IaSimilarityUsersController {

    private final IaSimilarityUsersService service;

    public IaSimilarityUsersController(IaSimilarityUsersService service) {
        this.service = service;
    }

    @Operation(summary = "Listar similitudes entre usuarios",
               description = "Devuelve lista paginada de pares de usuarios con su puntuación de similitud.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<IaSimilarityUsersResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener similitud entre dos usuarios",
               description = "Busca el registro de similitud entre user1 y user2. Ambos IDs deben ser positivos.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro encontrado"),
        @ApiResponse(responseCode = "400", description = "IDs negativos o cero", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{user1}/{user2}")
    public ResponseEntity<IaSimilarityUsersResponse> getById(
            @Parameter(description = "ID del primer usuario") @PathVariable Integer user1,
            @Parameter(description = "ID del segundo usuario") @PathVariable Integer user2) {
        return ResponseEntity.ok(service.getById(user1, user2));
    }

    @Operation(summary = "Crear similitud entre usuarios",
               description = "Registra similitud entre dos usuarios. No puede existir ya un registro para el mismo par user1/user2.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Registro creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Par de usuarios duplicado u otros datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<IaSimilarityUsersResponse> create(
            @Valid @RequestBody IaSimilarityUsersRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar similitud entre usuarios",
               description = "Actualiza el score de similitud entre dos usuarios existentes.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{user1}/{user2}")
    public ResponseEntity<IaSimilarityUsersResponse> update(
            @Parameter(description = "ID del primer usuario") @PathVariable Integer user1,
            @Parameter(description = "ID del segundo usuario") @PathVariable Integer user2,
            @Valid @RequestBody IaSimilarityUsersRequest request) {
        return ResponseEntity.ok(service.update(user1, user2, request));
    }

    @Operation(summary = "Eliminar similitud entre usuarios")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Registro eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{user1}/{user2}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del primer usuario") @PathVariable Integer user1,
            @Parameter(description = "ID del segundo usuario") @PathVariable Integer user2) {
        service.delete(user1, user2);
        return ResponseEntity.noContent().build();
    }
}
