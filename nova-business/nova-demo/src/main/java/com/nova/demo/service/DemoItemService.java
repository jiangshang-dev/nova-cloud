package com.nova.demo.service;

import com.nova.core.utils.AssertUtil;
import com.nova.core.utils.IdGeneratorUtil;
import com.nova.demo.domain.DemoItem;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

@Service
public class DemoItemService {

    private final Map<Long, DemoItem> store = new ConcurrentHashMap<>();

    public List<DemoItem> list(String title) {
        return store.values().stream()
                .filter(item -> title == null || title.isBlank()
                        || (item.getTitle() != null && item.getTitle().contains(title)))
                .sorted(Comparator.comparing(DemoItem::getGmtCreate).reversed())
                .collect(Collectors.toCollection(ArrayList::new));
    }

    public DemoItem getById(Long id) {
        DemoItem item = store.get(id);
        AssertUtil.notNull(item, "记录不存在");
        return item;
    }

    public DemoItem create(DemoItem item) {
        AssertUtil.isNotBlank(item.getTitle(), "title 不能为空");
        long id = IdGeneratorUtil.nextId();
        LocalDateTime now = LocalDateTime.now();
        item.setId(id);
        item.setGmtCreate(now);
        item.setGmtModified(now);
        store.put(id, item);
        return item;
    }

    public DemoItem update(DemoItem item) {
        AssertUtil.notNull(item.getId(), "id 不能为空");
        DemoItem db = getById(item.getId());
        if (item.getTitle() != null) {
            db.setTitle(item.getTitle());
        }
        if (item.getContent() != null) {
            db.setContent(item.getContent());
        }
        db.setGmtModified(LocalDateTime.now());
        store.put(db.getId(), db);
        return db;
    }

    public void delete(Long id) {
        AssertUtil.notNull(store.remove(id), "记录不存在");
    }
}
