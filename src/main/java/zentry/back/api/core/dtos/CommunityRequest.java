package zentry.back.api.core.dtos;

import com.fasterxml.jackson.annotation.JsonAlias;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.util.List;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class CommunityRequest {

    @NotBlank
    @Size(max = 100)
    @JsonAlias({"name", "nombre"})
    private String nombre;

    private String slug;

    @JsonAlias({"category", "categoria"})
    private String categoria;

    @JsonAlias({"description", "descripcion"})
    private String descripcion;

    private String avatarUrl;

    private String bannerUrl;

    private List<String> rules;

    public String getName() {
        return nombre;
    }

    public void setName(String name) {
        this.nombre = name;
    }

    public String getDescription() {
        return descripcion;
    }

    public void setDescription(String description) {
        this.descripcion = description;
    }

    public String getCategory() {
        return categoria;
    }

    public void setCategory(String category) {
        this.categoria = category;
    }
}
