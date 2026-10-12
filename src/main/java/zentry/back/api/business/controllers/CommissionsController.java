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

import zentry.back.api.business.dtos.CommissionsRequest;
import zentry.back.api.business.dtos.CommissionsResponse;
import zentry.back.api.business.services.CommissionsService;

import java.util.UUID;

@RestController
@RequestMapping("/api/business/commissions")
@Tag(name = "Commissions", description = "Configuración de comisiones aplicadas a transacciones")
public class CommissionsController {

    private final CommissionsService service;

    public CommissionsController(CommissionsService service) {
        this.service = service;
    }

    @Operation(summary = "Listar comisiones")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<CommissionsResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener comisión por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Comisión encontrada"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Comisión no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<CommissionsResponse> getById(
            @Parameter(description = "UUID de la comisión") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Crear comisión")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Comisión creada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<CommissionsResponse> create(
            @Valid @RequestBody CommissionsRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar comisión")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Comisión actualizada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Comisión no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<CommissionsResponse> update(
            @Parameter(description = "UUID de la comisión") @PathVariable UUID id,
            @Valid @RequestBody CommissionsRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar comisión")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Comisión eliminada exitosamente"),
        @ApiResponse(responseCode = "404", description = "Comisión no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "UUID de la comisión") @PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
