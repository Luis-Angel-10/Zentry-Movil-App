package zentry.back.api.core.controllers;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import zentry.back.api.core.dtos.InviteMemberRequest;
import zentry.back.api.core.dtos.NoteRequestDTO;
import zentry.back.api.core.dtos.ProjectLikeResponse;
import zentry.back.api.core.dtos.ProjectMemberResponse;
import zentry.back.api.core.dtos.ProjectRequestDTO;
import zentry.back.api.core.dtos.ResourceRequestDTO;
import zentry.back.api.core.dtos.TaskRequestDTO;
import zentry.back.api.core.models.Project;
import zentry.back.api.core.models.ProjectNote;
import zentry.back.api.core.models.ProjectResource;
import zentry.back.api.core.models.ProjectTask;
import zentry.back.api.core.services.ProjectService;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping({"/api/core/projects", "/api/v1/projects"})
@RequiredArgsConstructor
@Tag(name = "Projects", description = "Gestión de proyectos, tareas, recursos y notas")
public class ProjectController {

    private final ProjectService projectService;

    // GET /api/core/projects -> Lista de proyectos del usuario autenticado
    @GetMapping
    @Operation(summary = "Obtener proyectos del usuario autenticado")
    public ResponseEntity<List<Project>> getProjects(Principal principal) {
        String username = principal != null ? principal.getName() : null;
        return ResponseEntity.ok(projectService.getProjectsByUser(username));
    }

    // GET /api/core/projects/{id} -> Detalle completo del proyecto (solo si es del usuario autenticado)
    @GetMapping("/{id}")
    @Operation(summary = "Detalle completo del proyecto por ID")
    public ResponseEntity<Project> getProjectById(@PathVariable Long id, Principal principal) {
        String username = principal != null ? principal.getName() : null;
        return ResponseEntity.ok(projectService.getProjectById(id, username));
    }

    // POST /api/core/projects -> Crear nuevo proyecto
    @PostMapping
    @Operation(summary = "Crear nuevo proyecto")
    public ResponseEntity<Project> createProject(
            @RequestBody ProjectRequestDTO dto,
            Principal principal) {
        String username = principal != null ? principal.getName() : null;
        return ResponseEntity.ok(projectService.createProject(username, dto));
    }

    // PUT /api/core/projects/{id} -> Actualizar proyecto
    @PutMapping("/{id}")
    @Operation(summary = "Actualizar proyecto existente")
    public ResponseEntity<Project> updateProject(
            @PathVariable Long id,
            @RequestBody ProjectRequestDTO dto,
            Principal principal) {
        String username = principal != null ? principal.getName() : null;
        return ResponseEntity.ok(projectService.updateProject(id, username, dto));
    }

    // DELETE /api/core/projects/{id} -> Eliminar proyecto
    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar proyecto")
    public ResponseEntity<Void> deleteProject(
            @PathVariable Long id,
            Principal principal) {
        String username = principal != null ? principal.getName() : null;
        projectService.deleteProject(id, username);
        return ResponseEntity.noContent().build();
    }

    // POST /api/core/projects/{id}/tasks -> Añadir tarea
    @PostMapping("/{id}/tasks")
    @Operation(summary = "Añadir tarea a un proyecto")
    public ResponseEntity<ProjectTask> addTask(
            @PathVariable Long id,
            @RequestBody TaskRequestDTO dto,
            Principal principal) {
        String username = principal != null ? principal.getName() : null;
        return ResponseEntity.ok(projectService.addTask(id, username, dto));
    }

    // PUT /api/core/projects/{id}/tasks/{taskId}/toggle -> Marcar / desmarcar tarea
    @PutMapping("/{id}/tasks/{taskId}/toggle")
    @Operation(summary = "Alternar estado completado de una tarea")
    public ResponseEntity<ProjectTask> toggleTask(
            @PathVariable Long id,
            @PathVariable Long taskId,
            Principal principal) {
        String username = principal != null ? principal.getName() : null;
        return ResponseEntity.ok(projectService.toggleTask(id, taskId, username));
    }

    // DELETE /api/core/projects/{id}/tasks/{taskId} -> Eliminar tarea
    @DeleteMapping("/{id}/tasks/{taskId}")
    @Operation(summary = "Eliminar tarea de un proyecto")
    public ResponseEntity<Void> deleteTask(
            @PathVariable Long id,
            @PathVariable Long taskId,
            Principal principal) {
        String username = principal != null ? principal.getName() : null;
        projectService.deleteTask(id, taskId, username);
        return ResponseEntity.noContent().build();
    }

    // POST /api/core/projects/{id}/resources -> Añadir recurso (archivo real o enlace externo)
    @PostMapping(value = "/{id}/resources", consumes = { MediaType.APPLICATION_JSON_VALUE, MediaType.MULTIPART_FORM_DATA_VALUE })
    @Operation(summary = "Añadir recurso o archivo a un proyecto",
               description = "Acepta JSON con una URL externa, o multipart con un archivo real que se guarda en el servidor.")
    public ResponseEntity<ProjectResource> addResource(
            @PathVariable Long id,
            @RequestPart(value = "data", required = false) ResourceRequestDTO jsonDto,
            @RequestParam(value = "name", required = false) String nameParam,
            @RequestPart(value = "file", required = false) MultipartFile file,
            Principal principal) {
        String username = principal != null ? principal.getName() : null;
        ResourceRequestDTO dto = jsonDto;
        if (dto == null) {
            dto = new ResourceRequestDTO();
            dto.setName(nameParam);
        }
        return ResponseEntity.ok(projectService.addResource(id, username, dto, file));
    }

    // POST /api/core/projects/{id}/notes -> Añadir nota
    @PostMapping("/{id}/notes")
    @Operation(summary = "Añadir nota o documentación a un proyecto")
    public ResponseEntity<ProjectNote> addNote(
            @PathVariable Long id,
            @RequestBody NoteRequestDTO dto,
            Principal principal) {
        String username = principal != null ? principal.getName() : null;
        return ResponseEntity.ok(projectService.addNote(id, username, dto));
    }

    // GET /api/core/projects/search -> Buscar proyectos (acotado al usuario autenticado)
    @GetMapping("/search")
    @Operation(summary = "Buscar proyectos por término")
    public ResponseEntity<List<Project>> searchProjects(@RequestParam("q") String query, Principal principal) {
        String username = principal != null ? principal.getName() : null;
        return ResponseEntity.ok(projectService.searchProjects(username, query));
    }

    // GET /api/core/projects/{id}/members -> Listar colaboradores
    @GetMapping("/{id}/members")
    @Operation(summary = "Listar colaboradores de un proyecto")
    public ResponseEntity<List<ProjectMemberResponse>> listMembers(@PathVariable Long id, Principal principal) {
        String username = principal != null ? principal.getName() : null;
        return ResponseEntity.ok(projectService.listMembers(id, username));
    }

    // POST /api/core/projects/{id}/invite -> Invitar colaborador (solo el dueño)
    @PostMapping("/{id}/invite")
    @Operation(summary = "Invitar a un usuario a colaborar en el proyecto")
    public ResponseEntity<ProjectMemberResponse> inviteMember(
            @PathVariable Long id,
            @Valid @RequestBody InviteMemberRequest request,
            Principal principal) {
        String username = principal != null ? principal.getName() : null;
        return ResponseEntity.ok(projectService.inviteMember(id, username, request));
    }

    // DELETE /api/core/projects/{id}/members/{username} -> Salir o quitar colaborador
    @DeleteMapping("/{id}/members/{username}")
    @Operation(summary = "Quitar un colaborador o abandonar el proyecto")
    public ResponseEntity<Void> removeMember(
            @PathVariable Long id,
            @PathVariable String username,
            Principal principal) {
        String requester = principal != null ? principal.getName() : null;
        projectService.removeMember(id, requester, username);
        return ResponseEntity.noContent().build();
    }

    // POST /api/core/projects/{id}/like -> Alternar "me gusta"
    @PostMapping("/{id}/like")
    @Operation(summary = "Alternar me gusta en un proyecto")
    public ResponseEntity<ProjectLikeResponse> toggleLike(@PathVariable Long id, Principal principal) {
        String username = principal != null ? principal.getName() : null;
        return ResponseEntity.ok(projectService.toggleLike(id, username));
    }

    // GET /api/core/projects/{id}/like -> Estado de "me gusta"
    @GetMapping("/{id}/like")
    @Operation(summary = "Consultar estado de me gusta")
    public ResponseEntity<ProjectLikeResponse> getLikeStatus(@PathVariable Long id, Principal principal) {
        String username = principal != null ? principal.getName() : null;
        return ResponseEntity.ok(projectService.getLikeStatus(id, username));
    }
}
