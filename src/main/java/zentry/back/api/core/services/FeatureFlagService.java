package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.FeatureFlagRequest;
import zentry.back.api.core.dtos.FeatureFlagResponse;
import zentry.back.api.core.models.FeatureFlag;
import zentry.back.api.core.repositories.FeatureFlagRepository;
import zentry.back.api.core.mappers.CoreMappers;

@Service
@SuppressWarnings("null")
public class FeatureFlagService {

    private final FeatureFlagRepository repo;

    public FeatureFlagService(FeatureFlagRepository repo) {
        this.repo = repo;
    }

    public Page<FeatureFlagResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(CoreMappers::toResponse);
    }

    public FeatureFlagResponse getById(Integer id) {
        FeatureFlag entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "FeatureFlag not found"));
        return CoreMappers.toResponse(entity);
    }

    public FeatureFlagResponse create(FeatureFlagRequest request) {
        FeatureFlag entity = FeatureFlag.builder()
                .nombre(request.getNombre())
                .build();
        return CoreMappers.toResponse(repo.save(entity));
    }

    public FeatureFlagResponse update(Integer id, FeatureFlagRequest request) {
        FeatureFlag entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "FeatureFlag not found"));
        entity.setNombre(request.getNombre());
        return CoreMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        FeatureFlag entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "FeatureFlag not found"));
        repo.delete(entity);
    }
}
