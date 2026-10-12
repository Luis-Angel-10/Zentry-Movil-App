package zentry.back.api.realtime.repositories;

import zentry.back.api.realtime.models.SocketConnection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SocketConnectionRepository extends JpaRepository<SocketConnection, Integer> {

}
