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

import zentry.back.api.business.dtos.PayoutRequestsRequest;
import zentry.back.api.business.dtos.PayoutRequestsResponse;
import zentry.back.api.business.services.PayoutRequestsService;

import java.util.UUID;

@RestController
@RequestMapping("/api/business/payout-requests")
@Tag(name = "Payout Requests", description = "Solicitudes de retiro de fondos realizadas por usuarios")
public class PayoutRequestsController {

    private final PayoutRequestsService service;

    public PayoutRequestsController(PayoutRequestsService service) {
        this.service = service;
    }

    @Operation(summary = "Listar solicitudes de payout")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<PayoutRequestsResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener solicitud de payout por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Solicitud encontrada"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Solicitud no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<PayoutRequestsResponse> getById(
            @Parameter(description = "UUID de la solicitud") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Crear solicitud de payout")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Solicitud creada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<PayoutRequestsResponse> create(
            @Valid @RequestBody PayoutRequestsRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar solicitud de payout")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Solicitud actualizada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Solicitud no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<PayoutRequestsResponse> update(
            @Parameter(description = "UUID de la solicitud") @PathVariable UUID id,
            @Valid @RequestBody PayoutRequestsRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar solicitud de payout")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Solicitud eliminada exitosamente"),
        @ApiResponse(responseCode = "404", description = "Solicitud no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "UUID de la solicitud") @PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
