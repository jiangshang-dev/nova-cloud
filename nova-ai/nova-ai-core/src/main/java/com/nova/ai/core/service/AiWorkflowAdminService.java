package com.nova.ai.core.service;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.nova.ai.core.domain.entity.AiWorkflow;
import com.nova.ai.core.mapper.AiWorkflowMapper;
import com.nova.core.exception.ServiceException;
import com.nova.core.utils.IdGeneratorUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AiWorkflowAdminService {

    private final AiWorkflowMapper workflowMapper;

    public Page<AiWorkflow> page(long current, long size, String workflowName) {
        return workflowMapper.selectPage(new Page<>(current, size), new LambdaQueryWrapper<AiWorkflow>()
                .like(StrUtil.isNotBlank(workflowName), AiWorkflow::getWorkflowName, workflowName)
                .orderByDesc(AiWorkflow::getId));
    }

    public AiWorkflow getById(Long id) {
        AiWorkflow workflow = workflowMapper.selectById(id);
        if (workflow == null) {
            throw new ServiceException("工作流不存在");
        }
        return workflow;
    }

    @Transactional(rollbackFor = Exception.class)
    public Long save(AiWorkflow workflow) {
        if (workflow.getId() == null) {
            workflow.setId(IdGeneratorUtil.nextId());
            workflow.setTenantId(workflow.getTenantId() == null ? 0L : workflow.getTenantId());
            workflow.setVersion(workflow.getVersion() == null ? 1 : workflow.getVersion());
            workflow.setStatus(workflow.getStatus() == null ? 0 : workflow.getStatus());
            workflow.setIsDeleted(0);
            Long count = workflowMapper.selectCount(new LambdaQueryWrapper<AiWorkflow>()
                    .eq(AiWorkflow::getTenantId, workflow.getTenantId())
                    .eq(AiWorkflow::getWorkflowCode, workflow.getWorkflowCode()));
            if (count != null && count > 0) {
                throw new ServiceException("工作流编码已存在");
            }
            workflowMapper.insert(workflow);
        } else {
            getById(workflow.getId());
            workflowMapper.updateById(workflow);
        }
        return workflow.getId();
    }

    public void delete(Long id) {
        getById(id);
        workflowMapper.deleteById(id);
    }
}
