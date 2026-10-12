package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.SystemConfigRequest;
import zentry.back.api.core.dtos.SystemConfigResponse;
import zentry.back.api.core.models.SystemConfig;
import zentry.back.api.core.repositories.SystemConfigRepository;
import zentry.back.api.core.mappers.CoreMappers;

@Service
@SuppressWarnings("null")
public class SystemConfigService {

    private final SystemConfigRepository repo;

    public SystemConfigService(SystemConfigRepository repo) {
        this.repo = repo;
    }

    public Page<SystemConfigResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(CoreMappers::toResponse);
    }

    public SystemConfigResponse getById(Integer id) {
        SystemConfig entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SystemConfig not found"));
        return CoreMappers.toResponse(entity);
    }

    public SystemConfigResponse create(SystemConfigRequest request) {
        SystemConfig entity = SystemConfig.builder()
                .clave(request.getClave())
                .build();
        return CoreMappers.toResponse(repo.save(entity));
    }

    public SystemConfigResponse update(Integer id, SystemConfigRequest request) {
        SystemConfig entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SystemConfig not found"));
        entity.setClave(request.getClave());
        return CoreMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        SystemConfig entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "SystemConfig not found"));
        repo.delete(entity);
    }
}
