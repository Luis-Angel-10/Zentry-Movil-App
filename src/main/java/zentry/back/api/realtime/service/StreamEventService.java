package zentry.back.api.realtime.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.realtime.dtos.StreamEventRequest;
import zentry.back.api.realtime.dtos.StreamEventResponse;
import zentry.back.api.realtime.models.StreamEvent;
import zentry.back.api.realtime.repositories.StreamEventRepository;
import zentry.back.api.global.mappers;

@Service
@SuppressWarnings("null")
public class StreamEventService {

    private final StreamEventRepository repo;

    public StreamEventService(StreamEventRepository repo) {
        this.repo = repo;
    }

    public Page<StreamEventResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(mappers::toResponse);
    }

    public StreamEventResponse getById(Integer id) {
        StreamEvent entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "StreamEvent not found"));
        return mappers.toResponse(entity);
    }

    public StreamEventResponse create(StreamEventRequest request) {
        StreamEvent entity = StreamEvent.builder()
                .streamId(request.getStreamId())
                .userId(request.getUserId())
                .action(request.getAction())
                .build();
        return mappers.toResponse(repo.save(entity));
    }

    public StreamEventResponse update(Integer id, StreamEventRequest request) {
        StreamEvent entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "StreamEvent not found"));
        entity.setStreamId(request.getStreamId());
        entity.setUserId(request.getUserId());
        entity.setAction(request.getAction());
        return mappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        StreamEvent entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "StreamEvent not found"));
        repo.delete(entity);
    }
}
