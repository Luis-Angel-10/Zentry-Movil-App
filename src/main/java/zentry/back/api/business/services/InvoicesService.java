package zentry.back.api.business.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.business.dtos.InvoicesRequest;
import zentry.back.api.business.dtos.InvoicesResponse;
import zentry.back.api.business.models.Invoices;
import zentry.back.api.business.repositories.InvoicesRepository;
import zentry.back.api.business.mappers.BusinessMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class InvoicesService {

    private final InvoicesRepository repo;

    public InvoicesService(InvoicesRepository repo) {
        this.repo = repo;
    }

    public Page<InvoicesResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(BusinessMappers::toResponse);
    }

    public InvoicesResponse getById(UUID id) {
        Invoices entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Invoice not found"));
        return BusinessMappers.toResponse(entity);
    }

    public InvoicesResponse create(InvoicesRequest request) {
        Invoices entity = Invoices.builder()
                .userId(request.getUserId())
                .total(request.getTotal())
                .build();
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public InvoicesResponse update(UUID id, InvoicesRequest request) {
        Invoices entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Invoice not found"));
        entity.setUserId(request.getUserId());
        entity.setTotal(request.getTotal());
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        Invoices entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Invoice not found"));
        repo.delete(entity);
    }
}
