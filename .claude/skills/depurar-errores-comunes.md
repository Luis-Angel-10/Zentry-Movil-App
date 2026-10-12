# Skill: Depurar y Resolver Errores Comunes

## Descripción
Guía para diagnosticar y resolver los errores más frecuentes en el proyecto Zentry.

## Errores Comunes y Soluciones

### 1. "Failed to configure a DataSource"
**Causa:** Variables de entorno de BD no configuradas.
**Solución:**
```bash
export DB_URL="jdbc:postgresql://..."
export DB_USER="neondb_owner"
export DB_PASS="..."
```
O configurar en `application-dev.properties` (que está en .gitignore).

### 2. "Error creating bean with name 'entityManagerFactory'"
**Causa:** Conflicto entre JPA y MongoDB autoconfiguración.
**Solución:** Asegurarse de que las entidades JPA y MongoDB estén en paquetes separados.
```java
// En ApiApplication.java, si es necesario:
@SpringBootApplication
@EnableJpaRepositories(basePackages = {
    "zentry.back.api.core.repositories",
    "zentry.back.api.business.repositories",
    "zentry.back.api.ai.repositories"
})
@EnableMongoRepositories(basePackages = {
    "zentry.back.api.analytics.repositories",
    "zentry.back.api.realtime.repositories"
})
```

### 3. "No default constructor for entity" / Lombok no funciona
**Causa:** Lombok no está procesando las anotaciones.
**Solución:** Verificar que el `maven-compiler-plugin` tiene `annotationProcessorPaths` configurado (ya está en el pom.xml).
```bash
./mvnw clean compile
```

### 4. "Ambiguous handler methods mapped"
**Causa:** Dos controllers mapeados a la misma URL.
**Solución:** Verificar `@RequestMapping` de cada controller:
- Core: `/api/core/...`
- Business: `/api/business/...`
- AI: `/api/ai/...`

### 5. "Circular dependency"
**Causa:** Service A inyecta Service B y viceversa.
**Solución:** Usar `@Lazy` en uno de los constructores o refactorizar la lógica a un tercer servicio.

### 6. Tests fallan con 401/403
**Causa:** Falta `@Import(securityConfig.class)` en el test.
**Solución:**
```java
@Import(securityConfig.class)  // SIEMPRE agregar esto
@WebMvcTest(MyController.class)
class MyControllerTest { ... }
```

### 7. "Overloaded method reference toResponse is ambiguous"
**Causa:** Múltiples métodos `toResponse` en `mappers.java` con tipos que Java no puede distinguir.
**Solución:** Usar llamada explícita en vez de method reference:
```java
// En vez de:
.map(mappers::toResponse)
// Usar:
.map(entity -> mappers.toResponse(entity))
```

### 8. "relation does not exist" en PostgreSQL
**Causa:** El schema no existe en la base de datos.
**Solución:**
```sql
CREATE SCHEMA IF NOT EXISTS zentry_core;
CREATE SCHEMA IF NOT EXISTS zentry_business;
CREATE SCHEMA IF NOT EXISTS zentry_ia;
```

### 9. CORS bloqueado
**Causa:** El frontend está en un origen no permitido.
**Solución:** Agregar el origen en `corsConfig.java`:
```java
.allowedOrigins("http://localhost:5173", "http://localhost:3000", "https://tu-dominio.com")
```

### 10. Swagger no carga
**URL correcta:** `http://localhost:8080/swagger-ui.html`
**API docs:** `http://localhost:8080/api-docs`
Si da 404, verificar que la dependencia `springdoc-openapi-starter-webmvc-ui` está en el pom.xml.

## Comandos de Diagnóstico
```bash
# Ver logs detallados
./mvnw spring-boot:run -Dspring-boot.run.arguments=--logging.level.root=DEBUG

# Compilar sin tests (más rápido para debug)
./mvnw clean compile

# Verificar dependencias
./mvnw dependency:tree | grep security

# Verificar puerto en uso
lsof -i :8080
```
