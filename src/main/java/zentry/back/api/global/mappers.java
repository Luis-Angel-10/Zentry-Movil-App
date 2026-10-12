package zentry.back.api.global;
//IA
import zentry.back.api.ai.dtos.*;
import zentry.back.api.ai.models.*;

//Business
import zentry.back.api.business.dtos.*;
import zentry.back.api.business.models.*;

//core
import zentry.back.api.core.dtos.*;
import zentry.back.api.core.models.*;

//Realtime models (Notification excluded — conflicts with core)
import zentry.back.api.realtime.models.CollabLiveUpdate;
import zentry.back.api.realtime.models.Conversation;
import zentry.back.api.realtime.models.ConversationParticipant;
import zentry.back.api.realtime.models.EditingChange;
import zentry.back.api.realtime.models.EditingSession;
import zentry.back.api.realtime.models.EditingSessionUser;
import zentry.back.api.realtime.models.EventStream;
import zentry.back.api.realtime.models.LiveComment;
import zentry.back.api.realtime.models.LiveEvent;
import zentry.back.api.realtime.models.Message;
import zentry.back.api.realtime.models.OnlineUser;
import zentry.back.api.realtime.models.PresenceLog;
import zentry.back.api.realtime.models.PushQueue;
import zentry.back.api.realtime.models.RealtimeReaction;
import zentry.back.api.realtime.models.SocketConnection;
import zentry.back.api.realtime.models.StreamEvent;
import zentry.back.api.realtime.models.TypingStatus;
import zentry.back.api.realtime.models.VideoSession;
import zentry.back.api.realtime.models.VideoSessionParticipant;
import zentry.back.api.realtime.models.VoiceSession;
import zentry.back.api.realtime.models.VoiceSessionParticipant;

//Realtime DTOs (NotificationResponse excluded — conflicts with core)
import zentry.back.api.realtime.dtos.CollabLiveUpdateResponse;
import zentry.back.api.realtime.dtos.ConversationResponse;
import zentry.back.api.realtime.dtos.ConversationParticipantResponse;
import zentry.back.api.realtime.dtos.EditingChangeResponse;
import zentry.back.api.realtime.dtos.EditingSessionResponse;
import zentry.back.api.realtime.dtos.EditingSessionUserResponse;
import zentry.back.api.realtime.dtos.EventStreamResponse;
import zentry.back.api.realtime.dtos.LiveCommentResponse;
import zentry.back.api.realtime.dtos.LiveEventResponse;
import zentry.back.api.realtime.dtos.MessageResponse;
import zentry.back.api.realtime.dtos.OnlineUserResponse;
import zentry.back.api.realtime.dtos.PresenceLogResponse;
import zentry.back.api.realtime.dtos.PushQueueResponse;
import zentry.back.api.realtime.dtos.RealtimeReactionResponse;
import zentry.back.api.realtime.dtos.SocketConnectionResponse;
import zentry.back.api.realtime.dtos.StreamEventResponse;
import zentry.back.api.realtime.dtos.TypingStatusResponse;
import zentry.back.api.realtime.dtos.VideoSessionResponse;
import zentry.back.api.realtime.dtos.VideoSessionParticipantResponse;
import zentry.back.api.realtime.dtos.VoiceSessionResponse;
import zentry.back.api.realtime.dtos.VoiceSessionParticipantResponse;

public final class mappers {
    private mappers() {}

    //#region IA

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

    public static TrendingTopicResponse toResponse(TrendingTopic entity) {
        if (entity == null) return null;
        return TrendingTopicResponse.builder()
                .id(entity.getId())
                .hashtag(entity.getHashtag())
                .category(entity.getCategory())
                .postsCount(entity.getPostsCount())
                .isHot(entity.getIsHot())
                .year(entity.getYear())
                .updatedAt(entity.getUpdatedAt())
                .build();
    }

    public static WalletTransactionResponse toResponse(WalletTransaction entity) {
        if (entity == null) return null;
        return WalletTransactionResponse.builder()
                .id(entity.getId())
                .username(entity.getUsername())
                .type(entity.getType())
                .amount(entity.getAmount())
                .description(entity.getDescription())
                .createdAt(entity.getCreatedAt())
                .build();
    }

    public static WalletResponse toResponse(Wallet entity, java.util.List<WalletTransaction> transactions) {
        if (entity == null) return null;
        java.util.List<WalletTransactionResponse> txList = (transactions == null) ? java.util.Collections.emptyList() :
                transactions.stream().map(mappers::toResponse).collect(java.util.stream.Collectors.toList());

        return WalletResponse.builder()
                .id(entity.getId())
                .username(entity.getUsername())
                .balance(entity.getBalance())
                .activePlanId(entity.getActivePlanId())
                .nextBillingDate(entity.getNextBillingDate())
                .transactions(txList)
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

    //#endregion

    //#region Business

    public static WalletsResponse toResponse(Wallets entity) {
        if (entity == null) return null;
        return WalletsResponse.builder()
                .userId(entity.getUserId())
                .balance(entity.getBalance())
                .build();
    }

    public static CartResponse toResponse(Cart entity) {
        if (entity == null) return null;
        return CartResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .build();
    }

    public static CartItemsResponse toResponse(CartItems entity) {
        if (entity == null) return null;
        return CartItemsResponse.builder()
                .cartId(entity.getCartId())
                .productId(entity.getProductId())
                .cantidad(entity.getCantidad())
                .build();
    }

    public static SubscriptionsResponse toResponse(Subscriptions entity) {
        if (entity == null) return null;
        return SubscriptionsResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .planId(entity.getPlanId())
                .build();
    }

    public static SubscriptionPlansResponse toResponse(SubscriptionPlans entity) {
        if (entity == null) return null;
        return SubscriptionPlansResponse.builder()
                .id(entity.getId())
                .name(entity.getName())
                .precio(entity.getPrecio())
                .build();
    }

    public static PaymentMethodsResponse toResponse(PaymentMethods entity) {
        if (entity == null) return null;
        return PaymentMethodsResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .metodo(entity.getMetodo())
                .build();
    }

    public static PaymentsResponse toResponse(Payments entity) {
        if (entity == null) return null;
        return PaymentsResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .paymentMethodId(entity.getPaymentMethodId())
                .amount(entity.getAmount())
                .build();
    }

    public static TransactionsResponse toResponse(Transactions entity) {
        if (entity == null) return null;
        return TransactionsResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .amount(entity.getAmount())
                .build();
    }

    public static WalletTransactionsResponse toResponse(WalletTransactions entity) {
        if (entity == null) return null;
        return WalletTransactionsResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .amount(entity.getAmount())
                .build();
    }

    public static InvoicesResponse toResponse(Invoices entity) {
        if (entity == null) return null;
        return InvoicesResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .total(entity.getTotal())
                .build();
    }

    public static InvoicesItemsResponse toResponse(InvoicesItems entity) {
        if (entity == null) return null;
        return InvoicesItemsResponse.builder()
                .id(entity.getId())
                .invoiceId(entity.getInvoiceId())
                .descripcion(entity.getDescripcion())
                .precio(entity.getPrecio())
                .build();
    }

    public static MarketplaceOrdersResponse toResponse(MarketplaceOrders entity) {
        if (entity == null) return null;
        return MarketplaceOrdersResponse.builder()
                .id(entity.getId())
                .buyerId(entity.getBuyerId())
                .total(entity.getTotal())
                .build();
    }

    public static MarketplaceProductsResponse toResponse(MarketplaceProducts entity) {
        if (entity == null) return null;
        return MarketplaceProductsResponse.builder()
                .id(entity.getId())
                .sellerId(entity.getSellerId())
                .nombre(entity.getNombre())
                .precio(entity.getPrecio())
                .build();
    }

    public static OrderItemsResponse toResponse(OrderItems entity) {
        if (entity == null) return null;
        return OrderItemsResponse.builder()
                .orderId(entity.getOrderId())
                .productId(entity.getProductId())
                .cantidad(entity.getCantidad())
                .build();
    }

    public static PayoutsResponse toResponse(Payouts entity) {
        if (entity == null) return null;
        return PayoutsResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .amount(entity.getAmount())
                .build();
    }

    public static PayoutRequestsResponse toResponse(PayoutRequests entity) {
        if (entity == null) return null;
        return PayoutRequestsResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .amount(entity.getAmount())
                .build();
    }

    public static CommissionsResponse toResponse(Commissions entity) {
        if (entity == null) return null;
        return CommissionsResponse.builder()
                .id(entity.getId())
                .porcentaje(entity.getPorcentaje())
                .build();
    }

    public static CommissionJobsResponse toResponse(CommissionJobs entity) {
        if (entity == null) return null;
        return CommissionJobsResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .descripcion(entity.getDescripcion())
                .build();
    }

    public static AffiliateProgramResponse toResponse(AffiliateProgram entity) {
        if (entity == null) return null;
        return AffiliateProgramResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .build();
    }

    public static AffiliatePayoutsResponse toResponse(AffiliatePayouts entity) {
        if (entity == null) return null;
        return AffiliatePayoutsResponse.builder()
                .id(entity.getId())
                .affiliateId(entity.getAffiliateId())
                .amount(entity.getAmount())
                .build();
    }

    public static DonationsResponse toResponse(Donations entity) {
        if (entity == null) return null;
        return DonationsResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .amount(entity.getAmount())
                .build();
    }

    public static ContractsResponse toResponse(Contracts entity) {
        if (entity == null) return null;
        return ContractsResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .detalles(entity.getDetalles())
                .build();
    }

    public static AdsCampaignsResponse toResponse(AdsCampaigns entity) {
        if (entity == null) return null;
        return AdsCampaignsResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .nombre(entity.getNombre())
                .headline(entity.getHeadline())
                .body(entity.getBody())
                .imageUrl(entity.getImageUrl())
                .linkUrl(entity.getLinkUrl())
                .ctaLabel(entity.getCtaLabel())
                .placement(entity.getPlacement())
                .isActive(entity.getIsActive())
                .build();
    }

    public static AdImpressionsResponse toResponse(AdImpressions entity) {
        if (entity == null) return null;
        return AdImpressionsResponse.builder()
                .id(entity.getId())
                .campaignId(entity.getCampaignId())
                .vistas(entity.getVistas())
                .build();
    }

    //#endregion

    //#region Core

    public static UserResponse toResponse(User entity) {
        if (entity == null) return null;
        return UserResponse.builder()
                .id(entity.getId())
                .username(entity.getHandle())
                .email(entity.getEmail())
                .build();
    }

    /*
    public static ProfileResponse toResponse(Profile entity) {
        if (entity == null) return null;
        return ProfileResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .bio(entity.getBio())
                .build();
    }

    public static PostResponse toResponse(Post entity) {
        if (entity == null) return null;
        return PostResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .contenido(entity.getContenido())
                .build();
    }
    */
   
    public static CommentResponse toResponse(Comment entity) {
        if (entity == null) return null;
        return CommentResponse.builder()
                .id(entity.getId())
                .postId(entity.getPostId())
                .userId(entity.getUserId())
                .build();
    }

    public static CommentReactionResponse toResponse(CommentReaction entity) {
        if (entity == null) return null;
        return CommentReactionResponse.builder()
                .id(entity.getId())
                .commentId(entity.getCommentId())
                .userId(entity.getUserId())
                .build();
    }

    public static CommentReplyResponse toResponse(CommentReply entity) {
        if (entity == null) return null;
        return CommentReplyResponse.builder()
                .id(entity.getId())
                .commentId(entity.getCommentId())
                .build();
    }

    public static StudioProjectResponse toResponse(StudioProject entity) {
        if (entity == null) return null;
        return StudioProjectResponse.builder()
                .id(entity.getId())
                .title(entity.getTitle())
                .description(entity.getDescription())
                .type(entity.getType())
                .contentData(entity.getContentData())
                .mediaUrl(entity.getMediaUrl())
                .tools(entity.getTools())
                .rewardCoins(entity.getRewardCoins())
                .ownerUsername(entity.getOwnerUsername())
                .published(Boolean.TRUE.equals(entity.getPublished()))
                .postId(entity.getPostId())
                .createdAt(entity.getCreatedAt())
                .lastEditedAt(entity.getLastEditedAt())
                .build();
    }

    public static CommunityResponse toResponse(Community entity) {
        if (entity == null) return null;
        return CommunityResponse.builder()
                .id(entity.getId())
                .slug(entity.getSlug())
                .nombre(entity.getNombre())
                .descripcion(entity.getDescripcion())
                .imageUrl(entity.getImageUrl())
                .avatarUrl(entity.getAvatarUrl())
                .bannerUrl(entity.getBannerUrl())
                .categoria(entity.getCategoria())
                .creatorId(entity.getCreatorId())
                .ownerUsername(entity.getOwnerUsername())
                .rules(entity.getRules())
                .createdAt(entity.getCreatedAt())
                .build();
    }

    public static CommunityMemberResponse toResponse(CommunityMember entity) {
        if (entity == null) return null;
        return CommunityMemberResponse.builder()
                .communityId(entity.getCommunityId())
                .userId(entity.getUserId())
                .build();
    }

    public static FollowResponse toResponse(Follow entity) {
        if (entity == null) return null;
        return FollowResponse.builder()
                .follower(entity.getFollower())
                .following(entity.getFollowing())
                .build();
    }

    public static FriendshipResponse toResponse(Friendship entity) {
        if (entity == null) return null;
        return FriendshipResponse.builder()
                .user1(entity.getUser1())
                .user2(entity.getUser2())
                .build();
    }

    public static FriendRequestResponse toResponse(FriendRequest entity) {
        if (entity == null) return null;
        return FriendRequestResponse.builder()
                .id(entity.getId())
                .user1(entity.getUser1())
                .user2(entity.getUser2())
                .build();
    }

    public static BlockResponse toResponse(Block entity) {
        if (entity == null) return null;
        return BlockResponse.builder()
                .userId(entity.getUserId())
                .blockedId(entity.getBlockedId())
                .build();
    }

    public static BookmarkResponse toResponse(Bookmark entity) {
        if (entity == null) return null;
        return BookmarkResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .postId(entity.getPostId())
                .build();
    }

    public static CategoryResponse toResponse(Category entity) {
        if (entity == null) return null;
        return CategoryResponse.builder()
                .id(entity.getId())
                .nombre(entity.getNombre())
                .build();
    }

    public static SubcategoryResponse toResponse(Subcategory entity) {
        if (entity == null) return null;
        return SubcategoryResponse.builder()
                .id(entity.getId())
                .categoriaId(entity.getCategoriaId())
                .build();
    }

    public static TagResponse toResponse(Tag entity) {
        if (entity == null) return null;
        return TagResponse.builder()
                .id(entity.getId())
                .nombre(entity.getNombre())
                .build();
    }

    public static PostTagResponse toResponse(PostTag entity) {
        if (entity == null) return null;
        return PostTagResponse.builder()
                .postId(entity.getPostId())
                .tagId(entity.getTagId())
                .build();
    }

    public static PostMediaResponse toResponse(PostMedia entity) {
        if (entity == null) return null;
        return PostMediaResponse.builder()
                .id(entity.getId())
                .postId(entity.getPostId())
                .url(entity.getUrl())
                .build();
    }

    public static PostVersionResponse toResponse(PostVersion entity) {
        if (entity == null) return null;
        return PostVersionResponse.builder()
                .id(entity.getId())
                .postId(entity.getPostId())
                .contenido(entity.getContenido())
                .build();
    }

    public static MediaResponse toResponse(Media entity) {
        if (entity == null) return null;
        return MediaResponse.builder()
                .id(entity.getId())
                .postId(entity.getPostId())
                .url(entity.getUrl())
                .build();
    }

    public static MentionResponse toResponse(Mention entity) {
        if (entity == null) return null;
        return MentionResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .build();
    }

    public static NotificationResponse toResponse(Notification entity) {
        if (entity == null) return null;
        return NotificationResponse.builder()
                .id(entity.getId())
                .type(entity.getType())
                .content(entity.getContent())
                .sourceUsername(entity.getSourceUsername())
                .sourceAvatarUrl(entity.getSourceAvatarUrl())
                .relatedId(entity.getRelatedId())
                .read(Boolean.TRUE.equals(entity.getRead()))
                .createdAt(entity.getCreatedAt())
                .build();
    }

    public static ReactionResponse toResponse(Reaction entity) {
        if (entity == null) return null;
        return ReactionResponse.builder()
                .id(entity.getId())
                .postId(entity.getPostId())
                .userId(entity.getUserId())
                .build();
    }

    public static ReportResponse toResponse(Report entity) {
        if (entity == null) return null;
        return ReportResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .build();
    }

    public static ShareResponse toResponse(Share entity) {
        if (entity == null) return null;
        return ShareResponse.builder()
                .id(entity.getId())
                .postId(entity.getPostId())
                .userId(entity.getUserId())
                .build();
    }

    public static SeriesResponse toResponse(Series entity) {
        if (entity == null) return null;
        return SeriesResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .build();
    }

    public static SeriesChapterResponse toResponse(SeriesChapter entity) {
        if (entity == null) return null;
        return SeriesChapterResponse.builder()
                .id(entity.getId())
                .seriesId(entity.getSeriesId())
                .build();
    }

    public static AuditLogResponse toResponse(AuditLog entity) {
        if (entity == null) return null;
        return AuditLogResponse.builder()
                .id(entity.getId())
                .accion(entity.getAccion())
                .build();
    }

    public static FeatureFlagResponse toResponse(FeatureFlag entity) {
        if (entity == null) return null;
        return FeatureFlagResponse.builder()
                .id(entity.getId())
                .nombre(entity.getNombre())
                .build();
    }

    public static SystemConfigResponse toResponse(SystemConfig entity) {
        if (entity == null) return null;
        return SystemConfigResponse.builder()
                .id(entity.getId())
                .clave(entity.getClave())
                .build();
    }

    public static LoginHistoryResponse toResponse(LoginHistory entity) {
        if (entity == null) return null;
        return LoginHistoryResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .ip(entity.getIp())
                .build();
    }

    public static UserDeviceResponse toResponse(UserDevice entity) {
        if (entity == null) return null;
        return UserDeviceResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .dispositivo(entity.getDispositivo())
                .build();
    }

    public static UserSessionResponse toResponse(UserSession entity) {
        if (entity == null) return null;
        return UserSessionResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .token(entity.getToken())
                .build();
    }

    public static UserPreferencesResponse toResponse(UserPreferences entity) {
        if (entity == null) return null;
        return UserPreferencesResponse.builder()
                .userId(entity.getUserId())
                .config(entity.getConfig())
                .build();
    }

    public static UserPrivacyResponse toResponse(UserPrivacy entity) {
        if (entity == null) return null;
        return UserPrivacyResponse.builder()
                .userId(entity.getUserId())
                .nivel(entity.getNivel())
                .build();
    }

    public static UserSettingsResponse toResponse(UserSettings entity) {
        if (entity == null) return null;
        return UserSettingsResponse.builder()
                .userId(entity.getUserId())
                .privacidad(entity.getPrivacidad())
                .build();
    }

    public static ForumThreadResponse toResponse(ForumThread entity) {
        if (entity == null) return null;
        return ForumThreadResponse.builder()
                .id(entity.getId())
                .communityId(entity.getCommunityId())
                .build();
    }

    public static ForumReplyResponse toResponse(ForumReply entity) {
        if (entity == null) return null;
        return ForumReplyResponse.builder()
                .id(entity.getId())
                .threadId(entity.getThreadId())
                .build();
    }

    public static AchievementResponse toResponse(Achievement entity) {
        if (entity == null) return null;
        return AchievementResponse.builder()
                .id(entity.getId())
                .title(entity.getTitle())
                .description(entity.getDescription())
                .rewardCoins(entity.getRewardCoins())
                .iconUrl(entity.getIconUrl())
                .requirementType(entity.getRequirementType())
                .requirementValue(entity.getRequirementValue())
                .rarity(entity.getRarity())
                .category(entity.getCategory())
                .isSecret(entity.getIsSecret())
                .secretHint(entity.getSecretHint())
                .progress(0)
                .unlocked(false)
                .build();
    }

    public static MissionResponse toResponse(Mission entity) {
        if (entity == null) return null;
        return MissionResponse.builder()
                .id(entity.getId())
                .title(entity.getTitle())
                .description(entity.getDescription())
                .rewardCoins(entity.getRewardCoins())
                .requirementType(entity.getRequirementType())
                .requirementValue(entity.getRequirementValue())
                .category(entity.getCategory())
                .iconName(entity.getIconName())
                .progress(0)
                .completed(false)
                .build();
    }

    public static StoreItemResponse toResponse(StoreItem entity) {
        if (entity == null) return null;
        return StoreItemResponse.builder()
                .id(entity.getId())
                .name(entity.getName())
                .description(entity.getDescription())
                .type(entity.getType())
                .rarity(entity.getRarity())
                .price(entity.getPrice())
                .imageUrl(entity.getImageUrl())
                .owned(false)
                .build();
    }

    public static ProjectMemberResponse toResponse(ProjectMember entity) {
        if (entity == null) return null;
        return ProjectMemberResponse.builder()
                .projectId(entity.getProjectId())
                .username(entity.getUsername())
                .role(entity.getRole())
                .joinedAt(entity.getJoinedAt())
                .build();
    }

    public static StorePurchaseResponse toResponse(StorePurchase entity) {
        if (entity == null) return null;
        return StorePurchaseResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .storeItemId(entity.getStoreItemId())
                .purchaseDate(entity.getPurchaseDate())
                .build();
    }

    //#endregion

    //#region Realtime

    public static CollabLiveUpdateResponse toResponse(CollabLiveUpdate entity) {
        if (entity == null) return null;
        return CollabLiveUpdateResponse.builder()
                .id(entity.getId())
                .projectId(entity.getProjectId())
                .updateData(entity.getUpdateData())
                .createdAt(entity.getCreatedAt())
                .build();
    }

    public static ConversationResponse toResponse(Conversation entity) {
        if (entity == null) return null;
        return ConversationResponse.builder()
                .id(entity.getId())
                .isGroup(entity.getIsGroup())
                .name(entity.getName())
                .createdBy(entity.getCreatedBy())
                .createdAt(entity.getCreatedAt())
                .lastMessageAt(entity.getLastMessageAt())
                .build();
    }

    public static ConversationParticipantResponse toResponse(ConversationParticipant entity) {
        if (entity == null) return null;
        return ConversationParticipantResponse.builder()
                .conversationId(entity.getConversationId())
                .userId(entity.getUserId())
                .role(entity.getRole())
                .joinedAt(entity.getJoinedAt())
                .lastReadAt(entity.getLastReadAt())
                .build();
    }

    public static EditingChangeResponse toResponse(EditingChange entity) {
        if (entity == null) return null;
        return EditingChangeResponse.builder()
                .id(entity.getId())
                .sessionId(entity.getSessionId())
                .changeData(entity.getChangeData())
                .createdAt(entity.getCreatedAt())
                .build();
    }

    public static EditingSessionResponse toResponse(EditingSession entity) {
        if (entity == null) return null;
        return EditingSessionResponse.builder()
                .id(entity.getId())
                .docId(entity.getDocId())
                .createdAt(entity.getCreatedAt())
                .build();
    }

    public static EditingSessionUserResponse toResponse(EditingSessionUser entity) {
        if (entity == null) return null;
        return EditingSessionUserResponse.builder()
                .sessionId(entity.getSessionId())
                .userId(entity.getUserId())
                .build();
    }

    public static EventStreamResponse toResponse(EventStream entity) {
        if (entity == null) return null;
        return EventStreamResponse.builder()
                .id(entity.getId())
                .type(entity.getType())
                .data(entity.getData())
                .timestamp(entity.getTimestamp())
                .build();
    }

    public static LiveCommentResponse toResponse(LiveComment entity) {
        if (entity == null) return null;
        return LiveCommentResponse.builder()
                .id(entity.getId())
                .postId(entity.getPostId())
                .userId(entity.getUserId())
                .comment(entity.getComment())
                .createdAt(entity.getCreatedAt())
                .build();
    }

    public static LiveEventResponse toResponse(LiveEvent entity) {
        if (entity == null) return null;
        return LiveEventResponse.builder()
                .id(entity.getId())
                .eventType(entity.getEventType())
                .payload(entity.getPayload())
                .createdAt(entity.getCreatedAt())
                .build();
    }

    public static MessageResponse toResponse(Message entity) {
        if (entity == null) return null;
        return MessageResponse.builder()
                .id(entity.getId())
                .conversationId(entity.getConversationId())
                .senderId(entity.getSenderId())
                .content(entity.getContent())
                .type(entity.getType())
                .read(entity.getRead())
                .createdAt(entity.getCreatedAt())
                .build();
    }

    public static zentry.back.api.realtime.dtos.NotificationResponse toResponse(zentry.back.api.realtime.models.Notification entity) {
        if (entity == null) return null;
        return zentry.back.api.realtime.dtos.NotificationResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .type(entity.getType())
                .data(entity.getData())
                .read(entity.getRead())
                .createdAt(entity.getCreatedAt())
                .build();
    }

    public static OnlineUserResponse toResponse(OnlineUser entity) {
        if (entity == null) return null;
        return OnlineUserResponse.builder()
                .userId(entity.getUserId())
                .status(entity.getStatus())
                .lastSeen(entity.getLastSeen())
                .build();
    }

    public static PresenceLogResponse toResponse(PresenceLog entity) {
        if (entity == null) return null;
        return PresenceLogResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .status(entity.getStatus())
                .timestamp(entity.getTimestamp())
                .build();
    }

    public static PushQueueResponse toResponse(PushQueue entity) {
        if (entity == null) return null;
        return PushQueueResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .message(entity.getMessage())
                .sent(entity.getSent())
                .createdAt(entity.getCreatedAt())
                .build();
    }

    public static RealtimeReactionResponse toResponse(RealtimeReaction entity) {
        if (entity == null) return null;
        return RealtimeReactionResponse.builder()
                .id(entity.getId())
                .postId(entity.getPostId())
                .userId(entity.getUserId())
                .reaction(entity.getReaction())
                .createdAt(entity.getCreatedAt())
                .build();
    }

    public static SocketConnectionResponse toResponse(SocketConnection entity) {
        if (entity == null) return null;
        return SocketConnectionResponse.builder()
                .id(entity.getId())
                .userId(entity.getUserId())
                .socketId(entity.getSocketId())
                .connectedAt(entity.getConnectedAt())
                .build();
    }

    public static StreamEventResponse toResponse(StreamEvent entity) {
        if (entity == null) return null;
        return StreamEventResponse.builder()
                .id(entity.getId())
                .streamId(entity.getStreamId())
                .userId(entity.getUserId())
                .action(entity.getAction())
                .createdAt(entity.getCreatedAt())
                .build();
    }

    public static TypingStatusResponse toResponse(TypingStatus entity) {
        if (entity == null) return null;
        return TypingStatusResponse.builder()
                .userId(entity.getUserId())
                .conversationId(entity.getConversationId())
                .isTyping(entity.getIsTyping())
                .updatedAt(entity.getUpdatedAt())
                .build();
    }

    public static VideoSessionResponse toResponse(VideoSession entity) {
        if (entity == null) return null;
        return VideoSessionResponse.builder()
                .id(entity.getId())
                .quality(entity.getQuality())
                .startedAt(entity.getStartedAt())
                .endedAt(entity.getEndedAt())
                .build();
    }

    public static VideoSessionParticipantResponse toResponse(VideoSessionParticipant entity) {
        if (entity == null) return null;
        return VideoSessionParticipantResponse.builder()
                .sessionId(entity.getSessionId())
                .userId(entity.getUserId())
                .build();
    }

    public static VoiceSessionResponse toResponse(VoiceSession entity) {
        if (entity == null) return null;
        return VoiceSessionResponse.builder()
                .id(entity.getId())
                .startedAt(entity.getStartedAt())
                .endedAt(entity.getEndedAt())
                .build();
    }

    public static VoiceSessionParticipantResponse toResponse(VoiceSessionParticipant entity) {
        if (entity == null) return null;
        return VoiceSessionParticipantResponse.builder()
                .sessionId(entity.getSessionId())
                .userId(entity.getUserId())
                .build();
    }

    //#endregion

    //#region Analytics

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

    //#endregion
}