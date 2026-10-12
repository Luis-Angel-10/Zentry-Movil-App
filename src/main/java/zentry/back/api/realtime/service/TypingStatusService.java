package zentry.back.api.realtime.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.realtime.dtos.TypingStatusRequest;
import zentry.back.api.realtime.dtos.TypingStatusResponse;
import zentry.back.api.realtime.models.TypingStatus;
import zentry.back.api.realtime.models.TypingStatus.TypingStatusId;
import zentry.back.api.realtime.repositories.TypingStatusRepository;
import zentry.back.api.global.mappers;

@Service
@SuppressWarnings("null")
public class TypingStatusService {

    private final TypingStatusRepository repo;

    public TypingStatusService(TypingStatusRepository repo) {
        this.repo = repo;
    }

    public Page<TypingStatusResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(mappers::toResponse);
    }

    public TypingStatusResponse getById(Integer userId, Integer conversationId) {
        TypingStatusId id = new TypingStatusId(userId, conversationId);
        TypingStatus entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "TypingStatus not found"));
        return mappers.toResponse(entity);
    }

    public TypingStatusResponse create(TypingStatusRequest request) {
        TypingStatusId id = new TypingStatusId(request.getUserId(), request.getConversationId());
        if (repo.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "TypingStatus already exists");
        }
        TypingStatus entity = TypingStatus.builder()
                .userId(request.getUserId())
                .conversationId(request.getConversationId())
                .isTyping(request.getIsTyping())
                .build();
        return mappers.toResponse(repo.save(entity));
    }

    public void delete(Integer userId, Integer conversationId) {
        TypingStatusId id = new TypingStatusId(userId, conversationId);
        TypingStatus entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "TypingStatus not found"));
        repo.delete(entity);
    }
}
