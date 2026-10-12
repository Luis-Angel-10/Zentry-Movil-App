package zentry.back.api.business.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.business.dtos.SubscriptionsRequest;
import zentry.back.api.business.dtos.SubscriptionsResponse;
import zentry.back.api.business.models.Subscriptions;
import zentry.back.api.business.repositories.SubscriptionsRepository;
import zentry.back.api.business.mappers.BusinessMappers;

import java.util.UUID;

@Service
@SuppressWarnings("null")
public class SubscriptionsService {

    private final SubscriptionsRepository repo;

    public SubscriptionsService(SubscriptionsRepository repo) {
        this.repo = repo;
    }

    public Page<SubscriptionsResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(BusinessMappers::toResponse);
    }

    public SubscriptionsResponse getById(UUID id) {
        Subscriptions entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Subscription not found"));
        return BusinessMappers.toResponse(entity);
    }

    public SubscriptionsResponse create(SubscriptionsRequest request) {
        if (repo.existsByUserIdAndPlanId(request.getUserId(), request.getPlanId())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "User is already subscribed to this plan");
        }
        Subscriptions entity = Subscriptions.builder()
                .userId(request.getUserId())
                .planId(request.getPlanId())
                .build();
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public SubscriptionsResponse update(UUID id, SubscriptionsRequest request) {
        Subscriptions entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Subscription not found"));
        entity.setUserId(request.getUserId());
        entity.setPlanId(request.getPlanId());
        return BusinessMappers.toResponse(repo.save(entity));
    }

    public void delete(UUID id) {
        Subscriptions entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Subscription not found"));
        repo.delete(entity);
    }

    @org.springframework.transaction.annotation.Transactional
    public void cleanUserSubscriptions(Integer userId) {
        if (userId == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "UserId es obligatorio");
        }
        repo.deleteByUserId(userId);
    }
}
