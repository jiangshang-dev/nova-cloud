package com.nova.demo.service.impl;

import com.nova.core.utils.AssertUtil;
import com.nova.core.utils.IdGeneratorUtil;
import com.nova.demo.constants.DemoMqConstants;
import com.nova.demo.domain.DemoItem;
import com.nova.demo.service.DemoItemService;
import com.nova.mq.client.RabbitMqClient;
import com.nova.mq.model.BaseMap;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

/**
 * {@link #create} 中演示通过 {@link RabbitMqClient} 发送 MQ 消息；
 * 消费端见 {@link com.nova.demo.mq.DemoItemCreateReceiver}。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DemoItemServiceImpl implements DemoItemService {

    private final RabbitMqClient rabbitMqClient;

    private final Map<Long, DemoItem> store = new ConcurrentHashMap<>();

    @Override
    public List<DemoItem> list(String title) {
        return store.values().stream()
                .filter(item -> title == null || title.isBlank()
                        || (item.getTitle() != null && item.getTitle().contains(title)))
                .sorted(Comparator.comparing(DemoItem::getGmtCreate).reversed())
                .collect(Collectors.toCollection(ArrayList::new));
    }

    @Override
    public DemoItem getById(Long id) {
        DemoItem item = store.get(id);
        AssertUtil.notNull(item, "记录不存在");
        return item;
    }

    @Override
    public DemoItem create(DemoItem item) {
        AssertUtil.isNotBlank(item.getTitle(), "title 不能为空");
        long id = IdGeneratorUtil.nextId();
        LocalDateTime now = LocalDateTime.now();
        item.setId(id);
        item.setGmtCreate(now);
        item.setGmtModified(now);
        store.put(id, item);

        BaseMap payload = new BaseMap()
                .set("id", item.getId())
                .set("title", item.getTitle())
                .set("content", item.getContent())
                .set("event", "CREATE");
        rabbitMqClient.sendMessage(DemoMqConstants.DEMO_ITEM_CREATE_QUEUE, payload);
        log.info("已发送 DemoItem 创建消息, queue={}, id={}", DemoMqConstants.DEMO_ITEM_CREATE_QUEUE, id);
        return item;
    }

    @Override
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

    @Override
    public void delete(Long id) {
        AssertUtil.notNull(store.remove(id), "记录不存在");
    }
}
