package com.nova.demo.service.impl;

import com.nova.core.utils.AssertUtil;
import com.nova.core.utils.IdGeneratorUtil;
import com.nova.demo.api.dto.TodoCreateRequest;
import com.nova.demo.api.dto.TodoUpdateRequest;
import com.nova.demo.domain.DemoTodo;
import com.nova.demo.service.TodoService;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

@Service
public class TodoServiceImpl implements TodoService {

    private final Map<Long, DemoTodo> store = new ConcurrentHashMap<>();

    @Override
    public List<DemoTodo> list(String title) {
        return store.values().stream()
                .filter(item -> title == null || title.isBlank()
                        || (item.getTitle() != null && item.getTitle().contains(title)))
                .sorted(Comparator.comparing(DemoTodo::getGmtCreate).reversed())
                .collect(Collectors.toCollection(ArrayList::new));
    }

    @Override
    public DemoTodo getById(Long id) {
        DemoTodo todo = store.get(id);
        AssertUtil.notNull(todo, "Todo 不存在");
        return todo;
    }

    @Override
    public DemoTodo create(TodoCreateRequest request) {
        AssertUtil.isNotBlank(request.getTitle(), "title 不能为空");
        long id = IdGeneratorUtil.nextId();
        LocalDateTime now = LocalDateTime.now();
        DemoTodo todo = new DemoTodo();
        todo.setId(id);
        todo.setTitle(request.getTitle());
        todo.setContent(request.getContent());
        todo.setStatus(0);
        todo.setGmtCreate(now);
        todo.setGmtModified(now);
        store.put(id, todo);
        return todo;
    }

    @Override
    public DemoTodo update(Long id, TodoUpdateRequest request) {
        DemoTodo db = getById(id);
        if (request.getTitle() != null) {
            db.setTitle(request.getTitle());
        }
        if (request.getContent() != null) {
            db.setContent(request.getContent());
        }
        if (request.getStatus() != null) {
            db.setStatus(request.getStatus());
        }
        db.setGmtModified(LocalDateTime.now());
        store.put(db.getId(), db);
        return db;
    }

    @Override
    public void delete(Long id) {
        AssertUtil.notNull(store.remove(id), "Todo 不存在");
    }

    @Override
    public DemoTodo markDone(Long id) {
        DemoTodo db = getById(id);
        db.setStatus(1);
        db.setGmtModified(LocalDateTime.now());
        store.put(db.getId(), db);
        return db;
    }
}
