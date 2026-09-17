package com.nova.system.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nova.core.exception.ServiceException;
import com.nova.core.utils.IdGeneratorUtil;
import com.nova.system.domain.entity.SysDept;
import com.nova.system.domain.vo.DeptTreeVo;
import com.nova.system.mapper.SysDeptMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SysDeptService {

    private final SysDeptMapper sysDeptMapper;

    public List<SysDept> list(String deptName) {
        return sysDeptMapper.selectList(new LambdaQueryWrapper<SysDept>()
                .like(StringUtils.hasText(deptName), SysDept::getDeptName, deptName)
                .orderByAsc(SysDept::getSort)
                .orderByAsc(SysDept::getId));
    }

    public List<DeptTreeVo> tree(String deptName) {
        List<SysDept> all = list(deptName);
        if (StringUtils.hasText(deptName)) {
            // 搜索时扁平返回为树叶（无父子折叠）
            return all.stream().map(d -> {
                DeptTreeVo vo = new DeptTreeVo();
                BeanUtils.copyProperties(d, vo);
                return vo;
            }).toList();
        }
        Map<Long, List<SysDept>> grouped = all.stream()
                .collect(Collectors.groupingBy(d -> d.getParentId() == null ? 0L : d.getParentId()));
        return buildTree(grouped, 0L);
    }

    public SysDept getById(Long id) {
        SysDept dept = sysDeptMapper.selectById(id);
        if (dept == null) {
            throw new ServiceException("部门不存在");
        }
        return dept;
    }

    public Long create(SysDept dept) {
        if (dept.getId() == null) {
            dept.setId(IdGeneratorUtil.nextId());
        }
        if (dept.getTenantId() == null) {
            dept.setTenantId(1L);
        }
        if (dept.getParentId() == null) {
            dept.setParentId(0L);
        }
        if (dept.getStatus() == null) {
            dept.setStatus(1);
        }
        if (dept.getSort() == null) {
            dept.setSort(0);
        }
        dept.setAncestors(buildAncestors(dept.getParentId()));
        if (StringUtils.hasText(dept.getDeptCode())) {
            Long count = sysDeptMapper.selectCount(new LambdaQueryWrapper<SysDept>()
                    .eq(SysDept::getTenantId, dept.getTenantId())
                    .eq(SysDept::getDeptCode, dept.getDeptCode()));
            if (count != null && count > 0) {
                throw new ServiceException("部门编码已存在");
            }
        }
        sysDeptMapper.insert(dept);
        return dept.getId();
    }

    public void update(SysDept dept) {
        if (dept.getId() == null) {
            throw new ServiceException("部门ID不能为空");
        }
        SysDept old = getById(dept.getId());
        if (dept.getParentId() != null && !dept.getParentId().equals(old.getParentId())) {
            if (dept.getId().equals(dept.getParentId())) {
                throw new ServiceException("上级部门不能是自己");
            }
            dept.setAncestors(buildAncestors(dept.getParentId()));
        }
        sysDeptMapper.updateById(dept);
    }

    public void delete(Long id) {
        getById(id);
        Long child = sysDeptMapper.selectCount(new LambdaQueryWrapper<SysDept>().eq(SysDept::getParentId, id));
        if (child != null && child > 0) {
            throw new ServiceException("存在下级部门，无法删除");
        }
        sysDeptMapper.deleteById(id);
    }

    private String buildAncestors(Long parentId) {
        if (parentId == null || parentId == 0L) {
            return "0";
        }
        SysDept parent = getById(parentId);
        String ancestors = parent.getAncestors();
        if (!StringUtils.hasText(ancestors)) {
            return "0," + parent.getId();
        }
        return ancestors + "," + parent.getId();
    }

    private List<DeptTreeVo> buildTree(Map<Long, List<SysDept>> grouped, Long parentId) {
        List<SysDept> nodes = grouped.getOrDefault(parentId, List.of()).stream()
                .sorted(Comparator.comparing(SysDept::getSort, Comparator.nullsLast(Integer::compareTo)))
                .toList();
        List<DeptTreeVo> result = new ArrayList<>();
        for (SysDept node : nodes) {
            DeptTreeVo vo = new DeptTreeVo();
            BeanUtils.copyProperties(node, vo);
            vo.setChildren(buildTree(grouped, node.getId()));
            result.add(vo);
        }
        return result;
    }
}
