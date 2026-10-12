package zentry.back.api.business.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.business.dtos.PaymentsRequest;
import zentry.back.api.business.dtos.PaymentsResponse;
import zentry.back.api.business.models.Payments;
import zentry.back.api.business.repositories.PaymentsRepository;
import zentry.back.api.business.mappers.BusinessMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class PaymentsService {

    private final PaymentsRepository repo;

    public PaymentsService(PaymentsRepository repo) {
        this.repo = repo;
    }

    public Page<PaymentsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(BusinessMappers::toResponse);
    }

    public PaymentsResponse getById(UUID id) {
        Payments entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Payment not found"));
        return BusinessMappers.toResponse(entity);
    }

    public PaymentsResponse create(PaymentsRequest request) {
        Payments entity = Payments.builder()
                .userId(request.getUserId())
                .paymentMethodId(request.getPaymentMethodId())
                .amount(request.getAmount())
                .build();
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public PaymentsResponse update(UUID id, PaymentsRequest request) {
        Payments entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Payment not found"));
        entity.setUserId(request.getUserId());
        entity.setPaymentMethodId(request.getPaymentMethodId());
        entity.setAmount(request.getAmount());
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        Payments entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Payment not found"));
        repo.delete(entity);
    }
}
