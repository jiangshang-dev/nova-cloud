package com.nova.system.domain.vo;

import com.nova.system.domain.entity.SysDept;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.ArrayList;
import java.util.List;

@Data
@EqualsAndHashCode(callSuper = true)
public class DeptTreeVo extends SysDept {
    private List<DeptTreeVo> children = new ArrayList<>();
}
