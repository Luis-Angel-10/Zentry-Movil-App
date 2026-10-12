package zentry.back.api.realtime.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.realtime.dtos.LiveCommentRequest;
import zentry.back.api.realtime.dtos.LiveCommentResponse;
import zentry.back.api.realtime.models.LiveComment;
import zentry.back.api.realtime.repositories.LiveCommentRepository;
import zentry.back.api.global.mappers;

@Service
@SuppressWarnings("null")
public class LiveCommentService {

    private final LiveCommentRepository repo;

    public LiveCommentService(LiveCommentRepository repo) {
        this.repo = repo;
    }

    public Page<LiveCommentResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(mappers::toResponse);
    }

    public LiveCommentResponse getById(Integer id) {
        LiveComment entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "LiveComment not found"));
        return mappers.toResponse(entity);
    }

    public LiveCommentResponse create(LiveCommentRequest request) {
        LiveComment entity = LiveComment.builder()
                .postId(request.getPostId())
                .userId(request.getUserId())
                .comment(request.getComment())
                .build();
        return mappers.toResponse(repo.save(entity));
    }

    public LiveCommentResponse update(Integer id, LiveCommentRequest request) {
        LiveComment entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "LiveComment not found"));
        entity.setPostId(request.getPostId());
        entity.setUserId(request.getUserId());
        entity.setComment(request.getComment());
        return mappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        LiveComment entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "LiveComment not found"));
        repo.delete(entity);
    }
}
