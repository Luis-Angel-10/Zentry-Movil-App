package zentry.back.api.ai.repositories;

import zentry.back.api.ai.models.IaSimilarityUsers;
import zentry.back.api.ai.models.IaSimilarityUsersId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface IaSimilarityUsersRepository extends JpaRepository<IaSimilarityUsers, IaSimilarityUsersId> {
    List<IaSimilarityUsers> findByUser1(Integer user1);
    List<IaSimilarityUsers> findByUser2(Integer user2);
    List<IaSimilarityUsers> findByUser1OrUser2(Integer user1, Integer user2);
    List<IaSimilarityUsers> findByScoreGreaterThanEqual(BigDecimal score);
    boolean existsByUser1AndUser2(Integer user1, Integer user2);
}
