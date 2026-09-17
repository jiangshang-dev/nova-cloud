package com.nova.system.domain.vo;

import com.nova.system.domain.entity.SysMenu;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.ArrayList;
import java.util.List;

@Data
@EqualsAndHashCode(callSuper = true)
public class MenuTreeVo extends SysMenu {
    private List<MenuTreeVo> children = new ArrayList<>();
}
