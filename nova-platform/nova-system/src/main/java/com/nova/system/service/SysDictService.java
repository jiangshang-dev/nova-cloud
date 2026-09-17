package com.nova.system.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.nova.core.exception.ServiceException;
import com.nova.core.utils.IdGeneratorUtil;
import com.nova.system.domain.entity.SysDictData;
import com.nova.system.domain.entity.SysDictType;
import com.nova.system.mapper.SysDictDataMapper;
import com.nova.system.mapper.SysDictTypeMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SysDictService {

    private final SysDictTypeMapper sysDictTypeMapper;
    private final SysDictDataMapper sysDictDataMapper;

    public Page<SysDictType> typePage(long current, long size, String dictName, String dictType) {
        LambdaQueryWrapper<SysDictType> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasText(dictName), SysDictType::getDictName, dictName)
                .like(StringUtils.hasText(dictType), SysDictType::getDictType, dictType)
                .orderByDesc(SysDictType::getId);
        return sysDictTypeMapper.selectPage(new Page<>(current, size), wrapper);
    }

    public List<SysDictType> typeList() {
        return sysDictTypeMapper.selectList(new LambdaQueryWrapper<SysDictType>()
                .eq(SysDictType::getStatus, 1)
                .orderByDesc(SysDictType::getId));
    }

    public SysDictType getType(Long id) {
        SysDictType type = sysDictTypeMapper.selectById(id);
        if (type == null) {
            throw new ServiceException("字典类型不存在");
        }
        return type;
    }

    public Long createType(SysDictType type) {
        if (type.getId() == null) {
            type.setId(IdGeneratorUtil.nextId());
        }
        if (type.getTenantId() == null) {
            type.setTenantId(0L);
        }
        if (type.getStatus() == null) {
            type.setStatus(1);
        }
        Long count = sysDictTypeMapper.selectCount(new LambdaQueryWrapper<SysDictType>()
                .eq(SysDictType::getTenantId, type.getTenantId())
                .eq(SysDictType::getDictType, type.getDictType()));
        if (count != null && count > 0) {
            throw new ServiceException("字典类型已存在");
        }
        sysDictTypeMapper.insert(type);
        return type.getId();
    }

    public void updateType(SysDictType type) {
        if (type.getId() == null) {
            throw new ServiceException("字典类型ID不能为空");
        }
        SysDictType old = getType(type.getId());
        // 若修改 dictType，同步更新字典数据
        if (StringUtils.hasText(type.getDictType()) && !type.getDictType().equals(old.getDictType())) {
            Long count = sysDictTypeMapper.selectCount(new LambdaQueryWrapper<SysDictType>()
                    .eq(SysDictType::getTenantId, old.getTenantId() == null ? 0L : old.getTenantId())
                    .eq(SysDictType::getDictType, type.getDictType())
                    .ne(SysDictType::getId, type.getId()));
            if (count != null && count > 0) {
                throw new ServiceException("字典类型已存在");
            }
            SysDictData patch = new SysDictData();
            patch.setDictType(type.getDictType());
            sysDictDataMapper.update(patch, new LambdaQueryWrapper<SysDictData>()
                    .eq(SysDictData::getDictType, old.getDictType()));
        }
        sysDictTypeMapper.updateById(type);
    }

    @Transactional(rollbackFor = Exception.class)
    public void deleteType(Long id) {
        SysDictType type = getType(id);
        sysDictTypeMapper.deleteById(id);
        sysDictDataMapper.delete(new LambdaQueryWrapper<SysDictData>()
                .eq(SysDictData::getDictType, type.getDictType()));
    }

    public Page<SysDictData> dataPage(long current, long size, String dictType, String dictLabel) {
        if (!StringUtils.hasText(dictType)) {
            throw new ServiceException("字典类型不能为空");
        }
        LambdaQueryWrapper<SysDictData> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysDictData::getDictType, dictType)
                .like(StringUtils.hasText(dictLabel), SysDictData::getDictLabel, dictLabel)
                .orderByAsc(SysDictData::getSort)
                .orderByDesc(SysDictData::getId);
        return sysDictDataMapper.selectPage(new Page<>(current, size), wrapper);
    }

    public List<SysDictData> dataList(String dictType) {
        return sysDictDataMapper.selectList(new LambdaQueryWrapper<SysDictData>()
                .eq(StringUtils.hasText(dictType), SysDictData::getDictType, dictType)
                .eq(SysDictData::getStatus, 1)
                .orderByAsc(SysDictData::getSort));
    }

    public SysDictData getData(Long id) {
        SysDictData data = sysDictDataMapper.selectById(id);
        if (data == null) {
            throw new ServiceException("字典数据不存在");
        }
        return data;
    }

    public Long createData(SysDictData data) {
        if (!StringUtils.hasText(data.getDictType())) {
            throw new ServiceException("字典类型不能为空");
        }
        if (data.getId() == null) {
            data.setId(IdGeneratorUtil.nextId());
        }
        if (data.getTenantId() == null) {
            data.setTenantId(0L);
        }
        if (data.getStatus() == null) {
            data.setStatus(1);
        }
        if (data.getSort() == null) {
            data.setSort(0);
        }
        sysDictDataMapper.insert(data);
        return data.getId();
    }

    public void updateData(SysDictData data) {
        if (data.getId() == null) {
            throw new ServiceException("字典数据ID不能为空");
        }
        getData(data.getId());
        sysDictDataMapper.updateById(data);
    }

    public void deleteData(Long id) {
        sysDictDataMapper.deleteById(id);
    }

    /** 前端字典缓存：dictType -> [{label,value,text}] */
    public Map<String, List<Map<String, Object>>> allItems() {
        List<SysDictData> all = sysDictDataMapper.selectList(new LambdaQueryWrapper<SysDictData>()
                .eq(SysDictData::getStatus, 1)
                .orderByAsc(SysDictData::getSort));
        Map<String, List<SysDictData>> grouped = all.stream()
                .collect(Collectors.groupingBy(SysDictData::getDictType, LinkedHashMap::new, Collectors.toList()));
        Map<String, List<Map<String, Object>>> result = new LinkedHashMap<>();
        grouped.forEach((type, list) -> result.put(type, list.stream().map(d -> {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("label", d.getDictLabel());
            item.put("text", d.getDictLabel());
            item.put("value", d.getDictValue());
            item.put("title", d.getDictLabel());
            return item;
        }).collect(Collectors.toList())));
        return result;
    }
}
