package zentry.back.api.analytics.controllers;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import zentry.back.api.analytics.dtos.SearchClickRequest;
import zentry.back.api.analytics.dtos.SearchClickResponse;
import zentry.back.api.analytics.services.SearchClickService;

@RestController
@RequestMapping("/api/analytics/search-clicks")
@Tag(name = "Search Clicks", description = "Análisis de clics en los resultados de búsquedas")
public class SearchClickController {

    private final SearchClickService service;

    public SearchClickController(SearchClickService service) {
        this.service = service;
    }

    // ─── GET /api/analytics/search-clicks ────────────────────────────────────────────
    @Operation(summary = "Listar clics de búsqueda",
               description = "Devuelve una lista paginada con el detalle de qué resultados se clickearon luego de una búsqueda.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<SearchClickResponse>> list(
            @PageableDefault(size = 20, sort = "timestamp", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    // ─── GET /api/analytics/search-clicks/{id} ───────────────────────────────────────
    @Operation(summary = "Obtener clic de búsqueda por ID",
               description = "Retorna el registro detallado de un resultado de búsqueda clickeado.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro encontrado"),
        @ApiResponse(responseCode = "400", description = "ID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<SearchClickResponse> getById(
            @Parameter(description = "ID del registro") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    // ─── POST /api/analytics/search-clicks ───────────────────────────────────────────
    @Operation(summary = "Registrar clic en resultado de búsqueda",
               description = "Almacena la interacción cuando un usuario hace clic en un ítem listado por el buscador.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Registro creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos o faltantes", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<SearchClickResponse> create(@Valid @RequestBody SearchClickRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    // ─── PUT /api/analytics/search-clicks/{id} ───────────────────────────────────────
    @Operation(summary = "Actualizar clic de búsqueda",
               description = "Modifica los detalles del resultado clickeado en una búsqueda guardada.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<SearchClickResponse> update(
            @Parameter(description = "ID del registro a actualizar") @PathVariable Integer id,
            @Valid @RequestBody SearchClickRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    // ─── DELETE /api/analytics/search-clicks/{id} ────────────────────────────────────
    @Operation(summary = "Eliminar clic de búsqueda",
               description = "Borra un registro de clic derivado del motor de búsqueda.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Registro eliminado exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del registro a eliminar") @PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
