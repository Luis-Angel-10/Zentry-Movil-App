package zentry.back.api.core.repositories;

import zentry.back.api.core.models.PostLike;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PostLikeRepository extends JpaRepository<PostLike, PostLike.PostLikeId> {
    boolean existsByPostIdAndUserId(Integer postId, Integer userId);
    Optional<PostLike> findByPostIdAndUserId(Integer postId, Integer userId);
    long countByPostId(Integer postId);
    void deleteByPostIdAndUserId(Integer postId, Integer userId);
    List<PostLike> findByUserIdOrderByCreatedAtDesc(Integer userId);
}
