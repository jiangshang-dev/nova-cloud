package com.nova.demo.service;

import com.nova.demo.domain.DemoItem;

import java.util.List;

/**
 * DemoItem 业务（内存 + MQ 生产示例）。
 */
public interface DemoItemService {

    List<DemoItem> list(String title);

    DemoItem getById(Long id);

    DemoItem create(DemoItem item);

    DemoItem update(DemoItem item);

    void delete(Long id);
}
