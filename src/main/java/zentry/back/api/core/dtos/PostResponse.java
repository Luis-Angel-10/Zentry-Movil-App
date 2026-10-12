package zentry.back.api.core.dtos;

import java.time.LocalDateTime;
import java.util.List;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class PostResponse {

    private Integer id;

    private String authorUsername;
    private String authorAvatar;
    private String authorName;
    private String authorDiscipline;

    // Datos de la obra
    private String title;
    private String contenido;

    @JsonProperty("content_type")
    private String contentType;

    @JsonProperty("thumbnail_url")
    private String thumbnailUrl;

    @JsonProperty("image_url")
    private String imageUrl;

    private String visibility;
    private Integer communityId;
    private List<String> tools;
    private List<String> mediaUrls;
    private List<String> tags;
    
    // Estadísticas
    private Integer likesCount;
    private Integer commentsCount;
    private Boolean liked;
    private Boolean saved;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @JsonProperty("content")
    public String getContent() {
        return this.contenido;
    }

    @JsonProperty("type")
    public String getType() {
        return this.contentType != null ? this.contentType : "canvas";
    }
}
