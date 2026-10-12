package zentry.back.api.ai.repositories;

import zentry.back.api.ai.models.FeedbackLabels;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface FeedbackLabelsRepository extends JpaRepository<FeedbackLabels, UUID> {
    List<FeedbackLabels> findByFeedbackId(Integer feedbackId);
    List<FeedbackLabels> findByEtiquetaContainingIgnoreCase(String etiqueta);
    boolean existsByFeedbackId(Integer feedbackId);
}
