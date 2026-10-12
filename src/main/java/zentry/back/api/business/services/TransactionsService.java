package zentry.back.api.business.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.business.dtos.TransactionsRequest;
import zentry.back.api.business.dtos.TransactionsResponse;
import zentry.back.api.business.models.Transactions;
import zentry.back.api.business.repositories.TransactionsRepository;
import zentry.back.api.business.mappers.BusinessMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class TransactionsService {

    private final TransactionsRepository repo;

    public TransactionsService(TransactionsRepository repo) {
        this.repo = repo;
    }

    public Page<TransactionsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(BusinessMappers::toResponse);
    }

    public TransactionsResponse getById(UUID id) {
        Transactions entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Transaction not found"));
        return BusinessMappers.toResponse(entity);
    }

    public TransactionsResponse create(TransactionsRequest request) {
        Transactions entity = Transactions.builder()
                .userId(request.getUserId())
                .amount(request.getAmount())
                .build();
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public TransactionsResponse update(UUID id, TransactionsRequest request) {
        Transactions entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Transaction not found"));
        entity.setUserId(request.getUserId());
        entity.setAmount(request.getAmount());
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        Transactions entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Transaction not found"));
        repo.delete(entity);
    }
}
