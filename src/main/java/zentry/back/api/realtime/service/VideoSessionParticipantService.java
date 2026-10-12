package zentry.back.api.realtime.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.realtime.dtos.VideoSessionParticipantRequest;
import zentry.back.api.realtime.dtos.VideoSessionParticipantResponse;
import zentry.back.api.realtime.models.VideoSessionParticipant;
import zentry.back.api.realtime.models.VideoSessionParticipant.VideoSessionParticipantId;
import zentry.back.api.realtime.repositories.VideoSessionParticipantRepository;
import zentry.back.api.global.mappers;

@Service
@SuppressWarnings("null")
public class VideoSessionParticipantService {

    private final VideoSessionParticipantRepository repo;

    public VideoSessionParticipantService(VideoSessionParticipantRepository repo) {
        this.repo = repo;
    }

    public Page<VideoSessionParticipantResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(mappers::toResponse);
    }

    public VideoSessionParticipantResponse getById(Integer sessionId, Integer userId) {
        VideoSessionParticipantId id = new VideoSessionParticipantId(sessionId, userId);
        VideoSessionParticipant entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "VideoSessionParticipant not found"));
        return mappers.toResponse(entity);
    }

    public VideoSessionParticipantResponse create(VideoSessionParticipantRequest request) {
        VideoSessionParticipantId id = new VideoSessionParticipantId(request.getSessionId(), request.getUserId());
        if (repo.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "VideoSessionParticipant already exists");
        }
        VideoSessionParticipant entity = VideoSessionParticipant.builder()
                .sessionId(request.getSessionId())
                .userId(request.getUserId())
                .build();
        return mappers.toResponse(repo.save(entity));
    }

    public void delete(Integer sessionId, Integer userId) {
        VideoSessionParticipantId id = new VideoSessionParticipantId(sessionId, userId);
        VideoSessionParticipant entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "VideoSessionParticipant not found"));
        repo.delete(entity);
    }
}
