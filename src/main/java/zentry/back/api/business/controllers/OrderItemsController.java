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

import zentry.back.api.business.dtos.OrderItemsRequest;
import zentry.back.api.business.dtos.OrderItemsResponse;
import zentry.back.api.business.services.OrderItemsService;

import java.util.UUID;

@RestController
@RequestMapping("/api/business/order-items")
@Tag(name = "Order Items", description = "Ítems dentro de una orden — clave compuesta (orderId + productId)")
public class OrderItemsController {

    private final OrderItemsService service;

    public OrderItemsController(OrderItemsService service) {
        this.service = service;
    }

    @Operation(summary = "Listar ítems de orden")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<OrderItemsResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener ítem de orden por clave compuesta",
               description = "Requiere orderId y productId para identificar el registro de forma única.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Ítem encontrado"),
        @ApiResponse(responseCode = "400", description = "IDs inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Ítem no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{orderId}/{productId}")
    public ResponseEntity<OrderItemsResponse> getById(
            @Parameter(description = "ID de la orden") @PathVariable UUID orderId,
            @Parameter(description = "ID del producto") @PathVariable UUID productId) {
        return ResponseEntity.ok(service.getById(orderId, productId));
    }

    @Operation(summary = "Agregar ítem a la orden",
               description = "No puede existir ya un ítem con el mismo orderId y productId.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Ítem agregado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Ítem duplicado u datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<OrderItemsResponse> create(
            @Valid @RequestBody OrderItemsRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar cantidad de ítem en orden")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Ítem actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Ítem no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{orderId}/{productId}")
    public ResponseEntity<OrderItemsResponse> update(
            @Parameter(description = "ID de la orden") @PathVariable UUID orderId,
            @Parameter(description = "ID del producto") @PathVariable UUID productId,
            @Valid @RequestBody OrderItemsRequest request) {
        return ResponseEntity.ok(service.update(orderId, productId, request));
    }

    @Operation(summary = "Eliminar ítem de la orden")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Ítem eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Ítem no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{orderId}/{productId}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID de la orden") @PathVariable UUID orderId,
            @Parameter(description = "ID del producto") @PathVariable UUID productId) {
        service.delete(orderId, productId);
        return ResponseEntity.noContent().build();
    }
}
