package com.nova.log.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.nova.log.aspect.AutoLogAspect;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnWebApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.EnableAspectJAutoProxy;

@AutoConfiguration
@EnableAspectJAutoProxy
@ConditionalOnWebApplication(type = ConditionalOnWebApplication.Type.SERVLET)
public class NovaLogAutoConfiguration {

    @Bean
    public AutoLogAspect autoLogAspect(ObjectMapper objectMapper,
                                       org.springframework.beans.factory.ObjectProvider<com.nova.log.recorder.OperLogRecorder> recorder) {
        return new AutoLogAspect(recorder, objectMapper);
    }
}
