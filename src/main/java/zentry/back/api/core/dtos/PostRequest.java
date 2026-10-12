package zentry.back.api.core.dtos;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import lombok.*;
import java.util.List;
import org.springframework.web.multipart.MultipartFile;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class PostRequest {

    @NotBlank(message = "El título es obligatorio")
    private String title;

    @JsonAlias({"content", "contenido"})
    private String contenido;

    @JsonAlias({"content_type", "type", "contentType"})
    private String contentType;

    @JsonAlias({"thumbnail_url", "imageBlob", "thumbnailUrl"})
    private String thumbnailUrl;

    @JsonAlias({"image_url", "imageUrl"})
    private String imageUrl;

    private String visibility;

    private List<String> mediaUrls;
    private List<Integer> tagIds;
    private MultipartFile image;
    private MultipartFile[] files;
    private List<MultipartFile> mediaFiles;
    private String tools;
}
