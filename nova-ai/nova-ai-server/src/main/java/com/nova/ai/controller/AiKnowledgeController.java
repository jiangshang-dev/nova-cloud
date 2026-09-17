package com.nova.ai.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.nova.ai.core.domain.entity.AiKnowledgeBase;
import com.nova.ai.core.service.AiKnowledgeAdminService;
import com.nova.core.debounce.annotation.Debounce;
import com.nova.core.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@Tag(name = "AI 知识库管理")
@RestController
@RequestMapping("/ai/knowledge")
@RequiredArgsConstructor
public class AiKnowledgeController {

    private final AiKnowledgeAdminService knowledgeAdminService;

    @Operation(summary = "知识库分页")
    @GetMapping("/page")
    public R<Page<AiKnowledgeBase>> page(@RequestParam(defaultValue = "1") long current,
                                         @RequestParam(defaultValue = "10") long size,
                                         @RequestParam(required = false) String kbName) {
        return R.ok(knowledgeAdminService.page(current, size, kbName));
    }

    @Operation(summary = "知识库详情")
    @GetMapping("/{id}")
    public R<AiKnowledgeBase> detail(@PathVariable Long id) {
        return R.ok(knowledgeAdminService.getById(id));
    }

    @Debounce
    @Operation(summary = "保存知识库")
    @PostMapping
    public R<Long> save(@RequestBody AiKnowledgeBase kb) {
        return R.ok(knowledgeAdminService.save(kb));
    }

    @Debounce
    @Operation(summary = "删除知识库")
    @DeleteMapping("/{id}")
    public R<Void> delete(@PathVariable Long id) {
        knowledgeAdminService.delete(id);
        return R.ok();
    }
}
