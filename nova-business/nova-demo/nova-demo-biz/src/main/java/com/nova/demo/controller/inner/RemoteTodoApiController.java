package com.nova.demo.controller.inner;

import com.nova.core.result.R;
import com.nova.demo.api.RemoteTodoApi;
import com.nova.demo.api.constant.DemoServiceConstants;
import com.nova.demo.api.dto.TodoCreateRequest;
import com.nova.demo.api.dto.TodoUpdateRequest;
import com.nova.demo.api.vo.TodoVO;
import com.nova.demo.controller.TodoController;
import com.nova.demo.service.TodoService;
import io.swagger.v3.oas.annotations.Hidden;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 内部 Feign 入口：实现 {@link RemoteTodoApi}，仅接受携带内部 Token 的服务间调用。
 */
@Hidden
@RestController
@RequestMapping(DemoServiceConstants.INNER_TODO_PATH)
@RequiredArgsConstructor
public class RemoteTodoApiController implements RemoteTodoApi {

    private final TodoService todoService;

    @Override
    public R<List<TodoVO>> list(String title) {
        return R.ok(todoService.list(title).stream().map(TodoController::toVo).toList());
    }

    @Override
    public R<TodoVO> getById(Long id) {
        return R.ok(TodoController.toVo(todoService.getById(id)));
    }

    @Override
    public R<TodoVO> create(@Valid TodoCreateRequest request) {
        return R.ok(TodoController.toVo(todoService.create(request)));
    }

    @Override
    public R<TodoVO> update(Long id, TodoUpdateRequest request) {
        return R.ok(TodoController.toVo(todoService.update(id, request)));
    }

    @Override
    public R<Void> delete(Long id) {
        todoService.delete(id);
        return R.ok();
    }

    @Override
    public R<TodoVO> markDone(Long id) {
        return R.ok(TodoController.toVo(todoService.markDone(id)));
    }
}
