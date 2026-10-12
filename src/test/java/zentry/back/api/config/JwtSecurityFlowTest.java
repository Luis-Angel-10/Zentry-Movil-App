package zentry.back.api.config;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import zentry.back.api.core.services.JwtService;

import java.util.List;

import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Verifica el flujo de seguridad de extremo a extremo con el {@link SecurityConfig},
 * el {@link JwtAuthenticationFilter} y el {@link JwtService} REALES (sólo se simula
 * el {@code UserDetailsService}, que en producción va contra la BD):
 *
 * <ol>
 *   <li>{@code /api/auth/**} es público (sin JWT).</li>
 *   <li>Un endpoint no listado como público exige autenticación → 403 sin token
 *       (Spring Security 6 usa {@code Http403ForbiddenEntryPoint} por defecto al
 *       no haber httpBasic/formLogin).</li>
 *   <li>Un JWT válido (firmado por el {@code JwtService} real) da acceso → 200.</li>
 *   <li>Un JWT inválido no da acceso → 403.</li>
 * </ol>
 */
@WebMvcTest(controllers = JwtSecurityFlowTest.TestEndpoints.class)
@Import({SecurityConfig.class, JwtService.class, JwtAuthenticationFilter.class,
        JwtSecurityFlowTest.TestEndpoints.class})
@TestPropertySource(properties = {
        "security.jwt.secret-key=dGVzdHNlY3JldC1jaGFuZ2UtbWUtdGVzdHNlY3JldC1jaGFuZ2UtbWU=",
        "security.jwt.expiration-time=3600000"
})
@DisplayName("Flujo de seguridad JWT (SecurityConfig + JwtAuthenticationFilter + JwtService)")
class JwtSecurityFlowTest {

    @Autowired MockMvc mvc;
    @Autowired JwtService jwtService;

    @MockitoBean UserDetailsService userDetailsService;
    @MockitoBean AuthenticationProvider authenticationProvider;

    private static final String PUBLIC_URL = "/api/auth/ping";
    private static final String PRIVATE_URL = "/api/business/secure-ping";

    private UserDetails alice;

    @BeforeEach
    void setUp() {
        alice = User.withUsername("alice@zentry.com").password("x").authorities(List.of()).build();
        when(userDetailsService.loadUserByUsername(eq("alice@zentry.com"))).thenReturn(alice);
    }

    @Test
    @DisplayName("1. /api/auth/** es accesible sin token")
    void publicEndpoint_noToken_200() throws Exception {
        mvc.perform(get(PUBLIC_URL)).andExpect(status().isOk());
    }

    @Test
    @DisplayName("2. endpoint privado sin token → 403")
    void privateEndpoint_noToken_denied() throws Exception {
        mvc.perform(get(PRIVATE_URL)).andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("3. endpoint privado con JWT válido → 200")
    void privateEndpoint_validToken_200() throws Exception {
        String token = jwtService.generateToken(alice);
        mvc.perform(get(PRIVATE_URL).header("Authorization", "Bearer " + token))
           .andExpect(status().isOk());
    }

    @Test
    @DisplayName("4. endpoint privado con JWT inválido → 403")
    void privateEndpoint_invalidToken_denied() throws Exception {
        mvc.perform(get(PRIVATE_URL).header("Authorization", "Bearer not-a-real-jwt"))
           .andExpect(status().isForbidden());
    }

    @RestController
    static class TestEndpoints {
        @GetMapping(PUBLIC_URL)
        String publicPing() {
            return "public";
        }

        @GetMapping(PRIVATE_URL)
        String privatePing() {
            return "private";
        }
    }
}
