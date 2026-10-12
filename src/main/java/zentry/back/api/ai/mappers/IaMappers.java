package zentry.back.api.ai.mappers;

import zentry.back.api.ai.dtos.*;
import zentry.back.api.ai.models.*;
import java.util.*;

public final class IaMappers {
    private IaMappers() {}

    public static IaModelsResponse toResponse(IaModels entity) {
        if (entity == null) return null;
        return IaModelsResponse.builder()
                .id(entity.getId())
                .nombre(entity.getNombre())
                .build();
    }

    public static CommunityEmbeddingsResponse toResponse(CommunityEmbeddings entity) {
        if (entity == null) return null;
        return CommunityEmbeddingsResponse.builder()
                .id(entity.getId())
                .communityId(entity.getCommunityId())
                .vector(entity.getVector())
                .build();
    }

    public static ContentEmbeddingsResponse toResponse(ContentEmbeddings entity) {
        if (entity == null) return null;
        return ContentEmbeddingsResponse.builder()
                .id(entity.getId())
                .postId(entity.getPostId())
                .vector(entity.getVector())
                .build();
    }

    public static FeedbackLabelsResponse toResponse(FeedbackLabels entity) {
        if (entity == null) return null;
        return FeedbackLabelsResponse.builder()
                .id(entity.getId())
                .feedbackId(entity.getFeedbackId())
                .etiqueta(entity.getEtiqueta())
                .build();
    }

    public static IaBehaivorAnalitycsResponse toResponse(IaBehaivorAnalitycs entity) {
        if (entity == null) return null;
        return IaBehaivorAnalitycsResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .score(entity.getScore())
                .build();
    }

    public static IaClustersResponse toResponse(IaClusters entity) {
        if (entity == null) return null;
        return IaClustersResponse.builder()
                .id(entity.getId())
                .descripcion(entity.getDescripcion())
                .build();
    }

    public static IaConfigsResponse toResponse(IaConfigs entity) {
        if (entity == null) return null;
        return IaConfigsResponse.builder()
                .id(entity.getId())
                .modelId(entity.getModelId())
                .parametros(entity.getParametros())
                .build();
    }

    public static IaContentGenerationResponse toResponse(IaContentGeneration entity) {
        if (entity == null) return null;
        return IaContentGenerationResponse.builder()
                .id(entity.getId())
                .promptId(entity.getPromptId())
                .resultado(entity.getResultado())
                .build();
    }

    public static IaFeedbackResponse toResponse(IaFeedback entity) {
        if (entity == null) return null;
        return IaFeedbackResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .comentario(entity.getComentario())
                .build();
    }

    public static IaModerationResultsResponse toResponse(IaModerationResults entity) {
        if (entity == null) return null;
        return IaModerationResultsResponse.builder()
                .id(entity.getId())
                .postId(entity.getPostId())
                .resultado(entity.getResultado())
                .build();
    }

    public static IaPredictionsResponse toResponse(IaPredictions entity) {
        if (entity == null) return null;
        return IaPredictionsResponse.builder()
                .id(entity.getId())
                .modelId(entity.getModelId())
                .resultado(entity.getResultado())
                .build();
    }

    public static IaPromptsResponse toResponse(IaPrompts entity) {
        if (entity == null) return null;
        return IaPromptsResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .prompt(entity.getPrompt())
                .build();
    }

    public static IaRecommendationsResponse toResponse(IaRecommendations entity) {
        if (entity == null) return null;
        return IaRecommendationsResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .contenidoId(entity.getContenidoId())
                .score(entity.getScore())
                .build();
    }

    public static IaScoresResponse toResponse(IaScores entity) {
        if (entity == null) return null;
        return IaScoresResponse.builder()
                .id(entity.getId())
                .postId(entity.getPostId())
                .score(entity.getScore())
                .build();
    }

    public static IaSimilarityContentResponse toResponse(IaSimilarityContent entity) {
        if (entity == null) return null;
        return IaSimilarityContentResponse.builder()
                .id(entity.getId())
                .postId1(entity.getPostId1())
                .postId2(entity.getPostId2())
                .score(entity.getScore())
                .build();
    }

    public static IaSimilarityUsersResponse toResponse(IaSimilarityUsers entity) {
        if (entity == null) return null;
        return IaSimilarityUsersResponse.builder()
                .user1(entity.getUser1())
                .user2(entity.getUser2())
                .score(entity.getScore())
                .build();
    }

    public static IaTrainingDataResponse toResponse(IaTrainingData entity) {
        if (entity == null) return null;
        return IaTrainingDataResponse.builder()
                .id(entity.getId())
                .dataInput(entity.getDataInput())
                .dataOutput(entity.getDataOutput())
                .build();
    }

    public static IaTrainingLogsResponse toResponse(IaTrainingLogs entity) {
        if (entity == null) return null;
        return IaTrainingLogsResponse.builder()
                .id(entity.getId())
                .modelId(entity.getModelId())
                .estado(entity.getEstado())
                .fecha(entity.getFecha())
                .build();
    }

    public static IaVersionsResponse toResponse(IaVersions entity) {
        if (entity == null) return null;
        return IaVersionsResponse.builder()
                .id(entity.getId())
                .modelId(entity.getModelId())
                .version(entity.getVersion())
                .build();
    }


    public static PredictionHistoryResponse toResponse(PredictionHistory entity) {
        if (entity == null) return null;
        return PredictionHistoryResponse.builder()
                .id(entity.getId())
                .predictionId(entity.getPredictionId())
                .fecha(entity.getFecha())
                .build();
    }

    public static RecommendationLogsResponse toResponse(RecommendationLogs entity) {
        if (entity == null) return null;
        return RecommendationLogsResponse.builder()
                .id(entity.getId())
                .recommendationId(entity.getRecommendationId())
                .timestamp(entity.getTimestamp())
                .build();
    }

    public static TagEmbeddingsResponse toResponse(TagEmbeddings entity) {
        if (entity == null) return null;
        return TagEmbeddingsResponse.builder()
                .id(entity.getId())
                .tagId(entity.getTagId())
                .vector(entity.getVector())
                .build();
    }

    public static UserEmbeddingsResponse toResponse(UserEmbeddings entity) {
        if (entity == null) return null;
        return UserEmbeddingsResponse.builder()
                .userId(entity.getUserId())
                .vector(entity.getVector())
                .build();
    }
}
