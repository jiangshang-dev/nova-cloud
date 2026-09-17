package com.nova.demo.service;

import com.nova.demo.api.dto.TodoCreateRequest;
import com.nova.demo.api.dto.TodoUpdateRequest;
import com.nova.demo.domain.DemoTodo;

import java.util.List;

public interface TodoService {

    List<DemoTodo> list(String title);

    DemoTodo getById(Long id);

    DemoTodo create(TodoCreateRequest request);

    DemoTodo update(Long id, TodoUpdateRequest request);

    void delete(Long id);

    DemoTodo markDone(Long id);
}
