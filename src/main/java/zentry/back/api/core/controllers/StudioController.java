package zentry.back.api.core.controllers;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import zentry.back.api.core.dtos.StudioProjectRequest;
import zentry.back.api.core.dtos.StudioProjectResponse;
import zentry.back.api.core.models.ContentType;
import zentry.back.api.core.services.StudioProjectService;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping({"/api/core/studio", "/api/v1/studio"})
@Tag(name = "Studio", description = "Gestión de proyectos del Estudio Creativo")
public class StudioController {

    private final StudioProjectService service;

    public StudioController(StudioProjectService service) {
        this.service = service;
    }

    @Operation(summary = "Obtener proyectos del usuario autenticado", description = "Devuelve lista de proyectos filtrados opcionalmente por tipo.")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Lista obtenida exitosamente"),
        @ApiResponse(responseCode = "401", description = "No autenticado", content = @Content)
    })
    @GetMapping("/projects")
    public ResponseEntity<List<StudioProjectResponse>> getUserProjects(
            @Parameter(description = "Tipo de contenido (CANVAS, DOCUMENT, IMAGE, VIDEO, AUDIO)")
            @RequestParam(value = "type", required = false) String typeStr,
            Principal principal) {

        ContentType type = null;
        if (typeStr != null && !typeStr.isBlank()) {
            try {
                type = ContentType.valueOf(typeStr.toUpperCase());
            } catch (IllegalArgumentException ignored) {}
        }

        return ResponseEntity.ok(service.getUserProjects(principal.getName(), type));
    }

    @Operation(summary = "Crear nuevo proyecto en el estudio")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "Proyecto creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos inválidos", content = @Content)
    })
    @PostMapping(value = "/projects", consumes = { MediaType.APPLICATION_JSON_VALUE, MediaType.MULTIPART_FORM_DATA_VALUE })
    public ResponseEntity<StudioProjectResponse> createProject(
            @RequestPart(value = "data", required = false) @Valid StudioProjectRequest jsonRequest,
            @RequestParam(value = "title", required = false) String titleParam,
            @RequestParam(value = "description", required = false) String descriptionParam,
            @RequestParam(value = "type", required = false) String typeParam,
            @RequestParam(value = "tools", required = false) List<String> toolsParam,
            @RequestPart(value = "file", required = false) MultipartFile file,
            Principal principal) {

        StudioProjectRequest request = jsonRequest;
        if (request == null) {
            ContentType contentType = ContentType.CANVAS;
            if (typeParam != null && !typeParam.isBlank()) {
                try {
                    contentType = ContentType.valueOf(typeParam.toUpperCase());
                } catch (IllegalArgumentException ignored) {}
            }

            request = StudioProjectRequest.builder()
                    .title(titleParam != null ? titleParam : "Proyecto sin título")
                    .description(descriptionParam)
                    .type(contentType)
                    .tools(toolsParam)
                    .build();
        }

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(service.createProject(principal.getName(), request, file));
    }

    @Operation(summary = "Obtener detalle completo de un proyecto por ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Detalle del proyecto obtenido"),
        @ApiResponse(responseCode = "404", description = "Proyecto no encontrado", content = @Content)
    })
    @GetMapping("/projects/{id}")
    public ResponseEntity<StudioProjectResponse> getProjectDetail(
            @PathVariable Integer id,
            Principal principal) {
        return ResponseEntity.ok(service.getProjectDetail(id, principal.getName()));
    }

    @Operation(summary = "Actualizar proyecto desde el editor / canvas")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Proyecto actualizado exitosamente"),
        @ApiResponse(responseCode = "403", description = "No autorizado", content = @Content),
        @ApiResponse(responseCode = "404", description = "Proyecto no encontrado", content = @Content)
    })
    @PutMapping(value = "/projects/{id}", consumes = { MediaType.APPLICATION_JSON_VALUE, MediaType.MULTIPART_FORM_DATA_VALUE })
    public ResponseEntity<StudioProjectResponse> updateProject(
            @PathVariable Integer id,
            @RequestPart(value = "data", required = false) @Valid StudioProjectRequest jsonRequest,
            @RequestParam(value = "title", required = false) String titleParam,
            @RequestParam(value = "description", required = false) String descriptionParam,
            @RequestParam(value = "contentData", required = false) String contentDataParam,
            @RequestPart(value = "file", required = false) MultipartFile file,
            Principal principal) {

        StudioProjectRequest request = jsonRequest;
        if (request == null) {
            request = StudioProjectRequest.builder()
                    .title(titleParam)
                    .description(descriptionParam)
                    .contentData(contentDataParam)
                    .build();
        }

        return ResponseEntity.ok(service.updateProject(id, principal.getName(), request, file));
    }

    @Operation(summary = "Publicar un proyecto del estudio al feed principal", description = "Crea una publicación real en el feed a partir del proyecto y lo marca como publicado (deja de ser borrador).")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Proyecto publicado exitosamente"),
        @ApiResponse(responseCode = "403", description = "No es el propietario", content = @Content),
        @ApiResponse(responseCode = "404", description = "Proyecto no encontrado", content = @Content)
    })
    @PostMapping("/projects/{id}/publish")
    public ResponseEntity<StudioProjectResponse> publishProject(
            @PathVariable Integer id,
            Principal principal) {
        return ResponseEntity.ok(service.publishProject(id, principal.getName()));
    }

    @Operation(summary = "Eliminar proyecto del estudio")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "Proyecto eliminado exitosamente"),
        @ApiResponse(responseCode = "403", description = "No es el propietario", content = @Content),
        @ApiResponse(responseCode = "404", description = "Proyecto no encontrado", content = @Content)
    })
    @DeleteMapping("/projects/{id}")
    public ResponseEntity<Void> deleteProject(
            @PathVariable Integer id,
            Principal principal) {
        service.deleteProject(id, principal.getName());
        return ResponseEntity.noContent().build();
    }
}
