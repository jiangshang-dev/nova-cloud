package com.nova.file.service;

import com.nova.file.domain.entity.FileStorage;

import java.util.List;

/**
 * 文件存储配置服务。
 */
public interface FileStorageService {

    void initActive();

    List<FileStorage> listAll();

    FileStorage getById(Long id);

    Long create(FileStorage storage);

    void update(FileStorage storage);

    void delete(Long id);

    /** 启用指定存储，并关闭其余全部 */
    void enable(Long id);

    void disable(Long id);

    void test(Long id);

    /** 脱敏后返回 */
    FileStorage maskSecret(FileStorage storage);
}
