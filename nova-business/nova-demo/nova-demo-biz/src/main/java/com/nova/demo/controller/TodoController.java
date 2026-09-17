package com.nova.demo.controller;

import com.nova.core.debounce.annotation.Debounce;
import com.nova.core.result.R;
import com.nova.demo.api.dto.TodoCreateRequest;
import com.nova.demo.api.dto.TodoUpdateRequest;
import com.nova.demo.api.vo.TodoVO;
import com.nova.demo.domain.DemoTodo;
import com.nova.demo.service.TodoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
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
 * Todo 用户侧 API（需登录 JWT）。
 */
@Tag(name = "Demo Todo")
@RestController
@RequestMapping("/demo/todo")
@RequiredArgsConstructor
public class TodoController {

    private final TodoService todoService;

    @Operation(summary = "Todo 列表")
    @GetMapping("/list")
    public R<List<TodoVO>> list(@RequestParam(required = false) String title) {
        return R.ok(todoService.list(title).stream().map(TodoController::toVo).toList());
    }

    @Operation(summary = "Todo 详情")
    @GetMapping("/{id}")
    public R<TodoVO> detail(@PathVariable Long id) {
        return R.ok(toVo(todoService.getById(id)));
    }

    @Debounce
    @Operation(summary = "新建 Todo")
    @PostMapping
    public R<TodoVO> create(@Valid @RequestBody TodoCreateRequest request) {
        return R.ok(toVo(todoService.create(request)));
    }

    @Debounce
    @Operation(summary = "更新 Todo")
    @PutMapping("/{id}")
    public R<TodoVO> update(@PathVariable Long id, @RequestBody TodoUpdateRequest request) {
        return R.ok(toVo(todoService.update(id, request)));
    }

    @Debounce
    @Operation(summary = "删除 Todo")
    @DeleteMapping("/{id}")
    public R<Void> delete(@PathVariable Long id) {
        todoService.delete(id);
        return R.ok();
    }

    @Debounce
    @Operation(summary = "标记完成")
    @PostMapping("/{id}/done")
    public R<TodoVO> markDone(@PathVariable Long id) {
        return R.ok(toVo(todoService.markDone(id)));
    }

    public static TodoVO toVo(DemoTodo todo) {
        TodoVO vo = new TodoVO();
        BeanUtils.copyProperties(todo, vo);
        return vo;
    }
}
