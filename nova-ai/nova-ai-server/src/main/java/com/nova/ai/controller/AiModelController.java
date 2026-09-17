package com.nova.ai.controller;

import com.nova.ai.core.domain.entity.AiModel;
import com.nova.ai.core.domain.entity.AiModelProvider;
import com.nova.ai.core.service.AiModelConfigService;
import com.nova.core.debounce.annotation.Debounce;
import com.nova.core.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@Tag(name = "AI 模型配置")
@RestController
@RequestMapping("/ai/model")
@RequiredArgsConstructor
public class AiModelController {

    private final AiModelConfigService modelConfigService;

    @Operation(summary = "提供商列表")
    @GetMapping("/provider/list")
    public R<List<AiModelProvider>> providers() {
        return R.ok(modelConfigService.listProviders().stream()
                .map(modelConfigService::mask)
                .collect(Collectors.toList()));
    }

    @Operation(summary = "提供商详情")
    @GetMapping("/provider/{id}")
    public R<AiModelProvider> providerDetail(@PathVariable Long id) {
        return R.ok(modelConfigService.mask(modelConfigService.getProvider(id)));
    }

    @Debounce
    @Operation(summary = "保存提供商（含 API Key）")
    @PostMapping("/provider")
    public R<Long> saveProvider(@RequestBody AiModelProvider provider) {
        return R.ok(modelConfigService.saveProvider(provider));
    }

    @Debounce
    @Operation(summary = "删除提供商")
    @DeleteMapping("/provider/{id}")
    public R<Void> deleteProvider(@PathVariable Long id) {
        modelConfigService.deleteProvider(id);
        return R.ok();
    }

    @Operation(summary = "启用模型列表（运行时）")
    @GetMapping("/list")
    public R<List<AiModel>> models(@RequestParam(required = false) Long providerId) {
        return R.ok(modelConfigService.listModels(providerId));
    }

    @Operation(summary = "管理端模型列表（含停用）")
    @GetMapping("/admin/list")
    public R<List<AiModel>> adminModels(@RequestParam(required = false) Long providerId,
                                        @RequestParam(required = false) String modelName) {
        return R.ok(modelConfigService.listAllModels(providerId, modelName));
    }

    @Operation(summary = "模型详情")
    @GetMapping("/{id}")
    public R<AiModel> detail(@PathVariable Long id) {
        return R.ok(modelConfigService.getModel(id));
    }

    @Debounce
    @Operation(summary = "保存模型")
    @PostMapping
    public R<Long> saveModel(@RequestBody AiModel model) {
        return R.ok(modelConfigService.saveModel(model));
    }

    @Debounce
    @Operation(summary = "删除模型")
    @DeleteMapping("/{id}")
    public R<Void> deleteModel(@PathVariable Long id) {
        modelConfigService.deleteModel(id);
        return R.ok();
    }
}
