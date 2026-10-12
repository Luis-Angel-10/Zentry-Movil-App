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

import zentry.back.api.analytics.dtos.UserBehaviorRequest;
import zentry.back.api.analytics.dtos.UserBehaviorResponse;
import zentry.back.api.analytics.services.UserBehaviorService;

@RestController
@RequestMapping("/api/analytics/user-behavior")
@Tag(name = "User Behavior", description = "CRUD y métricas de acciones genéricas del usuario (scroll, click, share, etc.)")
public class UserBehaviorController {

    private final UserBehaviorService service;

    public UserBehaviorController(UserBehaviorService service) {
        this.service = service;
    }

    // ─── GET /api/analytics/user-behavior ────────────────────────────────────────────
    @Operation(summary = "Listar comportamientos de usuario",
               description = "Devuelve una lista paginada de todos los comportamientos del usuario registrados en el sistema, ordenados por fecha descendente.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "500", description = "Error interno del servidor", content = @Content)
    })
    @GetMapping
    public ResponseEntity<Page<UserBehaviorResponse>> list(
            @PageableDefault(size = 20, sort = "timestamp", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(service.list(pageable));
    }

    // ─── GET /api/analytics/user-behavior/{id} ───────────────────────────────────────
    @Operation(summary = "Obtener comportamiento por ID",
               description = "Retorna un registro de comportamiento de usuario específico dado su ID entero.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro encontrado"),
        @ApiResponse(responseCode = "400", description = "ID con formato inválido", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @GetMapping("/{id}")
    public ResponseEntity<UserBehaviorResponse> getById(
            @Parameter(description = "ID del registro de comportamiento") @PathVariable Integer id) {
        return ResponseEntity.ok(service.getById(id));
    }

    // ─── POST /api/analytics/user-behavior ───────────────────────────────────────────
    @Operation(summary = "Registrar comportamiento de usuario",
               description = "Registra una nueva acción genérica del usuario en la plataforma.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Registro creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos o faltantes", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @PostMapping
    public ResponseEntity<UserBehaviorResponse> create(@Valid @RequestBody UserBehaviorRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    // ─── PUT /api/analytics/user-behavior/{id} ───────────────────────────────────────
    @Operation(summary = "Actualizar comportamiento de usuario",
               description = "Actualiza los datos de un comportamiento existente.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Registro actualizado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Registro no encontrado", content = @Content)
    })
    @PutMapping("/{id}")
    public ResponseEntity<UserBehaviorResponse> update(
            @Parameter(description = "ID del registro a actualizar") @PathVariable Integer id,
            @Valid @RequestBody UserBehaviorRequest request) {
        return ResponseEntity.ok(service.update(id, request));
    }

    // ─── DELETE /api/analytics/user-behavior/{id} ────────────────────────────────────
    @Operation(summary = "Eliminar comportamiento de usuario",
               description = "Elimina permanentemente un registro de comportamiento por su ID.")
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
