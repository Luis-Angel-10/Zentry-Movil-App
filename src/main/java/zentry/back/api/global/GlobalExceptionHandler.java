package zentry.back.api.global;


import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.resource.NoResourceFoundException;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Manejador global de excepciones para toda la API.
 * Centraliza el formato de respuestas de error garantizando consistencia.
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    // ─── 400: Validación de campos (@Valid) ───────────────────────────────────
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleValidationErrors(MethodArgumentNotValidException ex) {
        Map<String, String> fieldErrors = new HashMap<>();
        for (FieldError err : ex.getBindingResult().getFieldErrors()) {
            fieldErrors.put(err.getField(), err.getDefaultMessage());
        }

        Map<String, Object> body = buildBody(HttpStatus.BAD_REQUEST, "Error de validación en los campos enviados", fieldErrors);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(body);
    }

    // ─── ResponseStatusException (404, 400, etc.) ──────────────────────────────
    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<Map<String, Object>> handleResponseStatus(ResponseStatusException ex) {
        Map<String, Object> body = buildBody(
                HttpStatus.resolve(ex.getStatusCode().value()),
                ex.getReason() != null ? ex.getReason() : ex.getMessage(),
                null
        );
        return ResponseEntity.status(ex.getStatusCode()).body(body);
    }

    // ─── 400: Argumento inválido (ej. UUID malformado en path variable) ─────────
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, Object>> handleIllegalArgument(IllegalArgumentException ex) {
        Map<String, Object> body = buildBody(HttpStatus.BAD_REQUEST,
                "Argumento inválido: " + ex.getMessage(), null);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(body);
    }

    // ─── 404: Recurso no encontrado (rutas inexistentes) ──────────────────────
    @ExceptionHandler(NoResourceFoundException.class)
    public ResponseEntity<Map<String, Object>> handleNoResourceFound(NoResourceFoundException ex) {
        Map<String, Object> body = buildBody(HttpStatus.NOT_FOUND,
                "El recurso solicitado no existe: " + ex.getResourcePath(), null);
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(body);
    }

    // ─── 500: Cualquier excepción no capturada ───────────────────────────────────
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleGeneral(Exception ex) {
        ex.printStackTrace(); // Agregado para ver la causa real en los logs
        String msg = (ex.getMessage() != null && !ex.getMessage().isBlank())
                ? ex.getMessage()
                : "Error interno del servidor. Contacte al administrador.";
        Map<String, Object> body = buildBody(HttpStatus.INTERNAL_SERVER_ERROR, msg, null);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(body);
    }

    // ─── Helper ────────────────────────────────────────────────────────────────
    private Map<String, Object> buildBody(HttpStatus status, String message, Object errors) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("timestamp", LocalDateTime.now().toString());
        body.put("status", status != null ? status.value() : 500);
        body.put("error", status != null ? status.getReasonPhrase() : "Internal Server Error");
        body.put("message", message);
        if (errors != null) {
            body.put("errors", errors);
        }
        return body;
    }
}
