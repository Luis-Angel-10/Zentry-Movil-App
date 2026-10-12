package zentry.back.api.core.repositories;

import zentry.back.api.core.models.ProjectLike;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ProjectLikeRepository extends JpaRepository<ProjectLike, ProjectLike.ProjectLikeId> {
    long countByProjectId(Long projectId);
    Optional<ProjectLike> findByProjectIdAndUsername(Long projectId, String username);
    void deleteByProjectId(Long projectId);
}
