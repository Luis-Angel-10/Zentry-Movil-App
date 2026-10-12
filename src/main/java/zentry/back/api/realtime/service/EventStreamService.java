package zentry.back.api.realtime.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.realtime.dtos.EventStreamRequest;
import zentry.back.api.realtime.dtos.EventStreamResponse;
import zentry.back.api.realtime.models.EventStream;
import zentry.back.api.realtime.repositories.EventStreamRepository;
import zentry.back.api.global.mappers;

@Service
@SuppressWarnings("null")
public class EventStreamService {

    private final EventStreamRepository repo;

    public EventStreamService(EventStreamRepository repo) {
        this.repo = repo;
    }

    public Page<EventStreamResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(mappers::toResponse);
    }

    public EventStreamResponse getById(Integer id) {
        EventStream entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "EventStream not found"));
        return mappers.toResponse(entity);
    }

    public EventStreamResponse create(EventStreamRequest request) {
        EventStream entity = EventStream.builder()
                .type(request.getType())
                .data(request.getData())
                .build();
        return mappers.toResponse(repo.save(entity));
    }

    public EventStreamResponse update(Integer id, EventStreamRequest request) {
        EventStream entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "EventStream not found"));
        entity.setType(request.getType());
        entity.setData(request.getData());
        return mappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        EventStream entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "EventStream not found"));
        repo.delete(entity);
    }
}
