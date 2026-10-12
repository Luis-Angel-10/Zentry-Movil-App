package zentry.back.api.core.repositories;

import zentry.back.api.core.models.ContentType;
import zentry.back.api.core.models.StudioProject;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StudioProjectRepository extends JpaRepository<StudioProject, Integer> {
    List<StudioProject> findByOwnerUsernameOrderByLastEditedAtDesc(String ownerUsername);
    List<StudioProject> findByOwnerUsernameAndTypeOrderByLastEditedAtDesc(String ownerUsername, ContentType type);
    Optional<StudioProject> findByIdAndOwnerUsername(Integer id, String ownerUsername);
}
