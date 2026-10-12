package zentry.back.api.business.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.business.dtos.CommissionsRequest;
import zentry.back.api.business.dtos.CommissionsResponse;
import zentry.back.api.business.models.Commissions;
import zentry.back.api.business.repositories.CommissionsRepository;
import zentry.back.api.business.mappers.BusinessMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class CommissionsService {

    private final CommissionsRepository repo;

    public CommissionsService(CommissionsRepository repo) {
        this.repo = repo;
    }

    public Page<CommissionsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(BusinessMappers::toResponse);
    }

    public CommissionsResponse getById(UUID id) {
        Commissions entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Commission not found"));
        return BusinessMappers.toResponse(entity);
    }

    public CommissionsResponse create(CommissionsRequest request) {
        Commissions entity = Commissions.builder()
                .porcentaje(request.getPorcentaje())
                .build();
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public CommissionsResponse update(UUID id, CommissionsRequest request) {
        Commissions entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Commission not found"));
        entity.setPorcentaje(request.getPorcentaje());
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        Commissions entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Commission not found"));
        repo.delete(entity);
    }
}
