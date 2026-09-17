package com.nova.demo.controller;

import com.nova.core.result.R;
import com.nova.demo.api.RemoteTodoApi;
import com.nova.demo.api.dto.TodoCreateRequest;
import com.nova.demo.api.dto.TodoUpdateRequest;
import com.nova.demo.api.vo.TodoVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * OpenFeign 远程调用演示：本 Controller 模拟「其他微服务」通过 {@link RemoteTodoApi} 调用 demo。
 * <p>
 * 实际流量：本服务 → Feign（带内部 Token）→ Nacos 发现 nova-demo → /inner/demo/todo/**
 * <p>
 * 其他业务服务用法：依赖 {@code nova-demo-api}，注入 {@code RemoteTodoApi} 即可，无需再写 HTTP 客户端。
 */
@Tag(name = "Demo Feign 调用 Todo")
@RestController
@RequestMapping("/demo/feign/todo")
@RequiredArgsConstructor
public class DemoFeignTodoController {

    private final RemoteTodoApi remoteTodoApi;

    @Operation(summary = "【Feign】列表")
    @GetMapping("/list")
    public R<List<TodoVO>> list(@RequestParam(required = false) String title) {
        return remoteTodoApi.list(title);
    }

    @Operation(summary = "【Feign】详情")
    @GetMapping("/{id}")
    public R<TodoVO> detail(@PathVariable Long id) {
        return remoteTodoApi.getById(id);
    }

    @Operation(summary = "【Feign】新建")
    @PostMapping
    public R<TodoVO> create(@Valid @RequestBody TodoCreateRequest request) {
        return remoteTodoApi.create(request);
    }

    @Operation(summary = "【Feign】更新")
    @PutMapping("/{id}")
    public R<TodoVO> update(@PathVariable Long id, @RequestBody TodoUpdateRequest request) {
        return remoteTodoApi.update(id, request);
    }

    @Operation(summary = "【Feign】删除")
    @DeleteMapping("/{id}")
    public R<Void> delete(@PathVariable Long id) {
        return remoteTodoApi.delete(id);
    }

    @Operation(summary = "【Feign】标记完成")
    @PostMapping("/{id}/done")
    public R<TodoVO> markDone(@PathVariable Long id) {
        return remoteTodoApi.markDone(id);
    }
}
