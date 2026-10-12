package zentry.back.api.realtime.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.realtime.dtos.PushQueueRequest;
import zentry.back.api.realtime.dtos.PushQueueResponse;
import zentry.back.api.realtime.models.PushQueue;
import zentry.back.api.realtime.repositories.PushQueueRepository;
import zentry.back.api.global.mappers;

@Service
@SuppressWarnings("null")
public class PushQueueService {

    private final PushQueueRepository repo;

    public PushQueueService(PushQueueRepository repo) {
        this.repo = repo;
    }

    public Page<PushQueueResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(mappers::toResponse);
    }

    public PushQueueResponse getById(Integer id) {
        PushQueue entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "PushQueue not found"));
        return mappers.toResponse(entity);
    }

    public PushQueueResponse create(PushQueueRequest request) {
        PushQueue entity = PushQueue.builder()
                .userId(request.getUserId())
                .message(request.getMessage())
                .sent(request.getSent())
                .build();
        return mappers.toResponse(repo.save(entity));
    }

    public PushQueueResponse update(Integer id, PushQueueRequest request) {
        PushQueue entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "PushQueue not found"));
        entity.setUserId(request.getUserId());
        entity.setMessage(request.getMessage());
        entity.setSent(request.getSent());
        return mappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        PushQueue entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "PushQueue not found"));
        repo.delete(entity);
    }
}
