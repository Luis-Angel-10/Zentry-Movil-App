package zentry.back.api.core.utils;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Component
public class SecurityUtils {

    // Extrae el email/username del JWT actual
    public static String getCurrentUserEmail() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.isAuthenticated()) {
            return authentication.getName(); // Spring Security guarda aquí el "subject" del JWT
        }
        throw new RuntimeException("Usuario no autenticado");
    }
}
