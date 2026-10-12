package zentry.back.api.core.dtos;

import zentry.back.api.core.models.ContentType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import java.util.List;

@Getter @Setter @Builder
@NoArgsConstructor @AllArgsConstructor
public class StudioProjectRequest {

    @NotBlank(message = "El título es obligatorio")
    private String title;

    private String description;

    @NotNull(message = "El tipo de contenido es obligatorio")
    private ContentType type;

    private String contentData;

    private String mediaUrl;

    private List<String> tools;

    private Integer rewardCoins;
}
