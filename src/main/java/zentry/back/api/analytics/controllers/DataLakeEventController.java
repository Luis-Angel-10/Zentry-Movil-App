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

import zentry.back.api.analytics.dtos.DataLakeEventRequest;
import zentry.back.api.analytics.dtos.DataLakeEventResponse;
import zentry.back.api.analytics.services.DataLakeEventService;

@RestController
@RequestMapping("/api/analytics/data-lake-events")
@Tag(name = "Data Lake Events", description = "Eventos en bruto (raw) sin procesar hacia el lago de datos")
public class DataLakeEventController {

    private final DataLakeEventService service;

    public DataLakeEventController(DataLakeEventService service) {
        this.service = service;
    }

    // ─── GET /api/analytics/data-lake-events ────────────────────────────────────────────
    @Operation(summary = "Listar eventos del data lake",
               description = "Devuelve un paginado de todos los eventos directos recibidos y almacenados para análisis en frío.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<DataLakeEventResponse>> list(
            @PageableDefault(size = 20, sort = "timestamp", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    // ─── GET /api/analytics/data-lake-events/{id} ───────────────────────────────────────
    @Operation(summary = "Obtener evento raw por ID",
               description = "Retorna toda la data en bruto guardada en el data lake para un ID particular.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro encontrado"),
        @ApiResponse(responseCode = "400", description = "ID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<DataLakeEventResponse> getById(
            @Parameter(description = "ID del evento") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    // ─── POST /api/analytics/data-lake-events ───────────────────────────────────────────
    @Operation(summary = "Registrar evento en el Data Lake",
               description = "Permite enviar JSON arbitrarios y el origen de eventos que requieren ser procesados de manera asíncrona.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Evento recibido y creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos o mal formateados", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<DataLakeEventResponse> create(@Valid @RequestBody DataLakeEventRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    // ─── PUT /api/analytics/data-lake-events/{id} ───────────────────────────────────────
    @Operation(summary = "Actualizar evento en el Data Lake",
               description = "Permite modificar el contenido de un evento raw almacenado (sólo para correcciones de consistencia).")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Evento actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<DataLakeEventResponse> update(
            @Parameter(description = "ID del evento a actualizar") @PathVariable Integer id,
            @Valid @RequestBody DataLakeEventRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    // ─── DELETE /api/analytics/data-lake-events/{id} ────────────────────────────────────
    @Operation(summary = "Eliminar evento del Data Lake",
               description = "Borra físicamente un evento del almacenamiento raw.")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Evento eliminado exitosamente"),
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
