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

import zentry.back.api.business.dtos.CommissionJobsRequest;
import zentry.back.api.business.dtos.CommissionJobsResponse;
import zentry.back.api.business.services.CommissionJobsService;

import java.util.UUID;

@RestController
@RequestMapping("/api/business/commission-jobs")
@Tag(name = "Commission Jobs", description = "Trabajos de comisión asignados a usuarios")
public class CommissionJobsController {

    private final CommissionJobsService service;

    public CommissionJobsController(CommissionJobsService service) {
        this.service = service;
    }

    @Operation(summary = "Listar trabajos de comisión")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<CommissionJobsResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener trabajo de comisión por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Trabajo encontrado"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Trabajo no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<CommissionJobsResponse> getById(
            @Parameter(description = "UUID del trabajo") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Crear trabajo de comisión")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Trabajo creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<CommissionJobsResponse> create(
            @Valid @RequestBody CommissionJobsRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar trabajo de comisión")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Trabajo actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Trabajo no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<CommissionJobsResponse> update(
            @Parameter(description = "UUID del trabajo") @PathVariable UUID id,
            @Valid @RequestBody CommissionJobsRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar trabajo de comisión")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Trabajo eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Trabajo no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "UUID del trabajo") @PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
