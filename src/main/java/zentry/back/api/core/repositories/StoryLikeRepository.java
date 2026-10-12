package zentry.back.api.core.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.core.models.StoryLike;

import java.util.List;
import java.util.Optional;

@Repository
public interface StoryLikeRepository extends JpaRepository<StoryLike, Integer> {

    Optional<StoryLike> findByStoryIdAndUserId(Integer storyId, Integer userId);

    boolean existsByStoryIdAndUserId(Integer storyId, Integer userId);

    void deleteByStoryIdAndUserId(Integer storyId, Integer userId);

    long countByStoryId(Integer storyId);

    List<StoryLike> findByStoryId(Integer storyId);
}
