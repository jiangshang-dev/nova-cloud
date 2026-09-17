package com.nova.ai.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.nova.ai.core.domain.entity.AiAgent;
import com.nova.ai.core.service.AiAgentAdminService;
import com.nova.core.debounce.annotation.Debounce;
import com.nova.core.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@Tag(name = "AI Agent 管理")
@RestController
@RequestMapping("/ai/agent")
@RequiredArgsConstructor
public class AiAgentController {

    private final AiAgentAdminService agentAdminService;

    @Operation(summary = "Agent 分页")
    @GetMapping("/page")
    public R<Page<AiAgent>> page(@RequestParam(defaultValue = "1") long current,
                                 @RequestParam(defaultValue = "10") long size,
                                 @RequestParam(required = false) String agentName) {
        return R.ok(agentAdminService.page(current, size, agentName));
    }

    @Operation(summary = "Agent 详情")
    @GetMapping("/{id}")
    public R<AiAgent> detail(@PathVariable Long id) {
        return R.ok(agentAdminService.getById(id));
    }

    @Debounce
    @Operation(summary = "保存 Agent")
    @PostMapping
    public R<Long> save(@RequestBody AiAgent agent) {
        return R.ok(agentAdminService.save(agent));
    }

    @Debounce
    @Operation(summary = "删除 Agent")
    @DeleteMapping("/{id}")
    public R<Void> delete(@PathVariable Long id) {
        agentAdminService.delete(id);
        return R.ok();
    }
}
