package zentry.back.api.bussiness;

import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.core.userdetails.UserDetailsService;
import zentry.back.api.core.services.JwtService;

import static org.mockito.Mockito.mock;

/**
 * Supplies the beans SecurityConfig/JwtAuthenticationFilter need
 * (JwtService, UserDetailsService, AuthenticationProvider) that a
 * @WebMvcTest slice does not scan, since ApplicationConfig (which
 * defines them against real repositories) is never imported here.
 */
@TestConfiguration
public class TestSecurityBeansConfig {

    @Bean
    public JwtService jwtService() {
        return mock(JwtService.class);
    }

    @Bean
    public UserDetailsService userDetailsService() {
        return mock(UserDetailsService.class);
    }

    @Bean
    public AuthenticationProvider authenticationProvider() {
        return mock(AuthenticationProvider.class);
    }
}
