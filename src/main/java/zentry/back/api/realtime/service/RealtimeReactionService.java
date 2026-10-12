package zentry.back.api.realtime.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.realtime.dtos.RealtimeReactionRequest;
import zentry.back.api.realtime.dtos.RealtimeReactionResponse;
import zentry.back.api.realtime.models.RealtimeReaction;
import zentry.back.api.realtime.repositories.RealtimeReactionRepository;
import zentry.back.api.global.mappers;

@Service
@SuppressWarnings("null")
public class RealtimeReactionService {

    private final RealtimeReactionRepository repo;

    public RealtimeReactionService(RealtimeReactionRepository repo) {
        this.repo = repo;
    }

    public Page<RealtimeReactionResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(mappers::toResponse);
    }

    public RealtimeReactionResponse getById(Integer id) {
        RealtimeReaction entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "RealtimeReaction not found"));
        return mappers.toResponse(entity);
    }

    public RealtimeReactionResponse create(RealtimeReactionRequest request) {
        RealtimeReaction entity = RealtimeReaction.builder()
                .postId(request.getPostId())
                .userId(request.getUserId())
                .reaction(request.getReaction())
                .build();
        return mappers.toResponse(repo.save(entity));
    }

    public RealtimeReactionResponse update(Integer id, RealtimeReactionRequest request) {
        RealtimeReaction entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "RealtimeReaction not found"));
        entity.setPostId(request.getPostId());
        entity.setUserId(request.getUserId());
        entity.setReaction(request.getReaction());
        return mappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        RealtimeReaction entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "RealtimeReaction not found"));
        repo.delete(entity);
    }
}
