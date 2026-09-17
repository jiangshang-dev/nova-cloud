package com.nova.file.config;

import com.nova.file.starter.client.FileStorageClientProvider;
import com.nova.file.starter.service.NovaFileService;
import com.nova.file.starter.service.impl.NovaFileServiceImpl;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * 将管理后台启用的存储绑定到 {@link NovaFileService}，全局上传/下载走同一套配置。
 */
@Configuration
public class NovaFileServiceConfiguration {

    @Bean
    public FileStorageClientProvider fileStorageClientProvider(ActiveStorageHolder activeStorageHolder) {
        return activeStorageHolder::requireClient;
    }

    @Bean
    public NovaFileService novaFileService(FileStorageClientProvider fileStorageClientProvider) {
        return new NovaFileServiceImpl(fileStorageClientProvider);
    }
}
