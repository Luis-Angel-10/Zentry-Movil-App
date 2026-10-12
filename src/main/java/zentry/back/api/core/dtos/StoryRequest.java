package zentry.back.api.core.dtos;

import com.fasterxml.jackson.annotation.JsonAlias;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import org.springframework.web.multipart.MultipartFile;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class StoryRequest {

    private Integer userId;

    @JsonAlias({"media_url", "mediaUrl"})
    private String mediaUrl;

    @JsonAlias({"media_type", "type", "mediaType"})
    private String mediaType; // IMAGE, VIDEO, TEXT

    @JsonAlias({"text_content", "textContent"})
    private String textContent;

    @JsonAlias({"text_color", "textColor"})
    private String textColor;

    private String background;

    @JsonAlias({"font_style", "fontStyle"})
    private String fontStyle;

    private String caption;

    @JsonAlias({"music_title", "musicTitle"})
    private String musicTitle;

    @JsonAlias({"music_artist", "musicArtist"})
    private String musicArtist;

    @JsonAlias({"music_url", "musicUrl"})
    private String musicUrl;

    @JsonAlias({"link_url", "linkUrl"})
    private String linkUrl;

    private Integer duration; // in milliseconds

    private MultipartFile file;
}
