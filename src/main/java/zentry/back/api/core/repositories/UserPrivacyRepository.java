package zentry.back.api.core.repositories;

import zentry.back.api.core.models.UserPrivacy;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserPrivacyRepository extends JpaRepository<UserPrivacy, Integer> {
   
}