# Skill: Implementar Módulo Analytics (MongoDB)

## Descripción
Guía para implementar el módulo de analítica usando MongoDB Atlas como base de datos.

## Contexto
- El paquete `analytics/` existe con sub-paquetes: controllers, documents, dtos, repositories, services
- Todos los archivos actuales son placeholders (`c.java`)
- La dependencia `spring-boot-starter-data-mongodb` ya está en el pom.xml
- La URI de MongoDB está comentada en application.properties

## Instrucciones

### Paso 1: Habilitar MongoDB
Descomentar y configurar en `application.properties`:
```properties
spring.data.mongodb.uri=${MONGO_URI:mongodb+srv://...}
```

### Paso 2: Documento MongoDB (en vez de @Entity)
En `analytics/documents/`:
```java
package zentry.back.api.analytics.documents;

import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;
import java.time.Instant;

@Document(collection = "page_views")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class PageView {

    @Id
    private String id;  // MongoDB usa String IDs (ObjectId)

    @Field("user_id")
    private Integer userId;

    @Field("page")
    private String page;

    @Field("timestamp")
    private Instant timestamp;

    @Field("metadata")
    private Map<String, Object> metadata;  // MongoDB permite campos flexibles
}
```

### Paso 3: Repository MongoDB
```java
package zentry.back.api.analytics.repositories;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;
import zentry.back.api.analytics.documents.PageView;
import java.time.Instant;
import java.util.List;

@Repository
public interface PageViewRepository extends MongoRepository<PageView, String> {
    List<PageView> findByUserId(Integer userId);
    List<PageView> findByTimestampBetween(Instant start, Instant end);
    long countByPage(String page);
}
```

### Paso 4: Documentos Sugeridos para Analytics

| Documento | Campos clave | Uso |
|-----------|-------------|-----|
| `PageView` | userId, page, timestamp, referrer | Tracking de navegación |
| `UserEvent` | userId, eventType, payload, timestamp | Eventos del usuario (clicks, scrolls) |
| `PostAnalytics` | postId, views, shares, avgReadTime | Métricas de posts |
| `SearchQuery` | userId, query, results, timestamp | Historial de búsquedas |
| `SessionLog` | userId, startTime, endTime, pages[] | Sesiones de usuario |

### Paso 5: Diferencias con los módulos JPA

| Aspecto | JPA (core/business/ai) | MongoDB (analytics) |
|---------|------------------------|---------------------|
| Anotación | `@Entity` | `@Document` |
| ID tipo | `Integer` | `String` |
| ID anotación | `@GeneratedValue(IDENTITY)` | Solo `@Id` (auto-generado) |
| Repository | `JpaRepository<E, Integer>` | `MongoRepository<D, String>` |
| Campos | `@Column(name = "x")` | `@Field("x")` |
| Schema | `schema = "zentry_core"` | `collection = "nombre"` |

### Reglas
- Eliminar todos los `c.java` placeholder al implementar
- MongoDB IDs son `String`, no `Integer`
- Los documentos NO van en `models/`, van en `documents/`
- No usar `mappers.java` global para analytics — crear mapper local si es necesario
- Los DTOs siguen el mismo patrón (Request + Response con Lombok)
- Los services y controllers siguen el mismo patrón que los demás módulos
