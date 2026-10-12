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

import zentry.back.api.business.dtos.AffiliateProgramRequest;
import zentry.back.api.business.dtos.AffiliateProgramResponse;
import zentry.back.api.business.services.AffiliateProgramService;

import java.util.UUID;

@RestController
@RequestMapping("/api/business/affiliate-program")
@Tag(name = "Affiliate Program", description = "Programa de afiliados — inscripción de usuarios")
public class AffiliateProgramController {

    private final AffiliateProgramService service;

    public AffiliateProgramController(AffiliateProgramService service) {
        this.service = service;
    }

    @Operation(summary = "Listar afiliados")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<AffiliateProgramResponse>> list(
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    @Operation(summary = "Obtener afiliado por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Afiliado encontrado"),
        @ApiResponse(responseCode = "400", description = "UUID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "404", description = "Afiliado no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<AffiliateProgramResponse> getById(
            @Parameter(description = "UUID del registro de afiliado") @PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @Operation(summary = "Inscribir usuario al programa de afiliados",
               description = "Cada usuario solo puede estar inscrito una vez en el programa.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Usuario inscrito exitosamente"),
        @ApiResponse(responseCode = "400", description = "Usuario ya inscrito u datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<AffiliateProgramResponse> create(
            @Valid @RequestBody AffiliateProgramRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @Operation(summary = "Actualizar afiliado")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Afiliado actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "404", description = "Afiliado no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<AffiliateProgramResponse> update(
            @Parameter(description = "UUID del afiliado") @PathVariable UUID id,
            @Valid @RequestBody AffiliateProgramRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    @Operation(summary = "Dar de baja afiliado")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Afiliado eliminado exitosamente"),
        @ApiResponse(responseCode = "404", description = "Afiliado no encontrado", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "UUID del afiliado") @PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
