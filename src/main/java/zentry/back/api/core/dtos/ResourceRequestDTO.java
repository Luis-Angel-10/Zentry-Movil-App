package zentry.back.api.core.dtos;

import lombok.Data;

@Data
public class ResourceRequestDTO {
    private String name;
    private String type; // "PDF", "FIGMA", "ZIP", "PNG"
    private String size;
    private String url;
}
