package zentry.back.api.core.repositories;

import zentry.back.api.core.models.UserSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserSessionRepository extends JpaRepository<UserSession, Integer> {
   
}