package zentry.back.api.analytics.mappers;

import zentry.back.api.analytics.dtos.*;
import zentry.back.api.analytics.models.*;
import java.util.*;

public final class AnalyticsMappers {
    private AnalyticsMappers() {}

    public static zentry.back.api.analytics.dtos.UserBehaviorResponse toResponse(zentry.back.api.analytics.models.UserBehavior entity) {
        if (entity == null) return null;
        return zentry.back.api.analytics.dtos.UserBehaviorResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .type(entity.getType())
                .metadata(entity.getMetadata())
                .timestamp(entity.getTimestamp())
                .build();
    }

    public static zentry.back.api.analytics.dtos.ClickStreamResponse toResponse(zentry.back.api.analytics.models.ClickStream entity) {
        if (entity == null) return null;
        return zentry.back.api.analytics.dtos.ClickStreamResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .element(entity.getElement())
                .page(entity.getPage())
                .timestamp(entity.getTimestamp())
                .build();
    }

    public static zentry.back.api.analytics.dtos.ScrollTrackingResponse toResponse(zentry.back.api.analytics.models.ScrollTracking entity) {
        if (entity == null) return null;
        return zentry.back.api.analytics.dtos.ScrollTrackingResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .page(entity.getPage())
                .depth(entity.getDepth())
                .timestamp(entity.getTimestamp())
                .build();
    }

    public static zentry.back.api.analytics.dtos.HeatmapResponse toResponse(zentry.back.api.analytics.models.Heatmap entity) {
        if (entity == null) return null;
        return zentry.back.api.analytics.dtos.HeatmapResponse.builder()
                .id(entity.getId())
                .page(entity.getPage())
                .clickData(entity.getClickData())
                .recordedAt(entity.getRecordedAt())
                .build();
    }

    public static zentry.back.api.analytics.dtos.SessionTrackingResponse toResponse(zentry.back.api.analytics.models.SessionTracking entity) {
        if (entity == null) return null;
        return zentry.back.api.analytics.dtos.SessionTrackingResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .sessionStart(entity.getSessionStart())
                .sessionEnd(entity.getSessionEnd())
                .durationSec(entity.getDurationSec())
                .build();
    }

    public static zentry.back.api.analytics.dtos.SearchLogResponse toResponse(zentry.back.api.analytics.models.SearchLog entity) {
        if (entity == null) return null;
        return zentry.back.api.analytics.dtos.SearchLogResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .query(entity.getQuery())
                .timestamp(entity.getTimestamp())
                .build();
    }

    public static zentry.back.api.analytics.dtos.SearchClickResponse toResponse(zentry.back.api.analytics.models.SearchClick entity) {
        if (entity == null) return null;
        return zentry.back.api.analytics.dtos.SearchClickResponse.builder()
                .id(entity.getId())
                .searchLogId(entity.getSearchLogId())
                .resultClicked(entity.getResultClicked())
                .timestamp(entity.getTimestamp())
                .build();
    }

    public static zentry.back.api.analytics.dtos.AiTrainingLogResponse toResponse(zentry.back.api.analytics.models.AiTrainingLog entity) {
        if (entity == null) return null;
        return zentry.back.api.analytics.dtos.AiTrainingLogResponse.builder()
                .id(entity.getId())
                .model(entity.getModel())
                .inputData(entity.getInputData())
                .outputData(entity.getOutputData())
                .createdAt(entity.getCreatedAt())
                .build();
    }

    public static zentry.back.api.analytics.dtos.RecommendationLogResponse toResponse(zentry.back.api.analytics.models.RecommendationLog entity) {
        if (entity == null) return null;
        return zentry.back.api.analytics.dtos.RecommendationLogResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .recommendations(entity.getRecommendations())
                .createdAt(entity.getCreatedAt())
                .build();
    }

    public static zentry.back.api.analytics.dtos.ContentPerformanceResponse toResponse(zentry.back.api.analytics.models.ContentPerformance entity) {
        if (entity == null) return null;
        return zentry.back.api.analytics.dtos.ContentPerformanceResponse.builder()
                .id(entity.getId())
                .postId(entity.getPostId())
                .views(entity.getViews())
                .likes(entity.getLikes())
                .recordedAt(entity.getRecordedAt())
                .build();
    }

    public static zentry.back.api.analytics.dtos.EngagementMetricResponse toResponse(zentry.back.api.analytics.models.EngagementMetric entity) {
        if (entity == null) return null;
        return zentry.back.api.analytics.dtos.EngagementMetricResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .score(entity.getScore())
                .recordedAt(entity.getRecordedAt())
                .build();
    }

    public static zentry.back.api.analytics.dtos.RetentionDataResponse toResponse(zentry.back.api.analytics.models.RetentionData entity) {
        if (entity == null) return null;
        return zentry.back.api.analytics.dtos.RetentionDataResponse.builder()
                .id(entity.getId())
                .cohort(entity.getCohort())
                .retentionRate(entity.getRetentionRate())
                .recordedAt(entity.getRecordedAt())
                .build();
    }

    public static zentry.back.api.analytics.dtos.ConversionFunnelResponse toResponse(zentry.back.api.analytics.models.ConversionFunnel entity) {
        if (entity == null) return null;
        return zentry.back.api.analytics.dtos.ConversionFunnelResponse.builder()
                .id(entity.getId())
                .funnelName(entity.getFunnelName())
                .steps(entity.getSteps())
                .conversions(entity.getConversions())
                .recordedAt(entity.getRecordedAt())
                .build();
    }

    public static zentry.back.api.analytics.dtos.FeatureUsageResponse toResponse(zentry.back.api.analytics.models.FeatureUsage entity) {
        if (entity == null) return null;
        return zentry.back.api.analytics.dtos.FeatureUsageResponse.builder()
                .id(entity.getId())
                .feature(entity.getFeature())
                .usageCount(entity.getUsageCount())
                .recordedAt(entity.getRecordedAt())
                .build();
    }

    public static zentry.back.api.analytics.dtos.ErrorTrackingResponse toResponse(zentry.back.api.analytics.models.ErrorTracking entity) {
        if (entity == null) return null;
        return zentry.back.api.analytics.dtos.ErrorTrackingResponse.builder()
                .id(entity.getId())
                .error(entity.getError())
                .stackTrace(entity.getStackTrace())
                .userId(entity.getUserId())
                .timestamp(entity.getTimestamp())
                .build();
    }

    public static zentry.back.api.analytics.dtos.ApiLogResponse toResponse(zentry.back.api.analytics.models.ApiLog entity) {
        if (entity == null) return null;
        return zentry.back.api.analytics.dtos.ApiLogResponse.builder()
                .id(entity.getId())
                .endpoint(entity.getEndpoint())
                .method(entity.getMethod())
                .responseTime(entity.getResponseTime())
                .statusCode(entity.getStatusCode())
                .userId(entity.getUserId())
                .timestamp(entity.getTimestamp())
                .build();
    }

    public static zentry.back.api.analytics.dtos.PerformanceLogResponse toResponse(zentry.back.api.analytics.models.PerformanceLog entity) {
        if (entity == null) return null;
        return zentry.back.api.analytics.dtos.PerformanceLogResponse.builder()
                .id(entity.getId())
                .metric(entity.getMetric())
                .value(entity.getValue())
                .timestamp(entity.getTimestamp())
                .build();
    }

    public static zentry.back.api.analytics.dtos.AbTestResponse toResponse(zentry.back.api.analytics.models.AbTest entity) {
        if (entity == null) return null;
        return zentry.back.api.analytics.dtos.AbTestResponse.builder()
                .id(entity.getId())
                .testName(entity.getTestName())
                .description(entity.getDescription())
                .createdAt(entity.getCreatedAt())
                .build();
    }

    public static zentry.back.api.analytics.dtos.AbTestResultResponse toResponse(zentry.back.api.analytics.models.AbTestResult entity) {
        if (entity == null) return null;
        return zentry.back.api.analytics.dtos.AbTestResultResponse.builder()
                .id(entity.getId())
                .testId(entity.getTestId())
                .variant(entity.getVariant())
                .result(entity.getResult())
                .userId(entity.getUserId())
                .recordedAt(entity.getRecordedAt())
                .build();
    }

    public static zentry.back.api.analytics.dtos.DataLakeEventResponse toResponse(zentry.back.api.analytics.models.DataLakeEvent entity) {
        if (entity == null) return null;
        return zentry.back.api.analytics.dtos.DataLakeEventResponse.builder()
                .id(entity.getId())
                .rawData(entity.getRawData())
                .source(entity.getSource())
                .timestamp(entity.getTimestamp())
                .build();
    }

}
