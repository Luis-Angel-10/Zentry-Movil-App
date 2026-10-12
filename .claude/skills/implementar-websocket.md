# Skill: Implementar Módulo WebSocket (Realtime)

## Descripción
Guía para implementar el módulo de tiempo real usando Spring WebSocket con STOMP y SockJS.

## Contexto
- El paquete `realtime/` ya existe con sub-paquetes: controllers, documents, dtos, repositories, sockets
- Todos los archivos actuales son placeholders (`c.java`)
- La dependencia `spring-boot-starter-websocket` ya está en el pom.xml
- Se planea usar MongoDB para documentos de este módulo

## Instrucciones

### Paso 1: Crear WebSocketConfig
En `config/WebSocketConfig.java`:
```java
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        config.enableSimpleBroker("/topic", "/queue");  // para broadcasts y mensajes directos
        config.setApplicationDestinationPrefixes("/app");
        config.setUserDestinationPrefix("/user");
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws")
                .setAllowedOrigins("http://localhost:5173")  // misma config que CORS
                .withSockJS();
    }
}
```

### Paso 2: Casos de Uso para Zentry
Los sockets más útiles para una red social:

| Canal | Tipo | Descripción |
|-------|------|-------------|
| `/topic/posts/{communityId}` | Broadcast | Nuevos posts en una comunidad |
| `/topic/comments/{postId}` | Broadcast | Nuevos comentarios en un post |
| `/user/queue/notifications` | Directo | Notificaciones personales |
| `/user/queue/messages` | Directo | Mensajes privados |
| `/topic/typing/{conversationId}` | Broadcast | Indicador de "está escribiendo..." |

### Paso 3: Crear Socket Controllers
En `realtime/sockets/`:
```java
@Controller
public class NotificationSocket {
    private final SimpMessagingTemplate messaging;

    // Enviar notificación a un usuario específico
    public void sendNotification(Integer userId, NotificationDto dto) {
        messaging.convertAndSendToUser(
            userId.toString(), "/queue/notifications", dto);
    }
}
```

### Paso 4: Documentos MongoDB
En `realtime/documents/`:
- Usar `@Document(collection = "nombre")` en vez de `@Entity`
- IDs con `@Id private String id` (MongoDB usa String IDs)

### Paso 5: Eliminar placeholders
- Eliminar todos los archivos `c.java` del paquete `realtime/`

## Reglas
- Los placeholders `c.java` deben eliminarse al implementar
- WebSocket debe integrarse con el sistema de notificaciones existente en core
- Si se implementa JWT, el WebSocket debe validar el token en el handshake
- Usar MongoDB para mensajes/chat (alto volumen, no relacional)
- Usar PostgreSQL para notificaciones persistentes (ya existe en core)
