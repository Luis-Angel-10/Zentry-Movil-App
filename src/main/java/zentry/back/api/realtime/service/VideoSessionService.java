package zentry.back.api.realtime.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.realtime.dtos.VideoSessionRequest;
import zentry.back.api.realtime.dtos.VideoSessionResponse;
import zentry.back.api.realtime.models.VideoSession;
import zentry.back.api.realtime.repositories.VideoSessionRepository;
import zentry.back.api.global.mappers;

@Service
@SuppressWarnings("null")
public class VideoSessionService {

    private final VideoSessionRepository repo;

    public VideoSessionService(VideoSessionRepository repo) {
        this.repo = repo;
    }

    public Page<VideoSessionResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(mappers::toResponse);
    }

    public VideoSessionResponse getById(Integer id) {
        VideoSession entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "VideoSession not found"));
        return mappers.toResponse(entity);
    }

    public VideoSessionResponse create(VideoSessionRequest request) {
        VideoSession entity = VideoSession.builder()
                .quality(request.getQuality())
                .startedAt(request.getStartedAt())
                .build();
        return mappers.toResponse(repo.save(entity));
    }

    public VideoSessionResponse update(Integer id, VideoSessionRequest request) {
        VideoSession entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "VideoSession not found"));
        entity.setQuality(request.getQuality());
        entity.setStartedAt(request.getStartedAt());
        return mappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        VideoSession entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "VideoSession not found"));
        repo.delete(entity);
    }
}
