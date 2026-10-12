# zentry

### 1. Repositories (Capa de Acceso a Datos / Data Access Layer)
Después de los modelos, necesitas una forma de hablar con la base de datos (hacer el CRUD: crear, leer, actualizar, borrar).
* **Qué son:** Interfaces que extienden de `JpaRepository<Entidad, TipoId>`.
* **Dónde van:** Dependiendo de tu paquete, irían en algo como `zentry.back.api.core.repositories`, `zentry.back.api.business.repositories`, etc.
* **Por qué:** Spring Data JPA se encarga de crear las consultas a base de datos de forma automática.

### 2. DTOs (Data Transfer Objects)
Una regla de oro en el desarrollo seguro de APIs es **nunca** devolver directamente los Models/Entidades al cliente (Frontend/Móvil), para evitar exponer información sensible, evitar ciclos infinitos en relaciones (como con `@ManyToOne`) y ahorrar ancho de banda.
* **Qué son:** Clases simples (con sus getters y setters) que sólo contienen la información que quieres recibir del cliente o enviarle.
* **Dónde van:** En paquetes tipo `zentry.back.api.core.dtos`.

### 3. Services (Capa de Lógica de Negocio / Business Logic)
Aquí es donde ocurre "la magia" de la aplicación.
* **Qué son:** Clases anotadas con `@Service`.
* **Qué hacen:** Inyectan los **Repositories** que creaste en el paso 1. Aquí aplicarás las reglas de tu negocio, validaciones complejas, y llamarás a funciones externas. También aquí es donde generalmente conviertes una *Entidad* a *DTO* (o usas librerías como MapStruct para mapear).
* **Dónde van:** En módulos tipo `zentry.back.api.core.services`.

### 4. Controllers (Capa de Presentación / API Layer)
El punto de entrada para que el Frontend se comunique con tu Backend.
* **Qué son:** Clases anotadas con `@RestController` y `@RequestMapping("/api/v1/...")`.
* **Qué hacen:** Exponen los *endpoints* (GET, POST, PUT, DELETE). Estas clases inyectan a los **Services** del paso 3. El Controller recibe las peticiones HTTP, le pide al Servicio que haga el trabajo pesado, y devuelve una respuesta estructurada (ejemplo: un `ResponseEntity`).
* **Dónde van:** Ej. `zentry.back.api.core.controllers`.

### 5. Configuración y Seguridad (Security / Config)
* Aquí es donde entra tu `SecurityConfig.java` (noto que justamente ahorita es el archivo que tienes abierto). Una vez que tengas listos los servicios de usuarios y sus roles, configuras el filtro JWT y estableces qué endpoints de tus **Controllers** requieren autenticación y cuáles son públicos.

---

### En resumen, tu flujo de trabajo para construir un nuevo módulo debería ser:
1. `Model` *(La tabla en la base de datos - Ya lo tienes)*
2. `Repository` *(Para acceder a esa tabla)*
3. `DTO` *(Para decidir qué datos entran y salen)*
4. `Service` *(Para la lógica y reglas del negocio)*
5. `Controller` *(Para crear el Endpoint HTTP / URL)*

¿Te gustaría que empecemos a crear los **Repositories** para alguna de tus entidades actuales? Si es así, dime sobre qué entidad quieres que trabajemos primero.
