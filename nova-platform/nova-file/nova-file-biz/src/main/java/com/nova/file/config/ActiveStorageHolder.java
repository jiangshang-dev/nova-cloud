package com.nova.file.config;

import com.nova.file.domain.entity.FileStorage;
import com.nova.file.starter.client.FileStorageClient;
import com.nova.file.starter.factory.FileStorageClientFactory;
import com.nova.file.starter.model.StorageConfig;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.concurrent.atomic.AtomicReference;

/**
 * 当前启用的存储客户端持有者（全局仅允许一个启用）。
 */
@Component
@RequiredArgsConstructor
public class ActiveStorageHolder {

    private final FileStorageClientFactory clientFactory;
    private final AtomicReference<Holder> ref = new AtomicReference<>();

    public synchronized void refresh(FileStorage storage) {
        Holder old = ref.get();
        if (old != null) {
            try {
                old.client().close();
            } catch (Exception ignored) {
                // ignore
            }
        }
        StorageConfig config = toConfig(storage);
        FileStorageClient client = clientFactory.create(config);
        ref.set(new Holder(storage, client));
    }

    public void clear() {
        Holder old = ref.getAndSet(null);
        if (old != null) {
            try {
                old.client().close();
            } catch (Exception ignored) {
                // ignore
            }
        }
    }

    public FileStorageClient requireClient() {
        Holder holder = ref.get();
        if (holder == null) {
            throw new IllegalStateException("未启用任何文件服务器，请在管理后台开启");
        }
        return holder.client();
    }

    public FileStorage requireStorage() {
        Holder holder = ref.get();
        if (holder == null) {
            throw new IllegalStateException("未启用任何文件服务器，请在管理后台开启");
        }
        return holder.storage();
    }

    public static StorageConfig toConfig(FileStorage storage) {
        return StorageConfig.builder()
                .id(storage.getId())
                .storageCode(storage.getStorageCode())
                .storageName(storage.getStorageName())
                .storageType(storage.getStorageType())
                .endpoint(storage.getEndpoint())
                .region(storage.getRegion())
                .accessKey(storage.getAccessKey())
                .secretKey(storage.getSecretKey())
                .bucketName(storage.getBucketName())
                .basePath(storage.getBasePath())
                .domain(storage.getDomain())
                .extConfig(storage.getExtConfig())
                .build();
    }

    private record Holder(FileStorage storage, FileStorageClient client) {
    }
}
