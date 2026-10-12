package zentry.back.api.realtime.repositories;

import zentry.back.api.realtime.models.EditingSessionUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EditingSessionUserRepository extends JpaRepository<EditingSessionUser, EditingSessionUser.EditingSessionUserId> {

}
