package com.nova.monitor.config;

import de.codecentric.boot.admin.server.config.AdminServerProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.SavedRequestAwareAuthenticationSuccessHandler;
import org.springframework.security.web.csrf.CookieCsrfTokenRepository;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;

/**
 * Spring Boot Admin 登录安全配置（参考 Jeecg SecuritySecureConfig）。
 */
@Configuration
@EnableWebSecurity
public class MonitorSecurityConfig {

    private final AdminServerProperties adminServer;

    public MonitorSecurityConfig(AdminServerProperties adminServerProperties) {
        this.adminServer = adminServerProperties;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        SavedRequestAwareAuthenticationSuccessHandler successHandler = new SavedRequestAwareAuthenticationSuccessHandler();
        successHandler.setTargetUrlParameter("redirectTo");
        successHandler.setDefaultTargetUrl(this.adminServer.path("/"));

        http.authorizeHttpRequests(auth -> auth
                        .requestMatchers(this.adminServer.path("/assets/**")).permitAll()
                        .requestMatchers(this.adminServer.path("/login"), "/css/**", "/js/**", "/image/**").permitAll()
                        .requestMatchers("/actuator/**").permitAll()
                        .anyRequest().authenticated())
                .formLogin(form -> form.loginPage(this.adminServer.path("/login")).successHandler(successHandler))
                .logout(logout -> logout.logoutUrl(this.adminServer.path("/logout")))
                .httpBasic(Customizer.withDefaults())
                .csrf(csrf -> csrf.csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
                        .ignoringRequestMatchers(
                                new AntPathRequestMatcher(this.adminServer.path("/instances")),
                                new AntPathRequestMatcher(this.adminServer.path("/instances/*")),
                                new AntPathRequestMatcher("/actuator/**")));

        return http.build();
    }
}
