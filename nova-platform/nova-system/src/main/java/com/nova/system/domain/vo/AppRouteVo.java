package com.nova.system.domain.vo;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
public class AppRouteVo {
    private String path;
    private String name;
    private String component;
    private String redirect;
    private RouteMetaVo meta;
    private List<AppRouteVo> children = new ArrayList<>();
}
