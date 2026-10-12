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

import zentry.back.api.business.dtos.AdsCampaignsRequest;
import zentry.back.api.business.dtos.AdsCampaignsResponse;
import zentry.back.api.business.services.AdsCampaignsService;

import java.util.UUID;

@RestController
@RequestMapping("/api/business/ads-campaigns")
@Tag(name = "Ads Campaigns", description = "Campañas publicitarias creadas por usuarios")
public class AdsCampaignsController {

    private final AdsCampaignsService service;

    public AdsCampaignsController(AdsCampaignsService service) {
        this.service = service;
    }

    @Operation(summary = "Obtener anuncios activos para un lugar del front", description = "placement: FEED, SIDEBAR o BOTH (por defecto BOTH).")
    @GetMapping("/active")
    public ResponseEntity<java.util.List<AdsCampaignsResponse>> getActiveAds(
            @RequestParam(value = "placement", required = false) String placement) {
        return ResponseEntity.ok(service.getActiveAds(placement));
    }

    @Operation(summary = "Registrar una impresión (vista) de un anuncio")
    @PostMapping("/{id}/impression")
    public ResponseEntity<Void> recordImpression(@PathVariable UUID id) {
        service.recordImpression(id);
        return ResponseEntity.noContent().build();
    }

    @Operation(summary = "Listar campañas publicitarias")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<AdsCampaignsResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener campaña por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Campaña encontrada"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Campaña no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<AdsCampaignsResponse> getById(
            @Parameter(description = "UUID de la campaña") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Crear campaña publicitaria",
               description = "El mismo usuario no puede crear dos campañas con el mismo nombre.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Campaña creada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Nombre duplicado para el usuario u datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<AdsCampaignsResponse> create(
            @Valid @RequestBody AdsCampaignsRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar campaña publicitaria")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Campaña actualizada exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Campaña no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<AdsCampaignsResponse> update(
            @Parameter(description = "UUID de la campaña") @PathVariable UUID id,
            @Valid @RequestBody AdsCampaignsRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Eliminar campaña publicitaria")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Campaña eliminada exitosamente"),
        @ApiResponse(responseCode = "404", description = "Campaña no encontrada", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "UUID de la campaña") @PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
