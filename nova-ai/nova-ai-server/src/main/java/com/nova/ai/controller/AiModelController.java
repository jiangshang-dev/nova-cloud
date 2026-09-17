package com.nova.ai.controller;

import com.nova.ai.core.domain.entity.AiModel;
import com.nova.ai.core.domain.entity.AiModelProvider;
import com.nova.ai.core.service.AiModelConfigService;
import com.nova.core.debounce.annotation.Debounce;
import com.nova.core.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

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

    @Debounce
    @Operation(summary = "保存提供商（含 API Key）")
    @PostMapping("/provider")
    public R<Long> saveProvider(@RequestBody AiModelProvider provider) {
        return R.ok(modelConfigService.saveProvider(provider));
    }

    @Operation(summary = "模型列表")
    @GetMapping("/list")
    public R<List<AiModel>> models(@RequestParam(required = false) Long providerId) {
        return R.ok(modelConfigService.listModels(providerId));
    }

    @Debounce
    @Operation(summary = "保存模型")
    @PostMapping
    public R<Long> saveModel(@RequestBody AiModel model) {
        return R.ok(modelConfigService.saveModel(model));
    }
}
