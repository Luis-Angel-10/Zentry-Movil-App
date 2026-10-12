package zentry.back.api.analytics.repositories;

import zentry.back.api.analytics.models.UserBehavior;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserBehaviorRepository extends JpaRepository<UserBehavior, Integer> {
   
}
