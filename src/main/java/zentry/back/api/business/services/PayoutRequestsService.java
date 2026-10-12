package zentry.back.api.business.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.business.dtos.PayoutRequestsRequest;
import zentry.back.api.business.dtos.PayoutRequestsResponse;
import zentry.back.api.business.models.PayoutRequests;
import zentry.back.api.business.repositories.PayoutRequestsRepository;
import zentry.back.api.business.mappers.BusinessMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class PayoutRequestsService {

    private final PayoutRequestsRepository repo;

    public PayoutRequestsService(PayoutRequestsRepository repo) {
        this.repo = repo;
    }

    public Page<PayoutRequestsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(BusinessMappers::toResponse);
    }

    public PayoutRequestsResponse getById(UUID id) {
        PayoutRequests entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "PayoutRequest not found"));
        return BusinessMappers.toResponse(entity);
    }

    public PayoutRequestsResponse create(PayoutRequestsRequest request) {
        PayoutRequests entity = PayoutRequests.builder()
                .userId(request.getUserId())
                .amount(request.getAmount())
                .build();
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public PayoutRequestsResponse update(UUID id, PayoutRequestsRequest request) {
        PayoutRequests entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "PayoutRequest not found"));
        entity.setUserId(request.getUserId());
        entity.setAmount(request.getAmount());
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        PayoutRequests entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "PayoutRequest not found"));
        repo.delete(entity);
    }
}
