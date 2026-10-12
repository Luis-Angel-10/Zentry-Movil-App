package zentry.back.api.ai.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.ai.dtos.IaVersionsRequest;
import zentry.back.api.ai.dtos.IaVersionsResponse;
import zentry.back.api.ai.models.IaVersions;
import zentry.back.api.ai.repositories.IaVersionsRepository;
import zentry.back.api.ai.mappers.IaMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class IaVersionsService {

    private final IaVersionsRepository repo;

    public IaVersionsService(IaVersionsRepository repo) {
        this.repo = repo;
    }

    public Page<IaVersionsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(IaMappers::toResponse);
    }

    public IaVersionsResponse getById(UUID id) {
        IaVersions entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Version not found"));
        return IaMappers.toResponse(entity);
    }

    public IaVersionsResponse create(IaVersionsRequest request) {
        if (repo.existsByModelIdAndVersion(request.getModelId(), request.getVersion())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Version already exists for this model");
        }
        IaVersions entity = IaVersions.builder()
                .modelId(request.getModelId())
                .version(request.getVersion())
                .build();
        return IaMappers.toResponse(repo.save(entity));
    }

    public IaVersionsResponse update(UUID id, IaVersionsRequest request) {
        IaVersions entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Version not found"));
        entity.setModelId(request.getModelId());
        entity.setVersion(request.getVersion());
        return IaMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        IaVersions entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Version not found"));
        repo.delete(entity);
    }
}
