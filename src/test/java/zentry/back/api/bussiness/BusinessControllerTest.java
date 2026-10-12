package zentry.back.api.bussiness;


import org.springframework.context.annotation.Import;
import zentry.back.api.config.SecurityConfig;

import java.lang.annotation.*;

/**
 * Meta-annotation applied to every business controller test.
 * Imports the real SecurityFilterChain (permitAll) so MockMvc
 * doesn't reject requests with 401/403.
 */
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Import(SecurityConfig.class)
public @interface BusinessControllerTest {
}
