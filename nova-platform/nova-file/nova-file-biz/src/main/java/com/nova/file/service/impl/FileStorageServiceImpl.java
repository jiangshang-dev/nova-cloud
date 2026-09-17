package com.nova.file.service.impl;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.nova.core.utils.AssertUtil;
import com.nova.core.utils.IdGeneratorUtil;
import com.nova.file.config.ActiveStorageHolder;
import com.nova.file.domain.entity.FileStorage;
import com.nova.file.mapper.FileStorageMapper;
import com.nova.file.service.FileStorageService;
import com.nova.file.starter.client.FileStorageClient;
import com.nova.file.starter.factory.FileStorageClientFactory;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FileStorageServiceImpl implements FileStorageService {

    private final FileStorageMapper fileStorageMapper;
    private final ActiveStorageHolder activeStorageHolder;
    private final FileStorageClientFactory clientFactory;

    @Override
    @PostConstruct
    public void initActive() {
        FileStorage active = fileStorageMapper.selectOne(new LambdaQueryWrapper<FileStorage>()
                .eq(FileStorage::getStatus, 1)
                .eq(FileStorage::getIsDefault, 1)
                .last("LIMIT 1"));
        if (active == null) {
            active = fileStorageMapper.selectOne(new LambdaQueryWrapper<FileStorage>()
                    .eq(FileStorage::getStatus, 1)
                    .orderByDesc(FileStorage::getIsDefault)
                    .last("LIMIT 1"));
        }
        if (active != null) {
            activeStorageHolder.refresh(active);
        }
    }

    @Override
    public List<FileStorage> listAll() {
        return fileStorageMapper.selectList(new LambdaQueryWrapper<FileStorage>()
                .orderByDesc(FileStorage::getIsDefault)
                .orderByAsc(FileStorage::getId));
    }

    @Override
    public FileStorage getById(Long id) {
        FileStorage storage = fileStorageMapper.selectById(id);
        AssertUtil.notNull(storage, "存储配置不存在");
        return storage;
    }

    @Override
    public FileStorage getByCode(String storageCode) {
        AssertUtil.isTrue(StrUtil.isNotBlank(storageCode), "storageCode 不能为空");
        FileStorage storage = fileStorageMapper.selectOne(new LambdaQueryWrapper<FileStorage>()
                .eq(FileStorage::getStorageCode, storageCode)
                .last("LIMIT 1"));
        AssertUtil.notNull(storage, "存储配置不存在");
        return storage;
    }

    /**
     * 兼容前端雪花 ID 精度丢失：优先按 id，找不到再按 storageCode。
     */
    @Override
    public FileStorage resolve(Long id, String storageCode) {
        if (id != null) {
            FileStorage byId = fileStorageMapper.selectById(id);
            if (byId != null) {
                return byId;
            }
        }
        if (StrUtil.isNotBlank(storageCode)) {
            return getByCode(storageCode);
        }
        throw new IllegalArgumentException("存储配置不存在");
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long create(FileStorage storage) {
        AssertUtil.isTrue(StrUtil.isNotBlank(storage.getStorageCode()), "storageCode 不能为空");
        AssertUtil.isTrue(StrUtil.isNotBlank(storage.getStorageType()), "storageType 不能为空");
        Long count = fileStorageMapper.selectCount(new LambdaQueryWrapper<FileStorage>()
                .eq(FileStorage::getStorageCode, storage.getStorageCode()));
        AssertUtil.isTrue(count == 0, "storageCode 已存在");

        storage.setId(IdGeneratorUtil.nextId());
        storage.setTenantId(storage.getTenantId() == null ? 0L : storage.getTenantId());
        storage.setStatus(0);
        storage.setIsDefault(0);
        storage.setIsDeleted(0);
        fileStorageMapper.insert(storage);
        return storage.getId();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void update(FileStorage storage) {
        AssertUtil.notNull(storage.getId(), "id 不能为空");
        FileStorage db = getById(storage.getId());
        storage.setStorageCode(db.getStorageCode());
        storage.setStatus(db.getStatus());
        storage.setIsDefault(db.getIsDefault());
        fileStorageMapper.updateById(storage);
        if (Integer.valueOf(1).equals(db.getStatus())) {
            activeStorageHolder.refresh(getById(storage.getId()));
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id) {
        FileStorage db = getById(id);
        AssertUtil.isTrue(!Integer.valueOf(1).equals(db.getStatus()), "请先关闭后再删除");
        fileStorageMapper.deleteById(id);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void enable(Long id) {
        FileStorage target = getById(id);
        try (FileStorageClient client = clientFactory.create(ActiveStorageHolder.toConfig(target))) {
            client.ping();
        } catch (Exception e) {
            throw new IllegalStateException("连通性检测失败: " + e.getMessage(), e);
        }

        fileStorageMapper.update(null, new LambdaUpdateWrapper<FileStorage>()
                .set(FileStorage::getStatus, 0)
                .set(FileStorage::getIsDefault, 0)
                .ne(FileStorage::getId, id));

        FileStorage update = new FileStorage();
        update.setId(id);
        update.setStatus(1);
        update.setIsDefault(1);
        fileStorageMapper.updateById(update);

        activeStorageHolder.refresh(getById(id));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void disable(Long id) {
        FileStorage db = getById(id);
        AssertUtil.isTrue(Integer.valueOf(1).equals(db.getStatus()), "当前未启用");
        FileStorage update = new FileStorage();
        update.setId(id);
        update.setStatus(0);
        update.setIsDefault(0);
        fileStorageMapper.updateById(update);
        activeStorageHolder.clear();
    }

    @Override
    public void test(Long id) {
        FileStorage storage = getById(id);
        try (FileStorageClient client = clientFactory.create(ActiveStorageHolder.toConfig(storage))) {
            client.ping();
        } catch (Exception e) {
            throw new IllegalStateException("连通性检测失败: " + e.getMessage(), e);
        }
    }

    @Override
    public FileStorage maskSecret(FileStorage storage) {
        if (storage == null) {
            return null;
        }
        if (StrUtil.isNotBlank(storage.getSecretKey())) {
            storage.setSecretKey("******");
        }
        if (StrUtil.isNotBlank(storage.getAccessKey()) && storage.getAccessKey().length() > 4) {
            storage.setAccessKey(storage.getAccessKey().substring(0, 4) + "****");
        }
        return storage;
    }
}
