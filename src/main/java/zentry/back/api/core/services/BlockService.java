package zentry.back.api.core.services;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import zentry.back.api.core.dtos.BlockRequest;
import zentry.back.api.core.dtos.BlockResponse;
import zentry.back.api.core.models.Block;
import zentry.back.api.core.models.Block.BlockId;
import zentry.back.api.core.repositories.BlockRepository;
import zentry.back.api.core.mappers.CoreMappers;

@Service
@SuppressWarnings("null")
public class BlockService {

    private final BlockRepository repo;

    public BlockService(BlockRepository repo) {
        this.repo = repo;
    }

    public Page<BlockResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(CoreMappers::toResponse);
    }

    public BlockResponse getById(Integer userId, Integer blockedId) {
        BlockId id = new BlockId(userId, blockedId);
        Block entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Block not found"));
        return CoreMappers.toResponse(entity);
    }

    public BlockResponse create(BlockRequest request) {
        BlockId id = new BlockId(request.getUserId(), request.getBlockedId());
        if (repo.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Block already exists");
        }
        Block entity = Block.builder()
                .userId(request.getUserId())
                .blockedId(request.getBlockedId())
                .build();
        return CoreMappers.toResponse(repo.save(entity));
    }

    public void delete(Integer userId, Integer blockedId) {
        BlockId id = new BlockId(userId, blockedId);
        Block entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Block not found"));
        repo.delete(entity);
    }
}
