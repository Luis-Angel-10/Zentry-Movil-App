package zentry.back.api.business.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.business.dtos.PaymentMethodsRequest;
import zentry.back.api.business.dtos.PaymentMethodsResponse;
import zentry.back.api.business.models.PaymentMethods;
import zentry.back.api.business.repositories.PaymentMethodsRepository;
import zentry.back.api.business.mappers.BusinessMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class PaymentMethodsService {

    private final PaymentMethodsRepository repo;

    public PaymentMethodsService(PaymentMethodsRepository repo) {
        this.repo = repo;
    }

    public Page<PaymentMethodsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(BusinessMappers::toResponse);
    }

    public PaymentMethodsResponse getById(UUID id) {
        PaymentMethods entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "PaymentMethod not found"));
        return BusinessMappers.toResponse(entity);
    }

    public PaymentMethodsResponse create(PaymentMethodsRequest request) {
        if (repo.existsByUserIdAndMetodo(request.getUserId(), request.getMetodo())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Payment method already registered for this user");
        }
        PaymentMethods entity = PaymentMethods.builder()
                .userId(request.getUserId())
                .metodo(request.getMetodo())
                .build();
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public PaymentMethodsResponse update(UUID id, PaymentMethodsRequest request) {
        PaymentMethods entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "PaymentMethod not found"));
        entity.setUserId(request.getUserId());
        entity.setMetodo(request.getMetodo());
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        PaymentMethods entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "PaymentMethod not found"));
        repo.delete(entity);
    }
}
