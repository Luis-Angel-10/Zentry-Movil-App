package zentry.back.api.ai.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.ai.dtos.IaConfigsRequest;
import zentry.back.api.ai.dtos.IaConfigsResponse;
import zentry.back.api.ai.models.IaConfigs;
import zentry.back.api.ai.repositories.IaConfigsRepository;
import zentry.back.api.ai.mappers.IaMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class IaConfigsService {

    private final IaConfigsRepository repo;

    public IaConfigsService(IaConfigsRepository repo) {
        this.repo = repo;
    }

    public Page<IaConfigsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(IaMappers::toResponse);
    }

    public IaConfigsResponse getById(UUID id) {
        IaConfigs entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Config not found"));
        return IaMappers.toResponse(entity);
    }

    public IaConfigsResponse create(IaConfigsRequest request) {
        IaConfigs entity = IaConfigs.builder()
                .modelId(request.getModelId())
                .parametros(request.getParametros())
                .build();
        return IaMappers.toResponse(repo.save(entity));
    }

    public IaConfigsResponse update(UUID id, IaConfigsRequest request) {
        IaConfigs entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Config not found"));
        entity.setModelId(request.getModelId());
        entity.setParametros(request.getParametros());
        return IaMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        IaConfigs entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Config not found"));
        repo.delete(entity);
    }
}
