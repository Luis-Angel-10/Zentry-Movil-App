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

import zentry.back.api.analytics.dtos.SearchLogRequest;
import zentry.back.api.analytics.dtos.SearchLogResponse;
import zentry.back.api.analytics.services.SearchLogService;

@RestController
@RequestMapping("/api/analytics/search-logs")
@Tag(name = "Search Logs", description = "Historial de términos de búsqueda usados en el motor")
public class SearchLogController {

    private final SearchLogService service;

    public SearchLogController(SearchLogService service) {
        this.service = service;
    }

    // ─── GET /api/analytics/search-logs ────────────────────────────────────────────
    @Operation(summary = "Listar búsquedas",
               description = "Devuelve una lista paginada del historial de búsquedas realizadas, ordenado por fecha de captura.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<SearchLogResponse>> list(
            @PageableDefault(size = 20, sort = "timestamp", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    // ─── GET /api/analytics/search-logs/{id} ───────────────────────────────────────
    @Operation(summary = "Obtener búsqueda por ID",
               description = "Retorna un evento de búsqueda dado su identificador único.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro encontrado"),
        @ApiResponse(responseCode = "400", description = "ID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<SearchLogResponse> getById(
            @Parameter(description = "ID del evento de búsqueda") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    // ─── POST /api/analytics/search-logs ───────────────────────────────────────────
    @Operation(summary = "Registrar nueva búsqueda",
               description = "Registra un término buscado por el usuario en el historial.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Registro creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos o faltantes", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<SearchLogResponse> create(@Valid @RequestBody SearchLogRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    // ─── PUT /api/analytics/search-logs/{id} ───────────────────────────────────────
    @Operation(summary = "Actualizar término de búsqueda",
               description = "Modifica la query buscada en un evento ya existente.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<SearchLogResponse> update(
            @Parameter(description = "ID de la búsqueda a actualizar") @PathVariable Integer id,
            @Valid @RequestBody SearchLogRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    // ─── DELETE /api/analytics/search-logs/{id} ────────────────────────────────────
    @Operation(summary = "Eliminar evento de búsqueda",
               description = "Borra permanentemente un log de búsqueda del sistema.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Registro eliminado exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @Parameter(description = "ID del evento a eliminar") @PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
