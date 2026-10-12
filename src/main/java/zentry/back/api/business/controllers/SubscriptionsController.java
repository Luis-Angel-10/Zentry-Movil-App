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

import zentry.back.api.business.dtos.SubscriptionsRequest;
import zentry.back.api.business.dtos.SubscriptionsResponse;
import zentry.back.api.business.services.SubscriptionsService;

import java.util.UUID;

@RestController
@RequestMapping("/api/business/subscriptions")
@Tag(name = "Subscriptions", description = "Suscripciones activas de usuarios a planes")
public class SubscriptionsController {

    private final SubscriptionsService service;

    public SubscriptionsController(SubscriptionsService service) {
        this.service = service;
    }

    @Operation(summary = "Listar suscripciones")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<SubscriptionsResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener suscripción por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Suscripción encontrada"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Suscripción no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<SubscriptionsResponse> getById(
            @Parameter(description = "UUID de la suscripción") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Crear suscripción",
               description = "No puede existir ya una suscripción para el mismo userId y planId.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Suscripción creada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Suscripción duplicada u datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<SubscriptionsResponse> create(
            @Valid @RequestBody SubscriptionsRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar suscripción")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Suscripción actualizada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Suscripción no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<SubscriptionsResponse> update(
            @Parameter(description = "UUID de la suscripción") @PathVariable UUID id,
            @Valid @RequestBody SubscriptionsRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar suscripción")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Suscripción eliminada exitosamente"),
        @ApiResponse(responseCode = "404", description = "Suscripción no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "UUID de la suscripción") @PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }

    @Operation(summary = "Limpiar todas las membresías/suscripciones de un usuario")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Membresías del usuario limpiadas exitosamente"),
        @ApiResponse(responseCode = "400", description = "UserId inválido", content = @Content)
    })
    @DeleteMapping("/user/{userId}")
    public ResponseEntity<Void> cleanUserSubscriptions(
            @Parameter(description = "ID interno del usuario") @PathVariable Integer userId) {
        service.cleanUserSubscriptions(userId);
        return ResponseEntity.noContent().build();
    }
}
