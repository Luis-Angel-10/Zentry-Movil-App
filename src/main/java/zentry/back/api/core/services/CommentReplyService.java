package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.CommentReplyRequest;
import zentry.back.api.core.dtos.CommentReplyResponse;
import zentry.back.api.core.models.CommentReply;
import zentry.back.api.core.repositories.CommentReplyRepository;
import zentry.back.api.core.mappers.CoreMappers;

@Service
@SuppressWarnings("null")
public class CommentReplyService {

    private final CommentReplyRepository repo;

    public CommentReplyService(CommentReplyRepository repo) {
        this.repo = repo;
    }

    public Page<CommentReplyResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(CoreMappers::toResponse);
    }

    public CommentReplyResponse getById(Integer id) {
        CommentReply entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "CommentReply not found"));
        return CoreMappers.toResponse(entity);
    }

    public CommentReplyResponse create(CommentReplyRequest request) {
        CommentReply entity = CommentReply.builder()
                .commentId(request.getCommentId())
                .build();
        return CoreMappers.toResponse(repo.save(entity));
    }

    public CommentReplyResponse update(Integer id, CommentReplyRequest request) {
        CommentReply entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "CommentReply not found"));
        entity.setCommentId(request.getCommentId());
        return CoreMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        CommentReply entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "CommentReply not found"));
        repo.delete(entity);
    }
}
