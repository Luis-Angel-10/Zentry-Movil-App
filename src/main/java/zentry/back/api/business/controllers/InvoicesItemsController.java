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

import zentry.back.api.business.dtos.InvoicesItemsRequest;
import zentry.back.api.business.dtos.InvoicesItemsResponse;
import zentry.back.api.business.services.InvoicesItemsService;

import java.util.UUID;

@RestController
@RequestMapping("/api/business/invoice-items")
@Tag(name = "Invoice Items", description = "Líneas de detalle dentro de una factura")
public class InvoicesItemsController {

    private final InvoicesItemsService service;

    public InvoicesItemsController(InvoicesItemsService service) {
        this.service = service;
    }

    @Operation(summary = "Listar ítems de factura")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<InvoicesItemsResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener ítem de factura por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Ítem encontrado"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Ítem no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<InvoicesItemsResponse> getById(
            @Parameter(description = "UUID del ítem de factura") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Agregar ítem a factura")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Ítem agregado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<InvoicesItemsResponse> create(
            @Valid @RequestBody InvoicesItemsRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar ítem de factura")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Ítem actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Ítem no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<InvoicesItemsResponse> update(
            @Parameter(description = "UUID del ítem") @PathVariable UUID id,
            @Valid @RequestBody InvoicesItemsRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar ítem de factura")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Ítem eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Ítem no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "UUID del ítem") @PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
