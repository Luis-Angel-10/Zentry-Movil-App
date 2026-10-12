package zentry.back.api.business.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.business.dtos.ContractsRequest;
import zentry.back.api.business.dtos.ContractsResponse;
import zentry.back.api.business.models.Contracts;
import zentry.back.api.business.repositories.ContractsRepository;
import zentry.back.api.business.mappers.BusinessMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class ContractsService {

    private final ContractsRepository repo;

    public ContractsService(ContractsRepository repo) {
        this.repo = repo;
    }

    public Page<ContractsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(BusinessMappers::toResponse);
    }

    public ContractsResponse getById(UUID id) {
        Contracts entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Contract not found"));
        return BusinessMappers.toResponse(entity);
    }

    public ContractsResponse create(ContractsRequest request) {
        Contracts entity = Contracts.builder()
                .userId(request.getUserId())
                .detalles(request.getDetalles())
                .build();
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public ContractsResponse update(UUID id, ContractsRequest request) {
        Contracts entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Contract not found"));
        entity.setUserId(request.getUserId());
        entity.setDetalles(request.getDetalles());
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        Contracts entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Contract not found"));
        repo.delete(entity);
    }
}
