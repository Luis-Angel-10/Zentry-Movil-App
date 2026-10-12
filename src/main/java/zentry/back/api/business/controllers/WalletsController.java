package zentry.back.api.business.controllers;

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

import zentry.back.api.business.dtos.WalletsRequest;
import zentry.back.api.business.dtos.WalletsResponse;
import zentry.back.api.business.services.WalletsService;

@RestController
@RequestMapping("/api/business/wallets")
@Tag(name = "Wallets", description = "Gestión de billeteras digitales por usuario")
public class WalletsController {

    private final WalletsService service;

    public WalletsController(WalletsService service) {
        this.service = service;
    }

    @Operation(summary = "Listar billeteras", description = "Devuelve lista paginada de todas las billeteras registradas.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<WalletsResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener billetera por userId",
               description = "La clave primaria es el userId (Integer), no un UUID.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Billetera encontrada"),
        @ApiResponse(responseCode = "404", description = "Billetera no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{userId}")
    public ResponseEntity<WalletsResponse> getById(
            @Parameter(description = "ID del usuario propietario") @PathVariable Integer userId) {
        return ResponseEntity.ok(service.getById(userId));
    }

    @Operation(summary = "Crear billetera",
               description = "Solo puede existir una billetera por usuario.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Billetera creada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Billetera ya existe para este usuario u datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<WalletsResponse> create(
            @Valid @RequestBody WalletsRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar saldo de billetera")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Billetera actualizada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Billetera no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{userId}")
    public ResponseEntity<WalletsResponse> update(
            @Parameter(description = "ID del usuario") @PathVariable Integer userId,
            @Valid @RequestBody WalletsRequest request) {
        return ResponseEntity.ok(service.update(userId, request));
    }

    @Operation(summary = "Eliminar billetera")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Billetera eliminada exitosamente"),
        @ApiResponse(responseCode = "404", description = "Billetera no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{userId}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del usuario") @PathVariable Integer userId) {
        service.delete(userId);
        return ResponseEntity.noContent().build();
    }
}
