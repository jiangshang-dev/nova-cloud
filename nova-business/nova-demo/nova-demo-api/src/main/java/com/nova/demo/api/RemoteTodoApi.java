package com.nova.demo.api;

import com.nova.core.result.R;
import com.nova.demo.api.constant.DemoServiceConstants;
import com.nova.demo.api.dto.TodoCreateRequest;
import com.nova.demo.api.dto.TodoUpdateRequest;
import com.nova.demo.api.vo.TodoVO;
import jakarta.validation.Valid;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

/**
 * Demo Todo 远程 API（服务间调用，自动携带内部免登 Token）。
 * <p>
 * 其他服务引入 {@code nova-demo-api}，并启用：
 * {@code @EnableFeignClients(basePackages = "com.nova.demo.api")}。
 */
@FeignClient(contextId = "remoteTodoApi", value = DemoServiceConstants.SERVICE_NAME, path = DemoServiceConstants.INNER_TODO_PATH)
public interface RemoteTodoApi {

    @GetMapping("/list")
    R<List<TodoVO>> list(@RequestParam(value = "title", required = false) String title);

    @GetMapping("/{id}")
    R<TodoVO> getById(@PathVariable("id") Long id);

    @PostMapping
    R<TodoVO> create(@Valid @RequestBody TodoCreateRequest request);

    @PutMapping("/{id}")
    R<TodoVO> update(@PathVariable("id") Long id, @RequestBody TodoUpdateRequest request);

    @DeleteMapping("/{id}")
    R<Void> delete(@PathVariable("id") Long id);

    @PostMapping("/{id}/done")
    R<TodoVO> markDone(@PathVariable("id") Long id);
}
