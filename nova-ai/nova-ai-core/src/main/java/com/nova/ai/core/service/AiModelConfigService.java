package com.nova.ai.core.service;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nova.ai.core.domain.entity.AiModel;
import com.nova.ai.core.domain.entity.AiModelProvider;
import com.nova.ai.core.mapper.AiModelMapper;
import com.nova.ai.core.mapper.AiModelProviderMapper;
import com.nova.ai.model.AiModelRuntimeConfig;
import com.nova.core.utils.AssertUtil;
import com.nova.core.utils.IdGeneratorUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AiModelConfigService {

    private final AiModelProviderMapper providerMapper;
    private final AiModelMapper modelMapper;

    public List<AiModelProvider> listProviders() {
        return providerMapper.selectList(new LambdaQueryWrapper<AiModelProvider>()
                .orderByAsc(AiModelProvider::getId));
    }

    public List<AiModel> listModels(Long providerId) {
        return modelMapper.selectList(new LambdaQueryWrapper<AiModel>()
                .eq(providerId != null, AiModel::getProviderId, providerId)
                .eq(AiModel::getStatus, 1)
                .orderByAsc(AiModel::getId));
    }

    @Transactional(rollbackFor = Exception.class)
    public Long saveProvider(AiModelProvider provider) {
        if (provider.getId() == null) {
            provider.setId(IdGeneratorUtil.nextId());
            provider.setTenantId(provider.getTenantId() == null ? 0L : provider.getTenantId());
            provider.setStatus(provider.getStatus() == null ? 1 : provider.getStatus());
            provider.setIsDeleted(0);
            providerMapper.insert(provider);
        } else {
            AiModelProvider db = providerMapper.selectById(provider.getId());
            AssertUtil.notNull(db, "提供商不存在");
            if (StrUtil.isNotBlank(provider.getApiKeyCipher()) && provider.getApiKeyCipher().contains("*")) {
                provider.setApiKeyCipher(db.getApiKeyCipher());
            }
            providerMapper.updateById(provider);
        }
        return provider.getId();
    }

    @Transactional(rollbackFor = Exception.class)
    public Long saveModel(AiModel model) {
        if (model.getId() == null) {
            model.setId(IdGeneratorUtil.nextId());
            model.setTenantId(model.getTenantId() == null ? 0L : model.getTenantId());
            model.setStatus(model.getStatus() == null ? 1 : model.getStatus());
            model.setModelType(StrUtil.blankToDefault(model.getModelType(), "chat"));
            model.setIsDeleted(0);
            modelMapper.insert(model);
        } else {
            modelMapper.updateById(model);
        }
        return model.getId();
    }

    public AiModelRuntimeConfig loadRuntimeConfig(Long modelId) {
        AiModel model = modelMapper.selectById(modelId);
        AssertUtil.notNull(model, "模型不存在");
        AssertUtil.isTrue(Integer.valueOf(1).equals(model.getStatus()), "模型已停用");
        AiModelProvider provider = providerMapper.selectById(model.getProviderId());
        AssertUtil.notNull(provider, "模型提供商不存在");
        AssertUtil.isTrue(Integer.valueOf(1).equals(provider.getStatus()), "模型提供商已停用");

        return AiModelRuntimeConfig.builder()
                .modelId(model.getId())
                .providerId(provider.getId())
                .providerCode(provider.getProviderCode())
                .modelCode(model.getModelCode())
                .modelName(model.getModelName())
                .modelType(model.getModelType())
                .apiKey(provider.getApiKeyCipher())
                .baseUrl(provider.getBaseUrl())
                .maxTokens(model.getMaxTokens())
                .stream(false)
                .build();
    }

    public AiModelRuntimeConfig loadRuntimeConfigByCode(String modelCode) {
        AiModel model = modelMapper.selectOne(new LambdaQueryWrapper<AiModel>()
                .eq(AiModel::getModelCode, modelCode)
                .eq(AiModel::getStatus, 1)
                .last("LIMIT 1"));
        AssertUtil.notNull(model, "模型不存在: " + modelCode);
        return loadRuntimeConfig(model.getId());
    }

    public AiModelProvider mask(AiModelProvider provider) {
        if (provider != null && StrUtil.isNotBlank(provider.getApiKeyCipher())) {
            String key = provider.getApiKeyCipher();
            provider.setApiKeyCipher(key.length() <= 4 ? "****" : key.substring(0, 4) + "****");
        }
        return provider;
    }
}
