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

import zentry.back.api.business.dtos.SubscriptionPlansRequest;
import zentry.back.api.business.dtos.SubscriptionPlansResponse;
import zentry.back.api.business.services.SubscriptionPlansService;

import java.util.UUID;

@RestController
@RequestMapping("/api/business/subscription-plans")
@Tag(name = "Subscription Plans", description = "Catálogo de planes de suscripción disponibles")
public class SubscriptionPlansController {

    private final SubscriptionPlansService service;

    public SubscriptionPlansController(SubscriptionPlansService service) {
        this.service = service;
    }

    @Operation(summary = "Listar planes de suscripción")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<SubscriptionPlansResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener plan por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Plan encontrado"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Plan no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<SubscriptionPlansResponse> getById(
            @Parameter(description = "UUID del plan") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Crear plan de suscripción",
               description = "El nombre del plan debe ser único en el sistema.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Plan creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Nombre duplicado u datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<SubscriptionPlansResponse> create(
            @Valid @RequestBody SubscriptionPlansRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar plan de suscripción")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Plan actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Plan no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<SubscriptionPlansResponse> update(
            @Parameter(description = "UUID del plan") @PathVariable UUID id,
            @Valid @RequestBody SubscriptionPlansRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar plan de suscripción")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Plan eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Plan no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "UUID del plan") @PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
