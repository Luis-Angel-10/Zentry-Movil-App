# 🔐 Informe de Seguridad — Proyecto Zentry

> **Fecha:** 9 de junio de 2026
> **Proyecto:** Zentry Backend API
> **Stack:** Spring Boot 3.5.13 · Java 17 · PostgreSQL (NeonDB) · Maven
> **Autor:** Generado por análisis automatizado

---

## Tabla de Contenido

1. [Resumen Ejecutivo](#1-resumen-ejecutivo)
2. [Arquitectura Actual del Proyecto](#2-arquitectura-actual-del-proyecto)
3. [Inventario de Módulos y Componentes](#3-inventario-de-módulos-y-componentes)
4. [Análisis de Vulnerabilidades](#4-análisis-de-vulnerabilidades)
5. [Opciones de Implementación de Seguridad](#5-opciones-de-implementación-de-seguridad)
6. [Tabla Comparativa de Opciones](#6-tabla-comparativa-de-opciones)
7. [Medidas de Seguridad Complementarias](#7-medidas-de-seguridad-complementarias)
8. [Plan de Acción Priorizado](#8-plan-de-acción-priorizado)
9. [Checklist de Seguridad](#9-checklist-de-seguridad)

---

## 1. Resumen Ejecutivo

Zentry es una API REST que funciona como **plataforma social + marketplace con capacidades de IA**.
El proyecto cuenta con **529 archivos Java**, organizados en una arquitectura modular de 8 paquetes.
Actualmente **no cuenta con ningún mecanismo de autenticación ni autorización activo**, lo que
representa un riesgo crítico si se despliega en un ambiente público.

### Estadísticas Clave

| Métrica                  | Valor       |
|--------------------------|-------------|
| Total archivos Java      | 529         |
| Modelos / Entidades      | 86          |
| Controladores REST       | 87          |
| Servicios                | 86          |
| Repositorios             | 87          |
| DTOs (Request+Response)  | 172         |
| Tests existentes         | 27          |
| Endpoints públicos       | **TODOS**   |
| Endpoints protegidos     | **NINGUNO** |
| Mecanismo de auth activo | **NINGUNO** |

---

## 2. Arquitectura Actual del Proyecto

```
zentry/
├── src/main/java/zentry/back/api/
│   ├── ApiApplication.java              ← Entry point
│   ├── config/
│   │   ├── securityConfig.java          ← Spring Security (TODO: permitAll)
│   │   └── corsConfig.java              ← CORS (solo localhost:5173)
│   ├── core/                            ← 🟢 MÓDULO PRINCIPAL - Red Social
│   │   ├── models/      (38 entidades)
│   │   ├── repositories/ (38 repos)
│   │   ├── services/     (38 servicios)
│   │   ├── controllers/  (38 endpoints)
│   │   └── dtos/         (76 DTOs)
│   ├── business/                        ← 🟢 Marketplace & Finanzas
│   │   ├── models/      (24 entidades)
│   │   ├── repositories/ (24 repos)
│   │   ├── services/     (24 servicios)
│   │   ├── controllers/  (24 endpoints)
│   │   └── dtos/         (48 DTOs)
│   ├── ai/                              ← 🟢 Motor de IA
│   │   ├── models/      (24 entidades)
│   │   ├── repositories/ (24 repos)
│   │   ├── services/     (24 servicios)
│   │   ├── controllers/  (24 endpoints)
│   │   └── dtos/         (48 DTOs)
│   ├── analytics/                       ← 🟡 Vacío (placeholders)
│   ├── realtime/                        ← 🟡 Vacío (WebSocket preparado)
│   ├── common/
│   │   ├── security/    (placeholder)
│   │   ├── exceptions/  (placeholder)
│   │   └── utils/       (placeholder)
│   └── global/
│       ├── mappers.java                 ← 772 líneas de mapeo Entity→DTO
│       └── GlobalExceptionHandler.java  ← Manejo centralizado de errores
└── src/main/resources/
    └── application.properties           ← ⚠️ Credenciales en texto plano
```

### Flujo Actual de una Petición HTTP

```
Cliente → HTTP Request → Controller → Service → Repository → PostgreSQL
                ↑                         ↑
           Sin filtro JWT           Sin validación
           Sin autenticación        de ownership
           Sin autorización         Sin auditoría
```

---

## 3. Inventario de Módulos y Componentes

### 3.1 Módulo Core — Red Social

Funcionalidades sociales completas:

| Área               | Entidades                                              |
|--------------------|--------------------------------------------------------|
| Usuarios           | User, Profile, UserPreferences, UserPrivacy, UserSettings |
| Sesiones           | UserSession, LoginHistory, UserDevice                  |
| Contenido          | Post, PostMedia, PostVersion, PostTag, Media           |
| Interacciones      | Comment, CommentReply, CommentReaction, Reaction       |
| Social             | Follow, Friendship, FriendRequest, Block               |
| Comunidades        | Community, CommunityMember, ForumThread, ForumReply    |
| Descubrimiento     | Bookmark, Share, Mention, Notification                 |
| Taxonomía          | Category, Subcategory, Tag                             |
| Series             | Series, SeriesChapter                                  |
| Admin              | Report, AuditLog, FeatureFlag, SystemConfig            |

### 3.2 Módulo Business — Marketplace y Finanzas

| Área               | Entidades                                              |
|--------------------|--------------------------------------------------------|
| Billetera          | Wallets, WalletTransactions                            |
| Carrito            | Cart, CartItems                                        |
| Marketplace        | MarketplaceProducts, MarketplaceOrders, OrderItems     |
| Pagos              | Payments, PaymentMethods, Transactions                 |
| Suscripciones      | Subscriptions, SubscriptionPlans                       |
| Facturación        | Invoices, InvoicesItems                                |
| Retiros            | Payouts, PayoutRequests                                |
| Comisiones         | Commissions, CommissionJobs                            |
| Afiliados          | AffiliateProgram, AffiliatePayouts                     |
| Otros              | Donations, Contracts, AdsCampaigns, AdImpressions      |

### 3.3 Módulo AI — Inteligencia Artificial

| Área               | Entidades                                              |
|--------------------|--------------------------------------------------------|
| Modelos            | IaModels, IaVersions, IaConfigs                        |
| Recomendaciones    | IaRecommendations, RecommendationLogs                  |
| Predicciones       | IaPredictions, PredictionHistory                       |
| Moderación         | IaModerationResults                                    |
| Generación         | IaContentGeneration, IaPrompts                         |
| Feedback           | IaFeedback, FeedbackLabels                             |
| Scoring            | IaScores, IaBehaivorAnalitycs, IaClusters              |
| Similitud          | IaSimilarityContent, IaSimilarityUsers                 |
| Training           | IaTrainingData, IaTrainingLogs                         |
| Embeddings         | UserEmbeddings, ContentEmbeddings, CommunityEmbeddings, TagEmbeddings |

---

## 4. Análisis de Vulnerabilidades

### 🔴 CRÍTICO — Nivel 1

#### V-001: Credenciales en Texto Plano
- **Ubicación:** `src/main/resources/application.properties`
- **Problema:** URL de conexión con usuario y contraseña de PostgreSQL (NeonDB) expuestos directamente.
  También se encuentra la contraseña de MongoDB Atlas en un comentario.
- **Riesgo:** Acceso total a la base de datos por cualquier persona con acceso al código fuente.
- **Datos expuestos:**
  - PostgreSQL: `__REDACTED__` (usuario: `neondb_owner`)
  - MongoDB: `__REDACTED__`

#### V-002: Sin Autenticación
- **Ubicación:** `config/securityConfig.java`
- **Problema:** `.anyRequest().permitAll()` — todos los endpoints son públicos.
- **Riesgo:** Cualquier usuario anónimo puede ejecutar CRUD completo sobre todas las entidades.

#### V-003: Sin Autorización
- **Problema:** No existen roles (`ADMIN`, `USER`, `MODERATOR`), ni permisos diferenciados.
- **Riesgo:** No se puede diferenciar entre un usuario normal y un administrador.

#### V-004: Modelo User sin Password
- **Ubicación:** `core/models/User.java`
- **Problema:** El modelo solo tiene `id`, `username`, `email`. Sin campo de password, rol, ni estado.
- **Riesgo:** Imposible implementar autenticación local sin modificar el modelo.

### 🟠 ALTO — Nivel 2

#### V-005: CSRF Deshabilitado sin Justificación
- **Problema:** CSRF está deshabilitado pero no hay autenticación JWT stateless que lo justifique.
- **Riesgo:** Vulnerable a ataques Cross-Site Request Forgery.

#### V-006: Sin Rate Limiting
- **Problema:** No hay límite de peticiones por IP ni por usuario.
- **Riesgo:** Ataques de fuerza bruta, DDoS a nivel de aplicación, scraping masivo.

#### V-007: Sin Validación de Propiedad (Ownership)
- **Problema:** Los servicios no verifican que el usuario autenticado sea el dueño del recurso.
- **Riesgo:** Usuario A puede borrar posts de Usuario B.

#### V-008: Sin Encriptación de Datos Sensibles
- **Problema:** Datos financieros (wallets, pagos) se almacenan sin encriptación adicional.
- **Riesgo:** Exposición de datos financieros si la BD es comprometida.

### 🟡 MEDIO — Nivel 3

#### V-009: CORS Permisivo
- **Problema:** `allowedHeaders("*")` — permite cualquier header. Sin configuración para producción.

#### V-010: Sin Validación de Input Avanzada
- **Problema:** Solo validaciones básicas con `@Valid`. Sin sanitización contra XSS/SQL Injection en campos de texto largo (posts, comentarios).

#### V-011: Sin Headers de Seguridad HTTP
- **Problema:** No se configuran headers como `X-Content-Type-Options`, `X-Frame-Options`, `Strict-Transport-Security`, `Content-Security-Policy`.

#### V-012: Swagger UI Público en Producción
- **Problema:** `/swagger-ui.html` y `/api-docs` son accesibles sin autenticación.
- **Riesgo:** Exposición completa de la estructura de la API.

#### V-013: Sin Logging de Seguridad
- **Problema:** No se registran intentos de acceso no autorizado, logins fallidos, ni operaciones sensibles.

#### V-014: `UserSession.token` Sin Uso
- **Problema:** Existe un campo `token` en `UserSession` pero no se utiliza para nada.

---

## 5. Opciones de Implementación de Seguridad

---

### OPCIÓN 1 ⭐ — JWT con Spring Security (RECOMENDADA)

**Descripción:** Autenticación stateless usando JSON Web Tokens. El usuario se registra con email/password,
hace login y recibe un token JWT que envía en cada petición subsecuente.

**Flujo:**
```
1. POST /api/auth/register  →  Crea usuario con password encriptado (BCrypt)
2. POST /api/auth/login     →  Verifica credenciales → Devuelve JWT (access + refresh)
3. GET  /api/core/posts     →  Header: "Authorization: Bearer <jwt>"
                                 → JwtAuthFilter valida token
                                 → Extrae userId del token
                                 → Procesa la petición
```

**Componentes a crear:**

| Archivo | Paquete | Función |
|---------|---------|---------|
| `JwtService.java` | `common/security/` | Generar, validar y parsear tokens |
| `JwtAuthFilter.java` | `common/security/` | Filtro OncePerRequest que intercepta peticiones |
| `CustomUserDetailsService.java` | `common/security/` | Carga usuario desde BD para Spring Security |
| `AuthController.java` | `core/controllers/` | Endpoints de login, register, refresh |
| `AuthService.java` | `core/services/` | Lógica de autenticación |
| `AuthRequest.java` | `core/dtos/` | DTO para login request |
| `AuthResponse.java` | `core/dtos/` | DTO para login response (token) |
| `SecurityConfig.java` | `config/` | Modificar para agregar filtro JWT |
| `User.java` | `core/models/` | Agregar password, role, enabled, createdAt |

**Dependencias Maven:**
```xml
<!-- JJWT -->
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

**Ventajas:**
- Stateless — no necesita sesiones en servidor
- Escalable horizontalmente (cualquier instancia puede validar el token)
- Control total sobre el contenido del token (claims personalizados)
- Ya tienes BCryptPasswordEncoder configurado
- Amplia documentación y comunidad
- Compatible con aplicaciones mobile y SPA

**Desventajas:**
- No puedes invalidar un token antes de su expiración sin blacklist
- Necesitas implementar refresh tokens manualmente
- El token viaja en cada petición (overhead de tamaño)

**Complejidad:** ⭐⭐⭐ Media
**Tiempo estimado:** 3-5 horas
**Ideal para:** APIs REST consumidas por SPA o apps móviles

---

### OPCIÓN 2 — OAuth2 con Proveedores Externos (Google, GitHub, etc.)

**Descripción:** Los usuarios se autentican a través de proveedores de identidad externos.
Zentry no maneja passwords; delega la autenticación a Google, GitHub, Facebook, etc.

**Flujo:**
```
1. Cliente → Redirige a Google Login
2. Google → Autentica al usuario → Devuelve Authorization Code
3. Cliente → Envía code a Zentry Backend
4. Zentry → Intercambia code con Google por Access Token + User Info
5. Zentry → Crea/vincula usuario local → Genera JWT propio
6. Zentry → Devuelve JWT al cliente
```

**Dependencias Maven:**
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-oauth2-client</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-oauth2-resource-server</artifactId>
</dependency>
```

**Configuración en application.properties:**
```properties
spring.security.oauth2.client.registration.google.client-id=${GOOGLE_CLIENT_ID}
spring.security.oauth2.client.registration.google.client-secret=${GOOGLE_CLIENT_SECRET}
spring.security.oauth2.client.registration.google.scope=email,profile
```

**Ventajas:**
- No manejas passwords (menor responsabilidad legal/seguridad)
- UX familiar para usuarios ("Login con Google")
- Proveedores manejan 2FA, detección de fraude, etc.
- Menor fricción en el registro

**Desventajas:**
- Dependencia de servicios externos
- Configuración por cada proveedor (Google Console, GitHub Apps, etc.)
- Más complejo de testear localmente
- Requiere registrar la app en cada proveedor
- Si el proveedor cae, tus usuarios no pueden entrar

**Complejidad:** ⭐⭐⭐⭐ Alta
**Tiempo estimado:** 6-10 horas
**Ideal para:** Plataformas sociales que priorizan UX de registro

---

### OPCIÓN 3 — Sesiones con Spring Session + Redis

**Descripción:** Autenticación tradicional basada en sesiones HTTP. El servidor crea una sesión
al hacer login y almacena el ID de sesión en una cookie. Redis se usa para almacenar las sesiones
de forma distribuida.

**Flujo:**
```
1. POST /api/auth/login (email, password)
2. Servidor crea HttpSession → almacena userId en sesión
3. Servidor envía cookie JSESSIONID al cliente
4. Cliente envía cookie automáticamente en cada petición
5. Servidor recupera sesión de Redis → identifica al usuario
```

**Dependencias Maven:**
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.session</groupId>
    <artifactId>spring-session-data-redis</artifactId>
</dependency>
```

**Ventajas:**
- Modelo mental simple (sesiones tradicionales)
- Puedes invalidar sesiones inmediatamente (logout real)
- Spring Security tiene soporte nativo
- Cookies HttpOnly son más seguras que JWT en localStorage

**Desventajas:**
- Stateful — necesitas Redis como infraestructura adicional
- No escala tan bien como JWT
- Las cookies pueden tener problemas con CORS en dominios cruzados
- Más complejo para clientes móviles nativos
- Requiere configurar Redis

**Complejidad:** ⭐⭐⭐ Media
**Tiempo estimado:** 4-6 horas
**Ideal para:** Aplicaciones web server-rendered (MVC), admin panels

---

### OPCIÓN 4 — API Key por Cliente

**Descripción:** Cada cliente (aplicación frontend, app móvil, servicio externo) tiene una
API Key única que se envía en un header personalizado. Es un mecanismo simple de identificación
de clientes, no de usuarios individuales.

**Flujo:**
```
1. Admin genera API Key para cada cliente (ej: web-app, mobile-ios, partner-x)
2. Cliente envía: Header "X-API-Key: ak_live_xxxxxxxxxxxx"
3. Servidor valida API Key contra tabla de API Keys
4. Si es válida → permite acceso según permisos del key
5. Rate limiting por API Key
```

**Componentes a crear:**

| Archivo | Función |
|---------|---------|
| `ApiKey.java` (Model) | Entidad: id, key, clientName, permissions, rateLimit, active |
| `ApiKeyRepository.java` | Acceso a datos |
| `ApiKeyFilter.java` | Filtro que valida el header X-API-Key |
| `ApiKeyService.java` | CRUD + generación de keys |

**Ventajas:**
- Muy simple de implementar (~100 líneas)
- Fácil de revocar (desactivar un key)
- Buen control por cliente
- Perfecto para rate limiting por cliente

**Desventajas:**
- NO identifica usuarios individuales
- Si el key se filtra, cualquiera puede usarlo
- No es un mecanismo de autenticación de usuario
- Se debe combinar con otro método para auth de usuarios

**Complejidad:** ⭐⭐ Baja
**Tiempo estimado:** 2-3 horas
**Ideal para:** Control de acceso por aplicación/cliente, APIs públicas

---

### OPCIÓN 5 — Basic Auth con Spring Security

**Descripción:** El método más simple. El cliente envía usuario y contraseña codificados en
Base64 en cada petición HTTP con el header `Authorization: Basic <base64(user:pass)>`.

**Flujo:**
```
1. Cliente envía: Authorization: Basic dXNlcjpwYXNz  (base64 de "user:pass")
2. Spring Security decodifica automáticamente
3. Valida contra BD usando UserDetailsService
4. Si es válido → permite acceso
```

**Componentes a crear:**

| Archivo | Función |
|---------|---------|
| `CustomUserDetailsService.java` | Cargar usuario desde BD |
| `SecurityConfig.java` | Habilitar httpBasic() |
| Modificar `User.java` | Agregar password, role |

**Configuración en SecurityConfig:**
```java
http
    .httpBasic(Customizer.withDefaults())
    .authorizeHttpRequests(auth -> auth
        .requestMatchers("/api/auth/**").permitAll()
        .anyRequest().authenticated()
    );
```

**Ventajas:**
- Extremadamente simple (~50 líneas de código)
- Soporte nativo de Spring Security
- No requiere dependencias adicionales
- Fácil de testear con Postman/curl

**Desventajas:**
- Credenciales viajan en cada petición (solo seguro con HTTPS)
- Base64 NO es encriptación (es codificación reversible)
- No hay tokens, no hay expiración
- Pésima UX para usuarios (popup del navegador)
- No recomendado para producción

**Complejidad:** ⭐ Muy Baja
**Tiempo estimado:** 1-2 horas
**Ideal para:** Prototipos, APIs internas, testing rápido

---

### OPCIÓN 6 — JWT + Refresh Token + Blacklist (JWT Avanzado)

**Descripción:** Versión avanzada de la Opción 1. Incluye tokens de refresco con rotación,
blacklist de tokens revocados, y detección de reutilización de refresh tokens.

**Flujo:**
```
1. Login → access_token (15 min) + refresh_token (7 días)
2. Access token expira → POST /api/auth/refresh con refresh_token
3. Servidor valida refresh_token → genera NUEVO access_token + NUEVO refresh_token
4. Refresh token anterior se invalida (blacklist)
5. Si alguien usa un refresh token ya rotado → se invalidan TODOS los tokens del usuario
```

**Componentes adicionales vs Opción 1:**

| Archivo | Función |
|---------|---------|
| `RefreshToken.java` (Model) | Entidad: id, token, userId, expiryDate, revoked |
| `RefreshTokenRepository.java` | Acceso a datos |
| `TokenBlacklistService.java` | Almacenar tokens revocados (en memoria o Redis) |
| `RefreshTokenService.java` | Rotación y validación de refresh tokens |

**Ventajas:**
- Máxima seguridad con tokens JWT
- Logout real (blacklist del token)
- Detección de robo de refresh tokens
- Access tokens de corta duración minimizan el riesgo

**Desventajas:**
- Significativamente más complejo
- Necesita almacenamiento para blacklist (BD o Redis)
- Ya no es puramente stateless

**Complejidad:** ⭐⭐⭐⭐ Alta
**Tiempo estimado:** 6-8 horas
**Ideal para:** Aplicaciones en producción con requisitos de seguridad estrictos

---

### OPCIÓN 7 — Multi-Factor Authentication (MFA/2FA)

**Descripción:** Capa adicional sobre cualquier método de autenticación. Después del login
con contraseña, el usuario debe verificar su identidad con un segundo factor: código TOTP
(Google Authenticator), SMS, o email.

**Flujo con TOTP (Google Authenticator):**
```
1. Registro: Usuario activa 2FA → servidor genera secreto TOTP → muestra QR code
2. Usuario escanea QR en Google Authenticator
3. Login paso 1: email + password → respuesta parcial (requiere 2FA)
4. Login paso 2: código de 6 dígitos de la app → login completo → JWT
```

**Dependencias Maven:**
```xml
<!-- Google Authenticator TOTP -->
<dependency>
    <groupId>dev.samstevens.totp</groupId>
    <artifactId>totp</artifactId>
    <version>1.7.1</version>
</dependency>
```

**Componentes a crear:**

| Archivo | Función |
|---------|---------|
| `TotpService.java` | Generar secreto, verificar código, generar QR URI |
| `MfaController.java` | Endpoints para activar/desactivar/verificar 2FA |
| Modificar `User.java` | Agregar: mfaEnabled, mfaSecret |
| Modificar `AuthService.java` | Flujo de login en 2 pasos |

**Ventajas:**
- Máxima seguridad de autenticación
- Incluso si el password es robado, necesitan el segundo factor
- Compatible con Google Authenticator, Authy, etc.
- Estándar de industria (TOTP - RFC 6238)

**Desventajas:**
- Complejidad en UX (los usuarios pueden no entender)
- Requiere flujo de recuperación si pierden el dispositivo
- Backup codes necesarios
- Solo como complemento, no reemplaza auth principal

**Complejidad:** ⭐⭐⭐⭐ Alta
**Tiempo estimado:** 5-7 horas (sobre una auth existente)
**Ideal para:** Plataformas con datos financieros (como tu módulo business)

---

### OPCIÓN 8 — RBAC (Role-Based Access Control) con Anotaciones

**Descripción:** Sistema de control de acceso basado en roles usando las anotaciones
de Spring Security. Cada usuario tiene uno o más roles, y cada endpoint requiere roles específicos.

**Modelo de Roles:**
```
ROLE_USER       → Acceso básico (leer posts, crear contenido propio)
ROLE_MODERATOR  → Moderar contenido (borrar posts, manejar reportes)
ROLE_CREATOR    → Crear productos en marketplace, series
ROLE_ADMIN      → Acceso total (configuración del sistema, feature flags)
ROLE_SUPER_ADMIN → Gestión de otros admins
```

**Ejemplo de uso en Controllers:**
```java
@PreAuthorize("hasRole('ADMIN')")
@DeleteMapping("/users/{id}")
public ResponseEntity<Void> deleteUser(@PathVariable Integer id) { ... }

@PreAuthorize("hasAnyRole('USER', 'CREATOR')")
@PostMapping("/posts")
public ResponseEntity<PostResponse> createPost(@RequestBody PostRequest req) { ... }

@PreAuthorize("#userId == authentication.principal.id or hasRole('ADMIN')")
@PutMapping("/users/{userId}/settings")
public ResponseEntity<UserSettingsResponse> updateSettings(...) { ... }
```

**Componentes a crear:**

| Archivo | Función |
|---------|---------|
| `Role.java` (Model) | Entidad: id, name (enum) |
| `Permission.java` (Model) | Entidad: id, name, description |
| `RolePermission.java` | Tabla intermedia Role ↔ Permission |
| `UserRole.java` | Tabla intermedia User ↔ Role |
| `RoleRepository.java` | Acceso a datos |
| Modificar `SecurityConfig.java` | Agregar `@EnableMethodSecurity` |
| Modificar `CustomUserDetailsService` | Cargar roles del usuario |

**Matriz de Permisos Sugerida para Zentry:**

| Operación | USER | CREATOR | MODERATOR | ADMIN |
|-----------|------|---------|-----------|-------|
| Leer posts | ✅ | ✅ | ✅ | ✅ |
| Crear post propio | ✅ | ✅ | ✅ | ✅ |
| Editar post propio | ✅ | ✅ | ✅ | ✅ |
| Borrar post de otro | ❌ | ❌ | ✅ | ✅ |
| Ver wallets propias | ✅ | ✅ | ❌ | ✅ |
| Crear producto marketplace | ❌ | ✅ | ❌ | ✅ |
| Moderar reportes | ❌ | ❌ | ✅ | ✅ |
| Gestionar feature flags | ❌ | ❌ | ❌ | ✅ |
| Configurar sistema | ❌ | ❌ | ❌ | ✅ |
| Ver analytics | ❌ | ✅ (propios) | ✅ | ✅ |
| Gestionar modelos IA | ❌ | ❌ | ❌ | ✅ |

**Ventajas:**
- Control granular de acceso
- Declarativo con anotaciones (@PreAuthorize)
- Fácil de entender y mantener
- Auditable
- Spring Security lo soporta nativamente

**Desventajas:**
- Requiere autenticación ya implementada (JWT u otra)
- Complejidad en la gestión de roles y permisos
- Las anotaciones se distribuyen por muchos controladores

**Complejidad:** ⭐⭐⭐ Media
**Tiempo estimado:** 3-4 horas (sobre una auth existente)
**Ideal para:** Cualquier aplicación con múltiples tipos de usuario

---

## 6. Tabla Comparativa de Opciones

| # | Opción | Complejidad | Tiempo | Seguridad | Tipo de App | Stateless | Producción |
|---|--------|:-----------:|:------:|:---------:|-------------|:---------:|:----------:|
| 1 | **JWT Básico** ⭐ | ⭐⭐⭐ | 3-5h | ⭐⭐⭐⭐ | API REST / SPA / Mobile | ✅ | ✅ |
| 2 | OAuth2 Externo | ⭐⭐⭐⭐ | 6-10h | ⭐⭐⭐⭐ | Plataformas sociales | ✅ | ✅ |
| 3 | Sesiones + Redis | ⭐⭐⭐ | 4-6h | ⭐⭐⭐ | Web tradicional | ❌ | ✅ |
| 4 | API Key | ⭐⭐ | 2-3h | ⭐⭐ | APIs públicas/B2B | ✅ | ⚠️ |
| 5 | Basic Auth | ⭐ | 1-2h | ⭐ | Prototipos/testing | ✅ | ❌ |
| 6 | JWT Avanzado | ⭐⭐⭐⭐ | 6-8h | ⭐⭐⭐⭐⭐ | Producción exigente | ⚠️ | ✅✅ |
| 7 | MFA/2FA | ⭐⭐⭐⭐ | 5-7h | ⭐⭐⭐⭐⭐ | Finanzas / datos sensibles | — | ✅✅ |
| 8 | RBAC | ⭐⭐⭐ | 3-4h | ⭐⭐⭐⭐ | Multi-rol | — | ✅ |

### Combinaciones Recomendadas

| Escenario | Combinación | Tiempo Total |
|-----------|-------------|:------------:|
| **Proyecto universitario (mínimo viable)** | Opción 1 (JWT) + Opción 8 (RBAC) | 6-9h |
| **MVP para producción** | Opción 1 + Opción 8 + Opción 4 (API Key) | 8-12h |
| **Plataforma social completa** | Opción 2 (OAuth2) + Opción 6 (JWT Avanzado) + Opción 8 | 15-22h |
| **Con requisitos financieros** | Opción 6 + Opción 7 (MFA) + Opción 8 | 14-19h |
| **Prototipo rápido** | Opción 5 (Basic Auth) | 1-2h |

---

## 7. Medidas de Seguridad Complementarias

Independientemente de la opción de autenticación elegida, estas medidas deben implementarse:

### 7.1 Variables de Entorno para Credenciales

**Estado actual (INSEGURO):**
```properties
spring.datasource.password=${DB_PASSWORD}
```

**Estado correcto:**
```properties
spring.datasource.url=${DB_URL}
spring.datasource.username=${DB_USER}
spring.datasource.password=${DB_PASS}
```

**Con perfiles de Spring:**
```
application.properties        → configuración común
application-dev.properties    → credenciales de desarrollo (en .gitignore)
application-prod.properties   → variables de entorno en producción
```

### 7.2 Headers de Seguridad HTTP

Agregar en `SecurityConfig.java`:
```java
http.headers(headers -> headers
    .contentTypeOptions(Customizer.withDefaults())           // X-Content-Type-Options: nosniff
    .frameOptions(frame -> frame.deny())                      // X-Frame-Options: DENY
    .httpStrictTransportSecurity(hsts -> hsts                 // HSTS
        .includeSubDomains(true)
        .maxAgeInSeconds(31536000))
    .xssProtection(Customizer.withDefaults())                 // X-XSS-Protection
);
```

### 7.3 Rate Limiting con Bucket4j

```xml
<dependency>
    <groupId>com.bucket4j</groupId>
    <artifactId>bucket4j-core</artifactId>
    <version>8.14.0</version>
</dependency>
```

Ejemplo de filtro:
```java
@Component
public class RateLimitFilter extends OncePerRequestFilter {
    private final Map<String, Bucket> cache = new ConcurrentHashMap<>();

    private Bucket createBucket() {
        return Bucket.builder()
            .addLimit(Bandwidth.classic(100, Refill.intervally(100, Duration.ofMinutes(1))))
            .build();
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
            HttpServletResponse response, FilterChain chain) {
        String ip = request.getRemoteAddr();
        Bucket bucket = cache.computeIfAbsent(ip, k -> createBucket());
        if (bucket.tryConsume(1)) {
            chain.doFilter(request, response);
        } else {
            response.setStatus(429); // Too Many Requests
        }
    }
}
```

### 7.4 Validación de Ownership en Servicios

```java
// Ejemplo en PostService
public PostResponse update(Integer postId, PostRequest request, Integer authenticatedUserId) {
    Post post = repo.findById(postId)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));

    if (!post.getUserId().equals(authenticatedUserId)) {
        throw new ResponseStatusException(HttpStatus.FORBIDDEN,
            "No tienes permiso para editar este post");
    }
    // ... continuar con la actualización
}
```

### 7.5 Sanitización de Input (Anti-XSS)

```java
// Ejemplo con OWASP HTML Sanitizer
public PostResponse create(PostRequest request) {
    String sanitized = Jsoup.clean(request.getContenido(), Safelist.basic());
    Post entity = Post.builder()
        .userId(request.getUserId())
        .contenido(sanitized)
        .build();
    return mappers.toResponse(repo.save(entity));
}
```

### 7.6 Auditoría Automática con Spring AOP

```java
@Aspect
@Component
public class AuditAspect {
    private final AuditLogRepository auditRepo;

    @AfterReturning("@annotation(auditable)")
    public void logAction(JoinPoint jp, Auditable auditable) {
        AuditLog log = AuditLog.builder()
            .accion(auditable.action())
            .userId(getCurrentUserId())
            .timestamp(LocalDateTime.now())
            .detalles(jp.getSignature().toShortString())
            .build();
        auditRepo.save(log);
    }
}

// Uso:
@Auditable(action = "DELETE_POST")
@DeleteMapping("/{id}")
public ResponseEntity<Void> delete(@PathVariable Integer id) { ... }
```

### 7.7 Proteger Swagger en Producción

```java
// En SecurityConfig.java
.requestMatchers("/swagger-ui/**", "/api-docs/**").hasRole("ADMIN")
```

O deshabilitar completamente en producción:
```properties
# application-prod.properties
springdoc.api-docs.enabled=false
springdoc.swagger-ui.enabled=false
```

### 7.8 Logging de Seguridad

```properties
# application.properties
logging.level.org.springframework.security=DEBUG
logging.level.zentry.back.api.common.security=INFO
```

---

## 8. Plan de Acción Priorizado

### FASE 1 — Urgente (Hacer AHORA — 1 hora)

- [ ] Mover credenciales a variables de entorno (`${DB_URL}`, `${DB_PASS}`)
- [ ] Agregar `application-dev.properties` al `.gitignore`
- [ ] Rotar las credenciales de NeonDB (ya fueron expuestas en el código)
- [ ] Eliminar el comentario con el password de MongoDB de `application.properties`

### FASE 2 — Alta Prioridad (Esta semana — 4-5 horas)

- [ ] Agregar campos al modelo `User`: `password`, `role`, `enabled`, `createdAt`
- [ ] Implementar JWT (Opción 1):
  - [ ] `JwtService.java`
  - [ ] `JwtAuthFilter.java`
  - [ ] `CustomUserDetailsService.java`
  - [ ] `AuthController.java` (login, register)
  - [ ] `AuthService.java`
- [ ] Modificar `SecurityConfig.java` para proteger endpoints
- [ ] Definir endpoints públicos vs protegidos

### FASE 3 — Media Prioridad (Próximas 2 semanas — 4-6 horas)

- [ ] Implementar RBAC (Opción 8):
  - [ ] Crear modelo `Role`
  - [ ] Agregar `@PreAuthorize` a controllers sensibles
- [ ] Agregar validación de ownership en servicios
- [ ] Implementar rate limiting
- [ ] Configurar headers de seguridad HTTP
- [ ] Proteger Swagger UI

### FASE 4 — Mejoras (Cuando haya tiempo — 5-8 horas)

- [ ] Implementar refresh tokens (Opción 6)
- [ ] Agregar auditoría automática con AOP
- [ ] Sanitización de inputs (anti-XSS)
- [ ] Tests de seguridad
- [ ] Logging de seguridad
- [ ] Considerar OAuth2 para login social
- [ ] Considerar MFA para operaciones financieras

---

## 9. Checklist de Seguridad

Usa esta checklist para verificar que tu aplicación cumple con los estándares mínimos de seguridad:

### Autenticación
- [ ] Las contraseñas se almacenan hasheadas (BCrypt)
- [ ] Existe un endpoint de login seguro
- [ ] Existe un endpoint de registro con validaciones
- [ ] Los tokens tienen expiración configurada
- [ ] Existe mecanismo de refresh token
- [ ] Se puede hacer logout (invalidar token)

### Autorización
- [ ] Existe sistema de roles (USER, ADMIN, etc.)
- [ ] Cada endpoint tiene permisos definidos
- [ ] Se valida ownership antes de modificar/borrar recursos
- [ ] Los endpoints administrativos están protegidos
- [ ] Swagger UI está protegido en producción

### Datos
- [ ] Credenciales en variables de entorno (no en código)
- [ ] HTTPS habilitado en producción
- [ ] Headers de seguridad configurados
- [ ] Inputs sanitizados contra XSS
- [ ] Queries protegidas contra SQL injection (JPA lo hace por defecto)

### Infraestructura
- [ ] Rate limiting implementado
- [ ] CORS configurado para dominios específicos
- [ ] Logs de seguridad habilitados
- [ ] Auditoría de acciones sensibles
- [ ] Monitoreo de intentos de acceso no autorizado

### Testing
- [ ] Tests de autenticación (login/register)
- [ ] Tests de autorización (acceso denegado por rol)
- [ ] Tests de ownership (usuario no puede ver/editar datos de otros)
- [ ] Tests de validación (inputs inválidos rechazados)

---

> **Nota:** Este informe fue generado como parte del análisis de seguridad del proyecto Zentry.
> Se recomienda revisar y actualizar este documento conforme se implementen las medidas de seguridad.
