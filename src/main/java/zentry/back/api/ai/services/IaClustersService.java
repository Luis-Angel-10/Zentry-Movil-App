package zentry.back.api.ai.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.ai.dtos.IaClustersRequest;
import zentry.back.api.ai.dtos.IaClustersResponse;
import zentry.back.api.ai.models.IaClusters;
import zentry.back.api.ai.repositories.IaClustersRepository;
import zentry.back.api.ai.mappers.IaMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class IaClustersService {

    private final IaClustersRepository repo;

    public IaClustersService(IaClustersRepository repo) {
        this.repo = repo;
    }

    public Page<IaClustersResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(IaMappers::toResponse);
    }

    public IaClustersResponse getById(UUID id) {
        IaClusters entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Cluster not found"));
        return IaMappers.toResponse(entity);
    }

    public IaClustersResponse create(IaClustersRequest request) {
        if (request.getDescripcion() != null && repo.existsByDescripcion(request.getDescripcion())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Cluster already exists");
        }
        IaClusters entity = IaClusters.builder()
                .descripcion(request.getDescripcion())
                .build();
        return IaMappers.toResponse(repo.save(entity));
    }

    public IaClustersResponse update(UUID id, IaClustersRequest request) {
        IaClusters entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Cluster not found"));
        entity.setDescripcion(request.getDescripcion());
        return IaMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        IaClusters entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Cluster not found"));
        repo.delete(entity);
    }
}
