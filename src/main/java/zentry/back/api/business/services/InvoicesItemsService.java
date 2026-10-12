package zentry.back.api.business.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.business.dtos.InvoicesItemsRequest;
import zentry.back.api.business.dtos.InvoicesItemsResponse;
import zentry.back.api.business.models.InvoicesItems;
import zentry.back.api.business.repositories.InvoicesItemsRepository;
import zentry.back.api.business.mappers.BusinessMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class InvoicesItemsService {

    private final InvoicesItemsRepository repo;

    public InvoicesItemsService(InvoicesItemsRepository repo) {
        this.repo = repo;
    }

    public Page<InvoicesItemsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(BusinessMappers::toResponse);
    }

    public InvoicesItemsResponse getById(UUID id) {
        InvoicesItems entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "InvoiceItem not found"));
        return BusinessMappers.toResponse(entity);
    }

    public InvoicesItemsResponse create(InvoicesItemsRequest request) {
        InvoicesItems entity = InvoicesItems.builder()
                .invoiceId(request.getInvoiceId())
                .descripcion(request.getDescripcion())
                .precio(request.getPrecio())
                .build();
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public InvoicesItemsResponse update(UUID id, InvoicesItemsRequest request) {
        InvoicesItems entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "InvoiceItem not found"));
        entity.setInvoiceId(request.getInvoiceId());
        entity.setDescripcion(request.getDescripcion());
        entity.setPrecio(request.getPrecio());
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        InvoicesItems entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "InvoiceItem not found"));
        repo.delete(entity);
    }
}
