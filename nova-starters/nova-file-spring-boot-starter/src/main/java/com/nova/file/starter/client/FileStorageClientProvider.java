package com.nova.file.starter.client;

/**
 * 提供当前启用的存储客户端（由文件服务后台配置驱动）。
 */
@FunctionalInterface
public interface FileStorageClientProvider {

    FileStorageClient requireClient();
}
