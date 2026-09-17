package com.nova.ai.core.service;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.nova.ai.core.domain.entity.AiKnowledgeBase;
import com.nova.ai.core.mapper.AiKnowledgeBaseMapper;
import com.nova.core.exception.ServiceException;
import com.nova.core.utils.IdGeneratorUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AiKnowledgeAdminService {

    private final AiKnowledgeBaseMapper knowledgeBaseMapper;

    public Page<AiKnowledgeBase> page(long current, long size, String kbName) {
        return knowledgeBaseMapper.selectPage(new Page<>(current, size), new LambdaQueryWrapper<AiKnowledgeBase>()
                .like(StrUtil.isNotBlank(kbName), AiKnowledgeBase::getKbName, kbName)
                .orderByDesc(AiKnowledgeBase::getId));
    }

    public AiKnowledgeBase getById(Long id) {
        AiKnowledgeBase kb = knowledgeBaseMapper.selectById(id);
        if (kb == null) {
            throw new ServiceException("知识库不存在");
        }
        return kb;
    }

    @Transactional(rollbackFor = Exception.class)
    public Long save(AiKnowledgeBase kb) {
        if (kb.getId() == null) {
            kb.setId(IdGeneratorUtil.nextId());
            kb.setTenantId(kb.getTenantId() == null ? 0L : kb.getTenantId());
            kb.setStatus(kb.getStatus() == null ? 1 : kb.getStatus());
            kb.setChunkSize(kb.getChunkSize() == null ? 500 : kb.getChunkSize());
            kb.setChunkOverlap(kb.getChunkOverlap() == null ? 50 : kb.getChunkOverlap());
            kb.setIsDeleted(0);
            Long count = knowledgeBaseMapper.selectCount(new LambdaQueryWrapper<AiKnowledgeBase>()
                    .eq(AiKnowledgeBase::getTenantId, kb.getTenantId())
                    .eq(AiKnowledgeBase::getKbCode, kb.getKbCode()));
            if (count != null && count > 0) {
                throw new ServiceException("知识库编码已存在");
            }
            knowledgeBaseMapper.insert(kb);
        } else {
            getById(kb.getId());
            knowledgeBaseMapper.updateById(kb);
        }
        return kb.getId();
    }

    public void delete(Long id) {
        getById(id);
        knowledgeBaseMapper.deleteById(id);
    }
}
