package com.nova.ai.core.service;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.nova.ai.core.domain.entity.AiAgent;
import com.nova.ai.core.mapper.AiAgentMapper;
import com.nova.core.exception.ServiceException;
import com.nova.core.utils.IdGeneratorUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AiAgentAdminService {

    private final AiAgentMapper aiAgentMapper;

    public Page<AiAgent> page(long current, long size, String agentName) {
        return aiAgentMapper.selectPage(new Page<>(current, size), new LambdaQueryWrapper<AiAgent>()
                .like(StrUtil.isNotBlank(agentName), AiAgent::getAgentName, agentName)
                .orderByDesc(AiAgent::getId));
    }

    public AiAgent getById(Long id) {
        AiAgent agent = aiAgentMapper.selectById(id);
        if (agent == null) {
            throw new ServiceException("Agent 不存在");
        }
        return agent;
    }

    @Transactional(rollbackFor = Exception.class)
    public Long save(AiAgent agent) {
        if (agent.getId() == null) {
            agent.setId(IdGeneratorUtil.nextId());
            agent.setTenantId(agent.getTenantId() == null ? 0L : agent.getTenantId());
            agent.setStatus(agent.getStatus() == null ? 1 : agent.getStatus());
            agent.setIsDeleted(0);
            Long count = aiAgentMapper.selectCount(new LambdaQueryWrapper<AiAgent>()
                    .eq(AiAgent::getTenantId, agent.getTenantId())
                    .eq(AiAgent::getAgentCode, agent.getAgentCode()));
            if (count != null && count > 0) {
                throw new ServiceException("Agent 编码已存在");
            }
            aiAgentMapper.insert(agent);
        } else {
            getById(agent.getId());
            aiAgentMapper.updateById(agent);
        }
        return agent.getId();
    }

    public void delete(Long id) {
        getById(id);
        aiAgentMapper.deleteById(id);
    }
}
