# Zentry Backend API — Claude Code Instructions

## Project Overview
Zentry is a Spring Boot 3.5.13 REST API (Java 17, Maven) that serves as a **social platform + marketplace with AI capabilities**. It uses PostgreSQL (NeonDB) as the primary database, with MongoDB Atlas planned for analytics/realtime.

## Architecture
The project follows a strict **modular layered architecture**: Controller → Service → Repository → Model, with DTOs for data transfer and a centralized mapper class.

```
src/main/java/zentry/back/api/
├── config/          → Security & CORS configuration
├── core/            → Social network module (users, posts, comments, communities, follows)
├── business/        → Marketplace & finance module (wallets, payments, marketplace, subscriptions)
├── ai/              → AI engine module (models, recommendations, predictions, embeddings)
├── analytics/       → Analytics module (MongoDB — not yet implemented)
├── realtime/        → WebSocket module (not yet implemented)
├── common/          → Shared utilities (security, exceptions, utils — placeholders)
└── global/          → Global components (mappers.java, GlobalExceptionHandler.java)
```

## Critical Rules — ALWAYS Follow These

### 1. Package Structure
Every module (`core`, `business`, `ai`) has exactly 5 sub-packages:
- `models/` — JPA entities
- `repositories/` — Spring Data interfaces
- `dtos/` — Request + Response DTOs (always in pairs)
- `services/` — Business logic classes
- `controllers/` — REST endpoints

### 2. Entity Pattern (Model)
```java
package zentry.back.api.{module}.models;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "{table_name}", schema = "zentry_core")  // always use schema
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class EntityName {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;  // Integer, not Long — this project uses Integer IDs

    @Column(name = "column_name", length = 100)  // always specify column name
    private String fieldName;
}
```

**IMPORTANT:**
- IDs are `Integer`, NOT `Long` or `UUID` (except in `business` module which uses `UUID`)
- Always use `@Table(schema = "zentry_core")` for `core` module entities
- Always use `@Table(schema = "zentry_business")` for `business` module entities
- Always use `@Table(schema = "zentry_ia")` for `ai` module entities
- Use Lombok annotations in this exact order: `@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor`
- Foreign keys are stored as plain Integer fields (e.g., `private Integer userId;`), NOT as `@ManyToOne` relations

### 3. Repository Pattern
```java
package zentry.back.api.{module}.repositories;
import zentry.back.api.{module}.models.EntityName;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EntityNameRepository extends JpaRepository<EntityName, Integer> {
}
```

### 4. DTO Pattern
**Request DTO** — with validation:
```java
package zentry.back.api.{module}.dtos;
import jakarta.validation.constraints.*;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class EntityNameRequest {
    @NotBlank
    @Size(max = 50)
    private String fieldName;
}
```

**Response DTO** — no validation:
```java
package zentry.back.api.{module}.dtos;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class EntityNameResponse {
    private Integer id;
    private String fieldName;
}
```

### 5. Service Pattern
```java
package zentry.back.api.{module}.services;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import zentry.back.api.global.mappers;

@Service
public class EntityNameService {
    private final EntityNameRepository repo;

    // Constructor injection (NOT @Autowired)
    public EntityNameService(EntityNameRepository repo) {
        this.repo = repo;
    }

    public Page<EntityNameResponse> list(Pageable pageable) {
        return repo.findAll(pageable).map(mappers::toResponse);
    }

    public EntityNameResponse getById(Integer id) {
        EntityName entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "EntityName not found"));
        return mappers.toResponse(entity);
    }

    public EntityNameResponse create(EntityNameRequest request) {
        EntityName entity = EntityName.builder()
                .fieldName(request.getFieldName())
                .build();
        return mappers.toResponse(repo.save(entity));
    }

    public EntityNameResponse update(Integer id, EntityNameRequest request) {
        EntityName entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "EntityName not found"));
        entity.setFieldName(request.getFieldName());
        return mappers.toResponse(repo.save(entity));
    }

    public void delete(Integer id) {
        EntityName entity = repo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "EntityName not found"));
        repo.delete(entity);
    }
}
```

**IMPORTANT:**
- Use constructor injection, NOT `@Autowired`
- Error handling: throw `ResponseStatusException` with `HttpStatus.NOT_FOUND`
- All list methods return `Page<Response>` with `Pageable`
- All mapping goes through the centralized `mappers` class in `zentry.back.api.global.mappers`

### 6. Controller Pattern
```java
package zentry.back.api.{module}.controllers;
import io.swagger.v3.oas.annotations.*;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.responses.*;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/{module}/{entity-plural}")   // e.g. /api/core/users
@Tag(name = "Entity Name", description = "Gestión de ...")
public class EntityNameController {
    private final EntityNameService service;

    public EntityNameController(EntityNameService service) {
        this.service = service;
    }

    // GET /           → list (paginated, default 20)
    // GET /{id}       → getById
    // POST /          → create (201 Created)
    // PUT /{id}       → update
    // DELETE /{id}    → delete (204 No Content)
}
```

**IMPORTANT:**
- Every method MUST have `@Operation` and `@ApiResponses` Swagger annotations
- URL pattern: `/api/{module}/{entity-plural-kebab-case}`
  - Core: `/api/core/users`, `/api/core/posts`, `/api/core/forum-threads`
  - Business: `/api/business/wallets`, `/api/business/marketplace-products`
  - AI: `/api/ai/ia-models`, `/api/ai/ia-predictions`
- POST returns `HttpStatus.CREATED` (201)
- DELETE returns `ResponseEntity.noContent().build()` (204)
- Pagination: `@PageableDefault(size = 20)`

### 7. Mapper Pattern
All entity-to-DTO mappings live in `zentry.back.api.global.mappers`:
```java
public static EntityNameResponse toResponse(EntityName entity) {
    if (entity == null) return null;
    return EntityNameResponse.builder()
            .id(entity.getId())
            .fieldName(entity.getFieldName())
            .build();
}
```
**When creating a new entity, ALWAYS add its mapper method to `mappers.java`** in the appropriate `#region` section (IA, Business, or Core).

### 8. Test Pattern
```java
@Import(securityConfig.class)
@WebMvcTest(EntityNameController.class)
@DisplayName("EntityNameController")
class EntityNameControllerTest {
    @Autowired MockMvc mvc;
    @Autowired ObjectMapper json;
    @MockBean  EntityNameService service;

    // Nested classes: ListTests, GetByIdTests, CreateTests, UpdateTests, DeleteTests
    // Test naming: methodName_expectedStatus (e.g., list_200, getById_404)
}
```

## Database Configuration
- **PostgreSQL (NeonDB)**: Primary database — credentials via environment variables
- **Schemas**: `zentry_core`, `zentry_business`, `zentry_ia`
- **JPA strategy**: `spring.jpa.hibernate.ddl-auto=update`
- **MongoDB Atlas**: Planned for analytics/realtime modules (currently commented out)

## Key Dependencies
- Spring Boot 3.5.13
- Spring Data JPA + Spring Data MongoDB
- Spring Security (currently permitAll — security not yet implemented)
- Spring WebSocket
- SpringDoc OpenAPI (Swagger UI at /swagger-ui.html)
- Lombok
- PostgreSQL driver
- Java 17

## Things to AVOID
- **DO NOT** use `@Autowired` — use constructor injection
- **DO NOT** use `Long` for IDs — use `Integer` (or `UUID` for business module)
- **DO NOT** return entities directly from controllers — always use DTOs
- **DO NOT** create mapper methods outside of `global/mappers.java`
- **DO NOT** use `@ManyToOne`/`@OneToMany` relations — use plain Integer FK fields
- **DO NOT** put credentials directly in application.properties — use `${ENV_VAR}`
- **DO NOT** use PascalCase for class names that start with lowercase (fix: `securityConfig` → `SecurityConfig`)

## Common Commands
```bash
# Build
./mvnw clean package -DskipTests

# Run
./mvnw spring-boot:run

# Run tests
./mvnw test

# Run specific test
./mvnw test -Dtest=CartControllerTest
```

## Current Security Status
- ⚠️ ALL endpoints are public (`anyRequest().permitAll()`)
- `BCryptPasswordEncoder` is configured but not used
- CSRF is disabled
- CORS allows only `localhost:5173`
- **TODO**: Implement JWT authentication + RBAC authorization
