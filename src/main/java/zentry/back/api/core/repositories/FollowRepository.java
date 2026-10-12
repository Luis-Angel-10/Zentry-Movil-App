package zentry.back.api.core.repositories;

import zentry.back.api.core.models.Follow;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface FollowRepository extends JpaRepository<Follow, Follow.FollowId> {
    boolean existsByFollowerAndFollowing(Integer follower, Integer following);
    long countByFollowing(Integer following);
    long countByFollower(Integer follower);
    void deleteByFollowerAndFollowing(Integer follower, Integer following);
    java.util.List<Follow> findByFollowing(Integer following);
    java.util.List<Follow> findByFollower(Integer follower);
}