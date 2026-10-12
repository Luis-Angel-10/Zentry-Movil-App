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

import zentry.back.api.business.dtos.PaymentMethodsRequest;
import zentry.back.api.business.dtos.PaymentMethodsResponse;
import zentry.back.api.business.services.PaymentMethodsService;

import java.util.UUID;

@RestController
@RequestMapping("/api/business/payment-methods")
@Tag(name = "Payment Methods", description = "Métodos de pago registrados por usuario")
public class PaymentMethodsController {

    private final PaymentMethodsService service;

    public PaymentMethodsController(PaymentMethodsService service) {
        this.service = service;
    }

    @Operation(summary = "Listar métodos de pago")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<PaymentMethodsResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener método de pago por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Método encontrado"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Método no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<PaymentMethodsResponse> getById(
            @Parameter(description = "UUID del método de pago") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Registrar método de pago",
               description = "No se permite registrar el mismo tipo de método dos veces para el mismo usuario.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Método registrado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Método duplicado u datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<PaymentMethodsResponse> create(
            @Valid @RequestBody PaymentMethodsRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar método de pago")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Método actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Método no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<PaymentMethodsResponse> update(
            @Parameter(description = "UUID del método de pago") @PathVariable UUID id,
            @Valid @RequestBody PaymentMethodsRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar método de pago")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Método eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Método no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "UUID del método de pago") @PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
