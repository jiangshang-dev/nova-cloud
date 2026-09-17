package com.nova.ai.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.nova.ai.core.domain.entity.AiWorkflow;
import com.nova.ai.core.service.AiWorkflowAdminService;
import com.nova.core.debounce.annotation.Debounce;
import com.nova.core.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@Tag(name = "AI 工作流管理")
@RestController
@RequestMapping("/ai/workflow")
@RequiredArgsConstructor
public class AiWorkflowController {

    private final AiWorkflowAdminService workflowAdminService;

    @Operation(summary = "工作流分页")
    @GetMapping("/page")
    public R<Page<AiWorkflow>> page(@RequestParam(defaultValue = "1") long current,
                                    @RequestParam(defaultValue = "10") long size,
                                    @RequestParam(required = false) String workflowName) {
        return R.ok(workflowAdminService.page(current, size, workflowName));
    }

    @Operation(summary = "工作流详情")
    @GetMapping("/{id}")
    public R<AiWorkflow> detail(@PathVariable Long id) {
        return R.ok(workflowAdminService.getById(id));
    }

    @Debounce
    @Operation(summary = "保存工作流")
    @PostMapping
    public R<Long> save(@RequestBody AiWorkflow workflow) {
        return R.ok(workflowAdminService.save(workflow));
    }

    @Debounce
    @Operation(summary = "删除工作流")
    @DeleteMapping("/{id}")
    public R<Void> delete(@PathVariable Long id) {
        workflowAdminService.delete(id);
        return R.ok();
    }
}
