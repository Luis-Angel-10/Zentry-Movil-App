package zentry.back.api.realtime.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.realtime.dtos.LiveEventRequest;
import zentry.back.api.realtime.dtos.LiveEventResponse;
import zentry.back.api.realtime.models.LiveEvent;
import zentry.back.api.realtime.repositories.LiveEventRepository;
import zentry.back.api.global.mappers;

@Service
@SuppressWarnings("null")
public class LiveEventService {

    private final LiveEventRepository repo;

    public LiveEventService(LiveEventRepository repo) {
        this.repo = repo;
    }

    public Page<LiveEventResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(mappers::toResponse);
    }

    public LiveEventResponse getById(Integer id) {
        LiveEvent entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "LiveEvent not found"));
        return mappers.toResponse(entity);
    }

    public LiveEventResponse create(LiveEventRequest request) {
        LiveEvent entity = LiveEvent.builder()
                .eventType(request.getEventType())
                .payload(request.getPayload())
                .build();
        return mappers.toResponse(repo.save(entity));
    }

    public LiveEventResponse update(Integer id, LiveEventRequest request) {
        LiveEvent entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "LiveEvent not found"));
        entity.setEventType(request.getEventType());
        entity.setPayload(request.getPayload());
        return mappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        LiveEvent entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "LiveEvent not found"));
        repo.delete(entity);
    }
}
