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

import zentry.back.api.business.dtos.CartItemsRequest;
import zentry.back.api.business.dtos.CartItemsResponse;
import zentry.back.api.business.services.CartItemsService;

import java.util.UUID;

@RestController
@RequestMapping("/api/business/cart-items")
@Tag(name = "Cart Items", description = "Ítems dentro de un carrito de compra — clave compuesta (cartId + productId)")
public class CartItemsController {

    private final CartItemsService service;

    public CartItemsController(CartItemsService service) {
        this.service = service;
    }

    @Operation(summary = "Listar ítems de carrito", description = "Devuelve lista paginada de todos los ítems en todos los carritos.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<CartItemsResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener ítem de carrito por clave compuesta",
               description = "Requiere tanto cartId como productId para identificar el registro.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Ítem encontrado"),
        @ApiResponse(responseCode = "400", description = "IDs inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Ítem no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{cartId}/{productId}")
    public ResponseEntity<CartItemsResponse> getById(
            @Parameter(description = "ID del carrito") @PathVariable UUID cartId,
            @Parameter(description = "ID del producto") @PathVariable UUID productId) {
        return ResponseEntity.ok(service.getById(cartId, productId));
    }

    @Operation(summary = "Agregar ítem al carrito",
               description = "No puede existir ya un ítem con el mismo cartId y productId.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Ítem agregado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Ítem duplicado u datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<CartItemsResponse> create(
            @Valid @RequestBody CartItemsRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar cantidad de ítem en carrito")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Ítem actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Ítem no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{cartId}/{productId}")
    public ResponseEntity<CartItemsResponse> update(
            @Parameter(description = "ID del carrito") @PathVariable UUID cartId,
            @Parameter(description = "ID del producto") @PathVariable UUID productId,
            @Valid @RequestBody CartItemsRequest request) {
        return ResponseEntity.ok(service.update(cartId, productId, request));
    }

    @Operation(summary = "Eliminar ítem del carrito")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Ítem eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Ítem no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{cartId}/{productId}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del carrito") @PathVariable UUID cartId,
            @Parameter(description = "ID del producto") @PathVariable UUID productId) {
        service.delete(cartId, productId);
        return ResponseEntity.noContent().build();
    }
}
