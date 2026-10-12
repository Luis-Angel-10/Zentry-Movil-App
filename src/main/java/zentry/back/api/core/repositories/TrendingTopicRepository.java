package zentry.back.api.core.repositories;

import zentry.back.api.core.models.TrendingTopic;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TrendingTopicRepository extends JpaRepository<TrendingTopic, Long> {

    List<TrendingTopic> findAllByOrderByPostsCountDesc();

    List<TrendingTopic> findByYearOrderByPostsCountDesc(Integer year);

    List<TrendingTopic> findByHashtagContainingIgnoreCaseOrCategoryContainingIgnoreCaseOrderByPostsCountDesc(String hashtag, String category);

    Optional<TrendingTopic> findByHashtag(String hashtag);
}
