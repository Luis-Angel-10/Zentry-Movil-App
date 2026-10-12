# Skill: Implementar Seguridad JWT

## Descripción
Guía paso a paso para implementar autenticación JWT en el proyecto Zentry.

## Contexto del Proyecto
- Spring Boot 3.5.13, Java 17
- Ya tiene `spring-boot-starter-security` y `BCryptPasswordEncoder` configurado
- SecurityConfig actual: `anyRequest().permitAll()` (sin protección)
- El paquete `common/security/` existe con un placeholder `c.java`
- El modelo `User` solo tiene: `id`, `username`, `email` (FALTA password y role)

## Instrucciones

### Paso 1: Agregar dependencia JJWT al pom.xml
```xml
<!-- Después de la sección de UTILIDADES -->
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-api</artifactId>
    <version>0.12.6</version>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-impl</artifactId>
    <version>0.12.6</version>
    <scope>runtime</scope>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-jackson</artifactId>
    <version>0.12.6</version>
    <scope>runtime</scope>
</dependency>
```

### Paso 2: Modificar el modelo User
Agregar campos a `core/models/User.java`:
```java
@Column(name = "password_hash")
private String passwordHash;

@Column(name = "role", length = 20)
private String role;  // "USER", "ADMIN", "MODERATOR", "CREATOR"

@Column(name = "enabled")
private Boolean enabled = true;

@Column(name = "created_at")
private LocalDateTime createdAt;
```

### Paso 3: Agregar propiedades JWT
En `application.properties`:
```properties
jwt.secret=${JWT_SECRET:my-super-secret-key-that-is-at-least-256-bits-long-for-hs256}
jwt.expiration=900000
jwt.refresh-expiration=604800000
```

### Paso 4: Crear JwtService
En `common/security/JwtService.java`:
- `generateToken(UserDetails)` → crea access token
- `generateRefreshToken(UserDetails)` → crea refresh token
- `extractUsername(String token)` → extrae el subject
- `isTokenValid(String token, UserDetails)` → valida firma + expiración

### Paso 5: Crear CustomUserDetailsService
En `common/security/CustomUserDetailsService.java`:
- Implementa `UserDetailsService`
- Inyecta `UserRepository`
- Busca por email: `repo.findByEmail(username)`
- Requiere agregar `Optional<User> findByEmail(String email)` al `UserRepository`

### Paso 6: Crear JwtAuthFilter
En `common/security/JwtAuthFilter.java`:
- Extiende `OncePerRequestFilter`
- Extrae token del header `Authorization: Bearer <token>`
- Valida con JwtService
- Establece SecurityContext

### Paso 7: Crear AuthController + AuthService
- `POST /api/auth/register` → RegisterRequest (username, email, password)
- `POST /api/auth/login` → LoginRequest (email, password)
- `POST /api/auth/refresh` → RefreshRequest (refreshToken)

### Paso 8: Modificar SecurityConfig
```java
http
    .csrf(AbstractHttpConfigurer::disable)
    .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
    .authorizeHttpRequests(auth -> auth
        .requestMatchers("/api/auth/**").permitAll()
        .requestMatchers("/swagger-ui/**", "/api-docs/**").permitAll()
        .requestMatchers(HttpMethod.GET, "/api/core/posts/**").permitAll()
        .anyRequest().authenticated()
    )
    .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);
```

### Paso 9: Actualizar DTOs de User
- UserResponse NO debe incluir passwordHash
- Crear AuthRequest y AuthResponse DTOs específicos

### Reglas Importantes
- El placeholder `common/security/c.java` debe ELIMINARSE al crear clases reales
- NUNCA exponer passwordHash en DTOs de respuesta
- Usar `BCryptPasswordEncoder` que YA existe en securityConfig
- Los tokens se firman con HMAC-SHA256 (HS256)
- Access token: 15 minutos, Refresh token: 7 días
