package com.nova.system.service;

import com.nova.system.domain.entity.SysMenu;
import com.nova.system.domain.vo.AppRouteVo;
import com.nova.system.domain.vo.RouteMetaVo;
import com.nova.system.domain.vo.UserPermissionVo;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

@Component
public class MenuRouteBuilder {

    private static final String LAYOUT = "LAYOUT";
    private static final String SKIP_COMPONENT = "system/config/index";

    public UserPermissionVo build(List<SysMenu> menus) {
        UserPermissionVo vo = new UserPermissionVo();
        vo.getMenu().add(dashboardRoute());

        Set<String> codeSet = new LinkedHashSet<>();
        for (SysMenu menu : menus) {
            if (StringUtils.hasText(menu.getPermission())) {
                codeSet.add(menu.getPermission());
            }
        }
        vo.setCodeList(new ArrayList<>(codeSet));

        List<SysMenu> routeMenus = menus.stream()
                .filter(m -> "M".equals(m.getMenuType()) || "C".equals(m.getMenuType()))
                .filter(m -> !shouldSkipMenu(m))
                .sorted(Comparator.comparing(SysMenu::getSort, Comparator.nullsLast(Integer::compareTo)))
                .toList();

        Map<Long, List<SysMenu>> childrenMap = routeMenus.stream()
                .collect(Collectors.groupingBy(m -> m.getParentId() == null ? 0L : m.getParentId()));

        List<SysMenu> roots = childrenMap.getOrDefault(0L, List.of()).stream()
                .sorted(Comparator.comparing(SysMenu::getSort, Comparator.nullsLast(Integer::compareTo)))
                .toList();

        for (SysMenu root : roots) {
            AppRouteVo route = toRoute(root, null, childrenMap);
            if ("/system".equals(route.getPath())) {
                injectUserSetting(route);
            }
            ensureMeta(route);
            vo.getMenu().add(route);
        }
        return vo;
    }

    private void ensureMeta(AppRouteVo route) {
        if (route == null) {
            return;
        }
        if (route.getMeta() == null) {
            RouteMetaVo meta = new RouteMetaVo();
            meta.setTitle(StringUtils.hasText(route.getName()) ? route.getName() : route.getPath());
            meta.setHideMenu(false);
            route.setMeta(meta);
        }
        if (route.getChildren() != null) {
            route.getChildren().forEach(this::ensureMeta);
        }
    }

    private void injectUserSetting(AppRouteVo systemRoute) {
        boolean exists = systemRoute.getChildren().stream()
                .anyMatch(c -> "usersetting".equals(c.getPath()) || "system-usersetting".equals(c.getName()));
        if (exists) {
            return;
        }
        AppRouteVo setting = leafRoute(
                "usersetting",
                "system-usersetting",
                "system/usersetting/UserSetting",
                "账户设置",
                "ant-design:setting-outlined",
                99,
                true);
        systemRoute.getChildren().add(setting);
    }

    private AppRouteVo dashboardRoute() {
        AppRouteVo dashboard = new AppRouteVo();
        dashboard.setPath("/dashboard");
        dashboard.setName("dashboard");
        dashboard.setComponent(LAYOUT);
        dashboard.setRedirect("/dashboard/analysis");
        RouteMetaVo dashMeta = new RouteMetaVo();
        dashMeta.setTitle("仪表盘");
        dashMeta.setIcon("ant-design:dashboard-outlined");
        dashMeta.setOrderNo(0);
        dashMeta.setHideMenu(false);
        dashboard.setMeta(dashMeta);

        AppRouteVo analysis = leafRoute("analysis", "dashboard-analysis", "dashboard/Analysis/index", "分析页", "ant-design:fund-outlined", 0, false);
        AppRouteVo workbench = leafRoute("workbench", "dashboard-workbench", "dashboard/workbench/index", "工作台", "ant-design:appstore-outlined", 1, false);
        dashboard.getChildren().add(analysis);
        dashboard.getChildren().add(workbench);
        return dashboard;
    }

    private AppRouteVo leafRoute(String path, String name, String component, String title, String icon, int orderNo, boolean hideMenu) {
        AppRouteVo route = new AppRouteVo();
        route.setPath(path);
        route.setName(name);
        route.setComponent(component);
        RouteMetaVo meta = new RouteMetaVo();
        meta.setTitle(title);
        meta.setIcon(icon);
        meta.setOrderNo(orderNo);
        meta.setHideMenu(hideMenu);
        route.setMeta(meta);
        return route;
    }

    private AppRouteVo toRoute(SysMenu menu, String parentPath, Map<Long, List<SysMenu>> childrenMap) {
        AppRouteVo route = new AppRouteVo();
        route.setPath(resolvePath(menu));
        route.setName(routeName(parentPath, menu));
        route.setMeta(buildMeta(menu));

        if ("M".equals(menu.getMenuType())) {
            route.setComponent(LAYOUT);
            List<SysMenu> children = childrenMap.getOrDefault(menu.getId(), List.of()).stream()
                    .filter(c -> !shouldSkipMenu(c))
                    .sorted(Comparator.comparing(SysMenu::getSort, Comparator.nullsLast(Integer::compareTo)))
                    .toList();
            String basePath = menu.getPath();
            for (SysMenu child : children) {
                route.getChildren().add(toRoute(child, basePath, childrenMap));
            }
            if (!route.getChildren().isEmpty() && StringUtils.hasText(route.getPath())) {
                AppRouteVo first = route.getChildren().get(0);
                String childPath = first.getPath();
                if (StringUtils.hasText(childPath) && !childPath.startsWith("/")) {
                    String parent = route.getPath().endsWith("/") ? route.getPath() : route.getPath() + "/";
                    route.setRedirect(parent + childPath);
                }
            }
        } else {
            route.setComponent(mapComponent(menu.getComponent()));
        }
        return route;
    }

    private String resolvePath(SysMenu menu) {
        return menu.getPath();
    }

    private RouteMetaVo buildMeta(SysMenu menu) {
        RouteMetaVo meta = new RouteMetaVo();
        meta.setTitle(menu.getMenuName());
        meta.setIcon(normalizeIcon(menu.getIcon()));
        meta.setOrderNo(menu.getSort());
        meta.setHideMenu(Objects.equals(menu.getIsVisible(), 0));
        return meta;
    }

    private String normalizeIcon(String icon) {
        if (!StringUtils.hasText(icon)) {
            return icon;
        }
        if (icon.contains(":")) {
            return icon;
        }
        return switch (icon) {
            case "setting" -> "ant-design:setting-outlined";
            case "user" -> "ant-design:user-outlined";
            case "peoples" -> "ant-design:team-outlined";
            case "tree-table" -> "ant-design:table-outlined";
            case "tree" -> "ant-design:apartment-outlined";
            case "dict" -> "ant-design:book-outlined";
            case "edit" -> "ant-design:edit-outlined";
            case "file-search" -> "ant-design:file-search-outlined";
            case "robot" -> "ant-design:robot-outlined";
            case "component" -> "ant-design:appstore-outlined";
            case "guide" -> "ant-design:compass-outlined";
            case "documentation" -> "ant-design:file-text-outlined";
            case "upload" -> "ant-design:cloud-upload-outlined";
            case "list" -> "ant-design:unordered-list-outlined";
            case "server" -> "ant-design:cloud-server-outlined";
            case "monitor" -> "ant-design:dashboard-outlined";
            case "form" -> "ant-design:form-outlined";
            case "logininfor" -> "ant-design:login-outlined";
            default -> "ant-design:" + icon + "-outlined";
        };
    }

    private String routeName(String parentPath, SysMenu menu) {
        String segment = menu.getPath();
        if (StringUtils.hasText(parentPath)) {
            String normalized = parentPath.startsWith("/") ? parentPath.substring(1) : parentPath;
            segment = normalized + "-" + menu.getPath();
        } else if (StringUtils.hasText(menu.getPath()) && menu.getPath().startsWith("/")) {
            segment = menu.getPath().substring(1);
        }
        return segment.replace("/", "-");
    }

    public String mapComponent(String component) {
        if (!StringUtils.hasText(component)) {
            return component;
        }
        return switch (component) {
            case "system/dept/index" -> "system/depart/index";
            case "monitor/operlog/index", "monitor/loginlog/index" -> "monitor/log/index";
            default -> component;
        };
    }

    private boolean shouldSkipMenu(SysMenu menu) {
        if (!StringUtils.hasText(menu.getComponent())) {
            return false;
        }
        String mapped = mapComponent(menu.getComponent());
        return SKIP_COMPONENT.equals(menu.getComponent()) || SKIP_COMPONENT.equals(mapped);
    }
}
