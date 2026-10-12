package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.AuditLogRequest;
import zentry.back.api.core.dtos.AuditLogResponse;
import zentry.back.api.core.models.AuditLog;
import zentry.back.api.core.repositories.AuditLogRepository;
import zentry.back.api.core.mappers.CoreMappers;

@Service
@SuppressWarnings("null")
public class AuditLogService {

    private final AuditLogRepository repo;

    public AuditLogService(AuditLogRepository repo) {
        this.repo = repo;
    }

    public Page<AuditLogResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(CoreMappers::toResponse);
    }

    public AuditLogResponse getById(Integer id) {
        AuditLog entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "AuditLog not found"));
        return CoreMappers.toResponse(entity);
    }

    public AuditLogResponse create(AuditLogRequest request) {
        AuditLog entity = AuditLog.builder()
                .accion(request.getAccion())
                .build();
        return CoreMappers.toResponse(repo.save(entity));
    }

    public AuditLogResponse update(Integer id, AuditLogRequest request) {
        AuditLog entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "AuditLog not found"));
        entity.setAccion(request.getAccion());
        return CoreMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        AuditLog entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "AuditLog not found"));
        repo.delete(entity);
    }
}
