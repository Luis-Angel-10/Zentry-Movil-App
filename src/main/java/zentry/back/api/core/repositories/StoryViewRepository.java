package zentry.back.api.core.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.core.models.StoryView;

import java.util.List;
import java.util.Optional;

@Repository
public interface StoryViewRepository extends JpaRepository<StoryView, Integer> {

    Optional<StoryView> findByStoryIdAndUserId(Integer storyId, Integer userId);

    boolean existsByStoryIdAndUserId(Integer storyId, Integer userId);

    long countByStoryId(Integer storyId);

    List<StoryView> findByStoryId(Integer storyId);

    List<StoryView> findByUserId(Integer userId);
}
